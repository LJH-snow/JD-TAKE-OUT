package controllers

import (
	"net/http"
	"strconv"

	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils" // 添加这一行

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// UserController 用户控制器
type UserController struct {
	DB *gorm.DB
}

// ListUsersRequest 定义了获取用户列表时的请求参数
type ListUsersRequest struct {
	Page     int    `form:"page,default=1"`
	PageSize int    `form:"pageSize,default=10"`
	Name     string `form:"name"`
	Phone    string `form:"phone"`
	IsActive string `form:"is_active"` // "true" 或 "false"
}

// UpdateUserRequest 定义了更新用户时的请求体
type UpdateUserRequest struct {
	Name     string `json:"name"`
	Phone    string `json:"phone"`
	Sex      string `json:"sex" binding:"oneof=0 1"`
	IsActive bool   `json:"is_active"`
}

// UpdateCurrentUserRequest 定义了当前用户更新自己信息时的请求体
type UpdateCurrentUserRequest struct {
	Name   string `json:"name" binding:"required"`
	Sex    string `json:"sex" binding:"oneof=0 1"`
	Avatar string `json:"avatar"`
}

// ChangePasswordRequest 定义了修改密码时的请求体
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required"`
}

// ListUsers 获取用户分页列表
// @Summary      获取用户分页列表
// @Description  根据分页和筛选条件获取用户列表
// @Tags         用户管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        page     query    int     false  "页码"
// @Param        pageSize query    int     false  "每页数量"
// @Param        name     query    string  false  "用户姓名"
// @Param        phone    query    string  false  "手机号"
// @Param        is_active query    string  false  "是否激活 (true/false)"
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/users [get]
func (uc *UserController) ListUsers(c *gin.Context) {
	var req ListUsersRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	var users []models.User
	var total int64

	db := uc.DB.Model(&models.User{})

	// 应用筛选
	if req.Name != "" {
		db = db.Where("name LIKE ?", "%"+req.Name+"%")
	}
	if req.Phone != "" {
		db = db.Where("phone LIKE ?", "%"+req.Phone+"%")
	}
	if req.IsActive != "" {
		isActive, err := strconv.ParseBool(req.IsActive)
		if err == nil {
			db = db.Where("is_active = ?", isActive)
		}
	}

	// 获取总数
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取用户总数失败"})
		return
	}

	// 获取分页数据
	offset := (req.Page - 1) * req.PageSize
	err := db.Order("created_at DESC").Offset(offset).Limit(req.PageSize).Find(&users).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取用户列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"items": users,
			"total": total,
		},
	})
}

// GetUserByID 获取单个用户详情
// @Summary      获取用户详情
// @Description  根据ID获取单个用户的详细信息
// @Tags         用户管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "用户ID"
// @Success      200  {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/users/{id} [get]
func (uc *UserController) GetUserByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var user models.User
	if err := uc.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "用户未找到"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "data": user})
}

// UpdateUser 更新用户信息
// @Summary      更新用户信息
// @Description  更新指定ID的用户信息，包括激活状态
// @Tags         用户管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int             true   "用户ID"
// @Param        body body      UpdateUserRequest  true   "要更新的用户信息"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Router       /api/v1/admin/users/{id} [put]
func (uc *UserController) UpdateUser(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var user models.User
	if err := uc.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "用户未找到"})
		return
	}

	// 更新字段
	updateData := map[string]interface{}{
		"name":      req.Name,
		"phone":     req.Phone,
		"sex":       req.Sex,
		"is_active": req.IsActive,
	}

	if err := uc.DB.Model(&user).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新用户失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}

// UpdateCurrentUser 更新当前登录用户信息
func (uc *UserController) UpdateCurrentUser(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userID := claims.(*utils.Claims).UserID

	var req UpdateCurrentUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	updateData := map[string]interface{}{
		"name":   req.Name,
		"sex":    req.Sex,
		"avatar": req.Avatar,
	}

	if err := uc.DB.Model(&models.User{}).Where("id = ?", userID).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新用户信息失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}

// ChangePassword 修改当前用户密码
func (uc *UserController) ChangePassword(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userID := claims.(*utils.Claims).UserID

	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var user models.User
	if err := uc.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "用户未找到"})
		return
	}

	// 校验旧密码
	if !utils.CheckPassword(req.OldPassword, user.Password) {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "旧密码不正确"})
		return
	}

	// 哈希新密码
	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "密码哈希失败"})
		return
	}

	// 更新密码
	if err := uc.DB.Model(&user).Update("password", hashedPassword).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新密码失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "密码修改成功"})
}
