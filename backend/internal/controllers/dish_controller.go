package controllers

import (
	"net/http"
	"strconv"

	"jd-take-out-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// DishController 菜品控制器
type DishController struct {
	DB *gorm.DB
}

// CreateDishRequest 新增菜品请求结构
type CreateDishRequest struct {
	Name        string  `json:"name" binding:"required"`
	CategoryID  uint    `json:"category_id" binding:"required"`
	Price       float64 `json:"price" binding:"required,gte=0"`
	Image       string  `json:"image"`
	Description string  `json:"description"`
	Status      int     `json:"status" binding:"oneof=0 1"` // 0:停售 1:起售
}

// UpdateDishRequest 更新菜品请求结构
type UpdateDishRequest struct {
	Name        string  `json:"name"`
	CategoryID  uint    `json:"category_id"`
	Price       float64 `json:"price,gte=0"`
	Image       string  `json:"image"`
	Description string  `json:"description"`
	Status      int     `json:"status" binding:"oneof=0 1"`
}

// ListDishes 获取菜品列表（分页）
// @Summary      获取菜品分页列表
// @Description  根据分页参数和可选的筛选条件获取菜品列表
// @Tags         菜品管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        page     query    int     false  "页码"				default(1)
// @Param        limit    query    int     false  "每页数量"			default(10)
// @Param        name     query    string  false  "菜品名称 (用于模糊搜索)"
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Failure      401      {object}  map[string]interface{}  "未授权"
// @Failure      500      {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/admin/dishes [get]
func (dc *DishController) ListDishes(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	name := c.Query("name")
	categoryID := c.Query("categoryId")

	var dishes []models.Dish
	var total int64

	db := dc.DB.Model(&models.Dish{})

	// 按名称模糊搜索
	if name != "" {
		db = db.Where("name LIKE ?", "%"+name+"%")
	}

	// 按分类ID精确搜索
	if categoryID != "" {
		db = db.Where("category_id = ?", categoryID)
	}

	// 获取总数
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取菜品总数失败"})
		return
	}

	// 获取分页数据
	if err := db.Preload("Category").Preload("DishFlavors").Order("id ASC").Offset((page - 1) * limit).Limit(limit).Find(&dishes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取菜品列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"items": dishes,
			"total": total,
		},
	})
}

// CreateDish 新增菜品
// @Summary      新增菜品
// @Description  创建一个新的菜品
// @Tags         菜品管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body     body      CreateDishRequest  true   "菜品信息"
// @Success      201      {object}  map[string]interface{}  "创建成功"
// @Failure      400      {object}  map[string]interface{}  "参数错误"
// @Failure      401      {object}  map[string]interface{}  "未授权"
// @Failure      500      {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/admin/dishes [post]
func (dc *DishController) CreateDish(c *gin.Context) {
	var req CreateDishRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	// 从上下文中获取创建者ID
	createUserID, _ := c.Get("user_id")

	dish := models.Dish{
		Name:        req.Name,
		CategoryID:  req.CategoryID,
		Price:       req.Price,
		Image:       req.Image,
		Description: req.Description,
		Status:      req.Status,
		CreateUser:  createUserID.(uint),
		UpdateUser:  createUserID.(uint),
	}

	if err := dc.DB.Create(&dish).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建菜品失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建成功",
		"data":    dish,
	})
}

// GetDishByID 获取单个菜品详情
// @Summary      获取菜品详情
// @Description  根据ID获取单个菜品的详细信息
// @Tags         菜品管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "菜品ID"
// @Success      200  {object}  map[string]interface{}  "成功响应"
// @Failure      404  {object}  map[string]interface{}  "记录未找到"
// @Router       /api/v1/admin/dishes/{id} [get]
func (dc *DishController) GetDishByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var dish models.Dish
	if err := dc.DB.Preload("Category").First(&dish, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "菜品未找到"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "data": dish})
}

// UpdateDish 更新菜品
// @Summary      更新菜品信息
// @Description  更新指定ID的菜品信息
// @Tags         菜品管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "菜品ID"
// @Param        body body      UpdateDishRequest  true   "要更新的菜品信息"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Failure      400  {object}  map[string]interface{}  "参数错误"
// @Failure      404  {object}  map[string]interface{}  "记录未找到"
// @Router       /api/v1/admin/dishes/{id} [put]
func (dc *DishController) UpdateDish(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var dish models.Dish
	if err := dc.DB.First(&dish, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "菜品未找到"})
		return
	}

	var req UpdateDishRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	updateUserID, _ := c.Get("user_id")

	// 使用 map 更新字段，以确保零值（如 status: 0）也能被正确更新
	updateData := map[string]interface{}{
		"name":        req.Name,
		"category_id": req.CategoryID,
		"price":       req.Price,
		"image":       req.Image,
		"description": req.Description,
		"status":      req.Status,
		"update_user": updateUserID.(uint),
	}

	dc.DB.Model(&dish).Updates(updateData)

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功", "data": dish})
}

// DeleteDish 删除菜品
// @Summary      删除菜品
// @Description  根据ID删除指定菜品
// @Tags         菜品管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "菜品ID"
// @Success      204  {object}  nil "删除成功"
// @Failure      404  {object}  map[string]interface{}  "记录未找到"
// @Router       /api/v1/admin/dishes/{id} [delete]
func (dc *DishController) DeleteDish(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	// 使用GORM的软删除
	tx := dc.DB.Delete(&models.Dish{}, id)
	if tx.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除失败"})
		return
	}

	if tx.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "菜品未找到，无法删除"})
		return
	}

	c.Status(http.StatusNoContent)
}