package controllers

import (
	"net/http"
	"strconv"

	"jd-take-out-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// CategoryController 分类控制器
type CategoryController struct {
	DB *gorm.DB
}

// CategoryRequest 定义了新增或更新分类时的请求体
type CategoryRequest struct {
	Name   string `json:"name" binding:"required"`
	Type   int    `json:"type" binding:"required,oneof=1 2"` // 1:菜品分类 2:套餐分类
	Sort   int    `json:"sort" binding:"gte=0"`
	Status int    `json:"status" binding:"oneof=0 1"`
}

// ListCategories 获取所有菜品或套餐分类
// @Summary      获取分类列表
// @Description  根据类型获取所有菜品或套餐的分类列表
// @Tags         分类管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        type     query    int     false  "分类类型 (1:菜品分类, 2:套餐分类)"
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Failure      401      {object}  map[string]interface{}  "未授权"
// @Failure      500      {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/admin/categories [get]
func (cc *CategoryController) ListCategories(c *gin.Context) {
	categoryType := c.Query("type")

	var categories []models.Category
	db := cc.DB.Order("sort asc, created_at desc")

	if categoryType != "" {
		db = db.Where("type = ?", categoryType)
	}

	if err := db.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取分类列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    categories,
	})
}

// CreateCategory 新增分类
// @Summary      新增分类
// @Description  创建一个新的菜品或套餐分类
// @Tags         分类管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body  body      CategoryRequest  true  "分类信息"
// @Success      201   {object}  map[string]interface{}  "创建成功"
// @Failure      400   {object}  map[string]interface{}  "参数错误"
// @Failure      500   {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/admin/categories [post]
func (cc *CategoryController) CreateCategory(c *gin.Context) {
	var req CategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	createUserID, _ := c.Get("user_id")

	category := models.Category{
		Name:       req.Name,
		Type:       req.Type,
		Sort:       req.Sort,
		Status:     req.Status,
		CreateUser: createUserID.(uint),
		UpdateUser: createUserID.(uint),
	}

	if err := cc.DB.Create(&category).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建分类失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建成功",
		"data":    category,
	})
}

// UpdateCategory 更新分类
// @Summary      更新分类
// @Description  更新指定ID的分类信息
// @Tags         分类管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id    path      int              true  "分类ID"
// @Param        body  body      CategoryRequest  true  "要更新的分类信息"
// @Success      200   {object}  map[string]interface{}  "更新成功"
// @Failure      400   {object}  map[string]interface{}  "参数错误"
// @Failure      404   {object}  map[string]interface{}  "记录未找到"
// @Router       /api/v1/admin/categories/{id} [put]
func (cc *CategoryController) UpdateCategory(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var category models.Category
	if err := cc.DB.First(&category, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "分类未找到"})
		return
	}

	var req CategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	updateUserID, _ := c.Get("user_id")

	updateData := map[string]interface{}{
		"name":       req.Name,
		"type":       req.Type,
		"sort":       req.Sort,
		"status":     req.Status,
		"update_user": updateUserID.(uint),
	}

	cc.DB.Model(&category).Updates(updateData)

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功", "data": category})
}

// DeleteCategory 删除分类
// @Summary      删除分类
// @Description  根据ID删除指定分类
// @Tags         分类管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "分类ID"
// @Success      204  {object}  nil "删除成功"
// @Failure      404  {object}  map[string]interface{}  "记录未找到"
// @Router       /api/v1/admin/categories/{id} [delete]
func (cc *CategoryController) DeleteCategory(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	// 注意：删除分类前，最好检查该分类下是否还有菜品
	var count int64
	cc.DB.Model(&models.Dish{}).Where("category_id = ?", id).Count(&count)
	if count > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无法删除，该分类下仍有关联菜品"})
		return
	}

	tx := cc.DB.Delete(&models.Category{}, id)
	if tx.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除失败"})
		return
	}

	if tx.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "分类未找到，无法删除"})
		return
	}

	c.Status(http.StatusNoContent)
}
