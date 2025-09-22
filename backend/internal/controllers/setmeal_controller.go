package controllers

import (
	"jd-take-out-backend/internal/models"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SetmealController 套餐控制器
type SetmealController struct {
	DB *gorm.DB
}

// SetmealRequest 定义了新增或更新套餐时的请求体
type SetmealRequest struct {
	Name        string  `json:"name" binding:"required"`
	CategoryID  uint    `json:"category_id" binding:"required"`
	Price       float64 `json:"price" binding:"required,gte=0"`
	Image       string  `json:"image"`
	Description string  `json:"description"`
	Status      int     `json:"status" binding:"oneof=0 1"`
	DishIDs     []uint  `json:"dish_ids" binding:"required,min=1"` // 套餐包含的菜品ID列表
}

// ListSetmeals 获取套餐分页列表
// @Summary      获取套餐分页列表
// @Description  获取所有套餐的列表，支持分页
// @Tags         套餐管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        page     query    int     false  "页码"
// @Param        pageSize query    int     false  "每页数量"
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/setmeals [get]
func (sc *SetmealController) ListSetmeals(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var setmeals []models.Setmeal
	var total int64

	db := sc.DB.Model(&models.Setmeal{})

	// 如果不是管理员或员工接口，则只查询在售套餐
	if !strings.HasPrefix(c.Request.URL.Path, "/api/v1/admin") && !strings.HasPrefix(c.Request.URL.Path, "/api/v1/employee") {
		db = db.Where("status = ?", 1)
	}

	// 获取总数
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取套餐总数失败"})
		return
	}

	// 获取分页数据
	offset := (page - 1) * limit
	err := db.Preload("Category").Preload("SetmealDishes").Order("id ASC").Offset(offset).Limit(limit).Find(&setmeals).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取套餐列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"items": setmeals,
			"total": total,
		},
	})
}

// CreateSetmeal 新增套餐
// @Summary      新增套餐
// @Description  创建一个新的套餐，并关联菜品
// @Tags         套餐管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body     body      SetmealRequest  true   "套餐信息"
// @Success      201      {object}  map[string]interface{}  "创建成功"
// @Router       /api/v1/admin/setmeals [post]
func (sc *SetmealController) CreateSetmeal(c *gin.Context) {
	var req SetmealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	createUserID, _ := c.Get("user_id")

	setmeal := models.Setmeal{
		Name:        req.Name,
		CategoryID:  req.CategoryID,
		Price:       req.Price,
		Image:       req.Image,
		Description: req.Description,
		Status:      req.Status,
		CreateUser:  createUserID.(uint),
		UpdateUser:  createUserID.(uint),
	}

	tx := sc.DB.Begin()

	// 1. 创建套餐
	if err := tx.Create(&setmeal).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建套餐失败: " + err.Error()})
		return
	}

	// 2. 创建套餐和菜品的关联关系
	var dishes []models.Dish
	if err := tx.Where("id IN ?", req.DishIDs).Find(&dishes).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "关联菜品查询失败"})
		return
	}

	setmealDishes := make([]models.SetmealDish, len(dishes))
	for i, dish := range dishes {
		setmealDishes[i] = models.SetmealDish{
			SetmealID: setmeal.ID,
			DishID:    dish.ID,
			Name:      dish.Name,
			Price:     dish.Price,
			Copies:    1, // 默认1份
		}
	}

	if err := tx.Create(&setmealDishes).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建套餐菜品关联失败"})
		return
	}

	tx.Commit()

	c.JSON(http.StatusCreated, gin.H{"code": 201, "message": "创建成功", "data": setmeal})
}

// GetSetmealByID 获取单个套餐详情
// @Summary      获取套餐详情
// @Description  根据ID获取单个套餐的详细信息，包括关联的菜品
// @Tags         套餐管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "套餐ID"
// @Success      200  {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/setmeals/{id} [get]
func (sc *SetmealController) GetSetmealByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var setmeal models.Setmeal
	if err := sc.DB.Preload("Category").Preload("SetmealDishes").First(&setmeal, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "套餐未找到"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "data": setmeal})
}

// UpdateSetmeal 更新套餐
// @Summary      更新套餐信息
// @Description  更新指定ID的套餐信息，并重新设置关联的菜品
// @Tags         套餐管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int             true   "套餐ID"
// @Param        body body      SetmealRequest  true   "要更新的套餐信息"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Router       /api/v1/admin/setmeals/{id} [put]
func (sc *SetmealController) UpdateSetmeal(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req SetmealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var setmeal models.Setmeal
	if err := sc.DB.First(&setmeal, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "套餐未找到"})
		return
	}

	updateUserID, _ := c.Get("user_id")
	tx := sc.DB.Begin()

	// 1. 更新套餐主表
	setmeal.Name = req.Name
	setmeal.CategoryID = req.CategoryID
	setmeal.Price = req.Price
	setmeal.Image = req.Image
	setmeal.Description = req.Description
	setmeal.Status = req.Status
	setmeal.UpdateUser = updateUserID.(uint)
	if err := tx.Save(&setmeal).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新套餐失败"})
		return
	}

	// 2. 删除旧的套餐菜品关联
	if err := tx.Where("setmeal_id = ?", setmeal.ID).Delete(&models.SetmealDish{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除旧关联失败"})
		return
	}

	// 3. 创建新的套餐菜品关联
	var dishes []models.Dish
	if err := tx.Where("id IN ?", req.DishIDs).Find(&dishes).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "关联菜品查询失败"})
		return
	}
	setmealDishes := make([]models.SetmealDish, len(dishes))
	for i, dish := range dishes {
		setmealDishes[i] = models.SetmealDish{SetmealID: setmeal.ID, DishID: dish.ID, Name: dish.Name, Price: dish.Price, Copies: 1}
	}
	if err := tx.Create(&setmealDishes).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建新关联失败"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}

// DeleteSetmeal 删除套餐
// @Summary      删除套餐
// @Description  根据ID删除指定套餐及其关联的菜品
// @Tags         套餐管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "套餐ID"
// @Success      204  {object}  nil "删除成功"
// @Router       /api/v1/admin/setmeals/{id} [delete]
func (sc *SetmealController) DeleteSetmeal(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	// 检查套餐是否仍在起售状态
	var setmeal models.Setmeal
	if err := sc.DB.First(&setmeal, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "套餐未找到"})
		return
	}

	if setmeal.Status == 1 {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无法删除起售中的套餐，请先停售"})
		return
	}

	tx := sc.DB.Begin()

	// 1. 删除套餐与菜品的关联记录
	if err := tx.Where("setmeal_id = ?", id).Delete(&models.SetmealDish{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除套餐关联菜品失败: " + err.Error()})
		return
	}

	// 2. 手动执行软删除：显式更新 deleted_at 字段
	result := tx.Model(&models.Setmeal{}).Where("id = ?", id).Update("deleted_at", time.Now())
	if result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "软删除套餐失败: " + result.Error.Error()})
		return
	}

	// 如果影响行数为0，说明该套餐不存在或已被删除
	if result.RowsAffected == 0 {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "套餐未找到或已被删除"})
		return
	}

	tx.Commit()

	c.Status(http.StatusNoContent) // 返回 204 No Content 表示成功
}