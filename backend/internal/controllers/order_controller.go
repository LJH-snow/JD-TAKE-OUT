package controllers

import (
	"net/http"
	"strconv"
	"time"

	"jd-take-out-backend/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// OrderController 订单控制器
type OrderController struct {
	DB *gorm.DB
}

// ListOrdersRequest 列表请求参数
type ListOrdersRequest struct {
	Page     int    `form:"page,default=1"`
	PageSize int    `form:"pageSize,default=10"`
	Status   int    `form:"status"`
	Number   string `form:"number"`
	Phone    string `form:"phone"`
	DateFrom string `form:"date_from"`
	DateTo   string `form:"date_to"`
}

// UpdateOrderStatusRequest 更新订单状态请求
type UpdateOrderStatusRequest struct {
	Status int `json:"status" binding:"required,oneof=3 4 5 6"` // 3:已接单 4:派送中 5:已完成 6:已取消
}

// ListOrders 获取订单分页列表
// @Summary      获取订单分页列表
// @Description  根据分页和筛选条件获取订单列表
// @Tags         订单管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        page      query    int     false  "页码"
// @Param        pageSize  query    int     false  "每页数量"
// @Param        status    query    int     false  "订单状态"
// @Param        number    query    string  false  "订单号"
// @Param        phone     query    string  false  "用户手机号"
// @Param        date_from query    string  false  "开始日期 (YYYY-MM-DD)"
// @Param        date_to   query    string  false  "结束日期 (YYYY-MM-DD)"
// @Success      200       {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/orders [get]
func (oc *OrderController) ListOrders(c *gin.Context) {
	var req ListOrdersRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	var orders []models.Order
	var total int64

	db := oc.DB.Model(&models.Order{})

	// 应用筛选
	if req.Status > 0 {
		db = db.Where("status = ?", req.Status)
	}
	if req.Number != "" {
		db = db.Where("number LIKE ?", "%"+req.Number+"%")
	}
	if req.Phone != "" {
		db = db.Where("phone LIKE ?", "%"+req.Phone+"%")
	}
	if req.DateFrom != "" && req.DateTo != "" {
		db = db.Where("order_time BETWEEN ? AND ?", req.DateFrom+" 00:00:00", req.DateTo+" 23:59:59")
	}

	// 获取总数
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取订单总数失败"})
		return
	}

	// 获取分页数据
	offset := (req.Page - 1) * req.PageSize
	err := db.Preload("User").Order("order_time DESC").Offset(offset).Limit(req.PageSize).Find(&orders).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取订单列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"items": orders,
			"total": total,
		},
	})
}

// GetOrderByID 获取单个订单详情
// @Summary      获取订单详情
// @Description  根据ID获取单个订单的完整信息，包括订单明细
// @Tags         订单管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "订单ID"
// @Success      200  {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/orders/{id} [get]
func (oc *OrderController) GetOrderByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var order models.Order
	err = oc.DB.Preload("User").Preload("AddressBook").Preload("OrderDetails").First(&order, id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "data": order})
}

// UpdateOrderStatus 更新订单状态
// @Summary      更新订单状态
// @Description  更新指定ID的订单状态（如：接单、派送、完成、取消）
// @Tags         订单管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "订单ID"
// @Param        body body      UpdateOrderStatusRequest  true   "新的订单状态"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Router       /api/v1/admin/orders/{id}/status [put]
func (oc *OrderController) UpdateOrderStatus(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	var req UpdateOrderStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var order models.Order
	if err := oc.DB.First(&order, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到"})
		return
	}

	// 更新状态和相应的时间
	updateData := map[string]interface{}{"status": req.Status}
	if req.Status == models.OrderStatusCompleted {
		updateData["delivery_time"] = time.Now()
	} else if req.Status == models.OrderStatusCancelled {
		updateData["cancel_time"] = time.Now()
		// 可在此处添加取消原因
		// updateData["cancel_reason"] = "商家取消"
	}

	if err := oc.DB.Model(&order).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新订单状态失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}
