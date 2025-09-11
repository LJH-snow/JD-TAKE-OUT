package controllers

import (
	"net/http"
	

	"jd-take-out-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SettingController 设置控制器
type SettingController struct {
	DB *gorm.DB
}

// UpdateSettingRequest 定义了更新设置时的请求体
type UpdateSettingRequest struct {
	Name        string `json:"name" binding:"required"`
	Address     string `json:"address"`
	Phone       string `json:"phone"`
	Description string `json:"description"`
	Logo        string `json:"logo"`
	IsOpen      bool   `json:"is_open"`
}

// GetSettings 获取店铺设置
// @Summary      获取店铺设置
// @Description  获取当前店铺的配置信息
// @Tags         店铺设置
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/settings [get]
func (sc *SettingController) GetSettings(c *gin.Context) {
	var setting models.StoreSetting
	// 尝试获取第一条记录，通常店铺设置只有一条
	if err := sc.DB.First(&setting).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// 如果没有记录，返回一个默认的空设置
			c.JSON(http.StatusOK, gin.H{"code": 200, "message": "获取成功", "data": models.StoreSetting{}})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取设置失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "获取成功", "data": setting})
}

// UpdateSettings 更新店铺设置
// @Summary      更新店铺设置
// @Description  更新当前店铺的配置信息，如果不存在则创建
// @Tags         店铺设置
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body     body      UpdateSettingRequest  true   "店铺设置信息"
// @Success      200      {object}  map[string]interface{}  "更新成功"
// @Router       /api/v1/admin/settings [put]
func (sc *SettingController) UpdateSettings(c *gin.Context) {
	var req UpdateSettingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var setting models.StoreSetting
	// 尝试获取第一条记录
	if err := sc.DB.First(&setting).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// 如果没有记录，则创建新记录
			createUserID, _ := c.Get("user_id")
			newSetting := models.StoreSetting{
				Name:        req.Name,
				Address:     req.Address,
				Phone:       req.Phone,
				Description: req.Description,
				Logo:        req.Logo,
				IsOpen:      req.IsOpen, // Added field
				CreateUser:  createUserID.(uint),
				UpdateUser:  createUserID.(uint),
			}
			if err := sc.DB.Create(&newSetting).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建设置失败"})
				return
			}
			c.JSON(http.StatusOK, gin.H{"code": 200, "message": "设置创建成功", "data": newSetting})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取设置失败"})
		return
	}

	// 更新现有记录
	updateUserID, _ := c.Get("user_id")
	updateData := map[string]interface{}{
		"name":        req.Name,
		"address":     req.Address,
		"phone":       req.Phone,
		"description": req.Description,
		"logo":        req.Logo,
		"is_open":     req.IsOpen, // Added field
		"update_user": updateUserID.(uint),
	}

	if err := sc.DB.Model(&setting).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新设置失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "设置更新成功", "data": setting})
}
