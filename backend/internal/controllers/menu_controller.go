package controllers

import (
    "net/http"

    "jd-take-out-backend/internal/models"

    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

// MenuController for fetching the entire menu
type MenuController struct {
    DB *gorm.DB
}

// MenuCategory is a struct for the full menu response
type MenuCategory struct {
    models.Category
    Dishes []models.Dish `json:"dishes"`
}

// GetFullMenu fetches all categories and their corresponding dishes
func (mc *MenuController) GetFullMenu(c *gin.Context) {
    var categories []models.Category
    // 1. Find all active categories, ordered by sort number
    if err := mc.DB.Where("status = ?", 1).Order("sort ASC").Find(&categories).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "Failed to get categories"})
        return
    }

    var dishes []models.Dish
    // 2. Find all active dishes, preloading their flavor options
    if err := mc.DB.Where("status = ?", 1).Preload("DishFlavors").Order("id ASC").Find(&dishes).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "Failed to get dishes"})
        return
    }

    // 3. Group dishes by their category ID for efficient lookup
    dishMap := make(map[uint][]models.Dish)
    for _, dish := range dishes {
        dishMap[dish.CategoryID] = append(dishMap[dish.CategoryID], dish)
    }

    // 4. Build the final nested menu structure
    var menu []MenuCategory
    for _, category := range categories {
        // Only include categories that have dishes
        if _, ok := dishMap[category.ID]; ok {
            menu = append(menu, MenuCategory{
                Category: category,
                Dishes:   dishMap[category.ID],
            })
        }
    }

    c.JSON(http.StatusOK, gin.H{
        "code":    200,
        "message": "Success",
        "data":    menu,
    })
}
