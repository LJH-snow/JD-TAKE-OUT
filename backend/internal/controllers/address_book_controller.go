package controllers

import (
	"net/http"
	"strconv"
	"time"

	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// AddressBookController 地址簿控制器
type AddressBookController struct {
	DB *gorm.DB
}

// AddAddressBookRequest 添加地址簿请求体
type AddAddressBookRequest struct {
	Consignee    string  `json:"consignee" binding:"required"`
	Sex          string  `json:"sex" binding:"required,oneof=0 1"` // 0:女 1:男
	Phone        string  `json:"phone" binding:"required"`
	Detail       string  `json:"detail" binding:"required"`
	Label        string  `json:"label"`
	IsDefault    int     `json:"is_default"` // 0:非默认 1:默认
	ProvinceCode string  `json:"province_code"`
	ProvinceName string  `json:"province_name"`
	CityCode     string  `json:"city_code"`
	CityName     string  `json:"city_name"`
	DistrictCode string  `json:"district_code"`
	DistrictName string  `json:"district_name"`
	Longitude    float64 `json:"longitude"`
	Latitude     float64 `json:"latitude"`
	FormattedAddress string `json:"formatted_address"`
}

// UpdateAddressBookRequest 更新地址簿请求体
type UpdateAddressBookRequest struct {
	Consignee    string  `json:"consignee" binding:"required"`
	Sex          string  `json:"sex" binding:"required,oneof=0 1"` // 0:女 1:男
	Phone        string  `json:"phone" binding:"required"`
	Detail       string  `json:"detail" binding:"required"`
	Label        string  `json:"label"`
	IsDefault    int     `json:"is_default"` // 0:非默认 1:默认
	ProvinceCode string  `json:"province_code"`
	ProvinceName string  `json:"province_name"`
	CityCode     string  `json:"city_code"`
	CityName     string  `json:"city_name"`
	DistrictCode string  `json:"district_code"`
	DistrictName string  `json:"district_name"`
	Longitude    float64 `json:"longitude"`
	Latitude     float64 `json:"latitude"`
	FormattedAddress string `json:"formatted_address"`
}

// ListAddressBooks 获取地址簿列表
// @Summary      获取地址簿列表
// @Description  获取当前用户的所有地址簿记录
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "获取成功"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook [get]
func (abc *AddressBookController) ListAddressBooks(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var addressBooks []models.AddressBook
	if err := abc.DB.Where("user_id = ?", userID).Order("is_default DESC, updated_at DESC").Find(&addressBooks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取地址簿失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "获取成功", "data": addressBooks})
}

// GetAddressBookByID 获取单个地址簿记录
// @Summary      获取单个地址簿记录
// @Description  根据ID获取当前用户的单个地址簿记录
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "地址簿ID"
// @Success      200  {object}  map[string]interface{}  "获取成功"
// @Failure      400  {object}  map[string]interface{}  "无效的ID格式"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "地址簿记录不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook/{id} [get]
func (abc *AddressBookController) GetAddressBookByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var addressBook models.AddressBook
	if err := abc.DB.Where("id = ? AND user_id = ?", id, userID).First(&addressBook).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "地址簿记录不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询地址簿失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "获取成功", "data": addressBook})
}

// AddAddressBook 添加地址簿记录
// @Summary      添加地址簿记录
// @Description  为当前用户添加新的地址簿记录
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body AddAddressBookRequest true "添加地址簿请求参数"
// @Success      200  {object}  map[string]interface{}  "添加成功"
// @Failure      400  {object}  map[string]interface{}  "请求参数错误"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook [post]
func (abc *AddressBookController) AddAddressBook(c *gin.Context) {
	var req AddAddressBookRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	// 如果新地址设置为默认，则将该用户其他所有地址设置为非默认
	if req.IsDefault == 1 {
		if err := abc.DB.Model(&models.AddressBook{}).Where("user_id = ?", userID).Update("is_default", 0).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新默认地址失败"})
			return
		}
	}

	addressBook := models.AddressBook{
		UserID:           userID,
		Consignee:        req.Consignee,
		Sex:              req.Sex,
		Phone:            req.Phone,
		ProvinceCode:     req.ProvinceCode,
		ProvinceName:     req.ProvinceName,
		CityCode:         req.CityCode,
		CityName:         req.CityName,
		DistrictCode:     req.DistrictCode,
		DistrictName:     req.DistrictName,
		Detail:           req.Detail,
		Label:            req.Label,
		IsDefault:        req.IsDefault,
		Longitude:        req.Longitude,
		Latitude:         req.Latitude,
		FormattedAddress: req.FormattedAddress,
		CreatedAt:        time.Now(),
		UpdatedAt:        time.Now(),
	}

	if err := abc.DB.Create(&addressBook).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "添加地址簿失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "添加成功", "data": addressBook})
}

// UpdateAddressBook 更新地址簿记录
// @Summary      更新地址簿记录
// @Description  更新当前用户的地址簿记录
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "地址簿ID"
// @Param        body body UpdateAddressBookRequest true "更新地址簿请求参数"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Failure      400  {object}  map[string]interface{}  "请求参数错误"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "地址簿记录不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook/{id} [put]
func (abc *AddressBookController) UpdateAddressBook(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var req UpdateAddressBookRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var addressBook models.AddressBook
	if err := abc.DB.Where("id = ? AND user_id = ?", id, userID).First(&addressBook).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "地址簿记录不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询地址簿失败"})
		return
	}

	// 如果新地址设置为默认，则将该用户其他所有地址设置为非默认
	if req.IsDefault == 1 {
		if err := abc.DB.Model(&models.AddressBook{}).Where("user_id = ? AND id != ?", userID, id).Update("is_default", 0).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新默认地址失败"})
			return
		}
	}

	// 更新地址簿字段
	updateData := map[string]interface{}{
		"consignee":        req.Consignee,
		"sex":              req.Sex,
		"phone":            req.Phone,
		"province_code":    req.ProvinceCode,
		"province_name":    req.ProvinceName,
		"city_code":        req.CityCode,
		"city_name":        req.CityName,
		"district_code":    req.DistrictCode,
		"district_name":    req.DistrictName,
		"detail":           req.Detail,
		"label":            req.Label,
		"is_default":       req.IsDefault,
		"longitude":        req.Longitude,
		"latitude":         req.Latitude,
		"formatted_address": req.FormattedAddress,
		"updated_at":       time.Now(),
	}

	if err := abc.DB.Model(&addressBook).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新地址簿失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功", "data": addressBook})
}

// DeleteAddressBook 删除地址簿记录
// @Summary      删除地址簿记录
// @Description  删除当前用户的地址簿记录
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "地址簿ID"
// @Success      200  {object}  map[string]interface{}  "删除成功"
// @Failure      400  {object}  map[string]interface{}  "无效的ID格式"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "地址簿记录不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook/{id} [delete]
func (abc *AddressBookController) DeleteAddressBook(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var addressBook models.AddressBook
	if err := abc.DB.Where("id = ? AND user_id = ?", id, userID).First(&addressBook).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "地址簿记录不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询地址簿失败"})
		return
	}

	if err := abc.DB.Delete(&addressBook).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除地址簿失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "删除成功"})
}

// SetDefaultAddressBook 设置默认地址
// @Summary      设置默认地址
// @Description  将指定地址设置为当前用户的默认地址
// @Tags         地址簿
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "地址簿ID"
// @Success      200  {object}  map[string]interface{}  "设置成功"
// @Failure      400  {object}  map[string]interface{}  "无效的ID格式"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "地址簿记录不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/addressBook/default/{id} [put]
func (abc *AddressBookController) SetDefaultAddressBook(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	// 开启事务
	tx := abc.DB.Begin()
	if tx.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "开启事务失败"})
		return
	}

	// 1. 将该用户所有地址设置为非默认
	if err := tx.Model(&models.AddressBook{}).Where("user_id = ?", userID).Update("is_default", 0).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新默认地址失败"})
		return
	}

	// 2. 将指定地址设置为默认
	var addressBook models.AddressBook
	if err := tx.Where("id = ? AND user_id = ?", id, userID).First(&addressBook).Error; err != nil {
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "地址簿记录不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询地址簿失败"})
		return
	}

	if err := tx.Model(&addressBook).Update("is_default", 1).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "设置默认地址失败"})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "提交事务失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "设置成功"})
}
