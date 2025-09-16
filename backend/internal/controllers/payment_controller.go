package controllers

import (
	"encoding/json"
	"fmt"
	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/internal/websocket"
	"jd-take-out-backend/pkg/utils"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type PaymentController struct {
	DB *gorm.DB
}

func NewPaymentController(db *gorm.DB) *PaymentController {
	return &PaymentController{
		DB: db,
	}
}

// PayRequest 模拟支付请求
type PayRequest struct {
	OrderNumber string `json:"order_number" binding:"required"` // 订单号
	PayMethod   int    `json:"pay_method" binding:"required"`   // 支付方式 1:微信 2:支付宝
}

// PayOrder 模拟支付
func (pc *PaymentController) PayOrder(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)

	var req PayRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "请求参数错误"})
		return
	}

	// 查询订单
	var order models.Order
	if err := pc.DB.Where("number = ? AND user_id = ?", req.OrderNumber, userClaims.UserID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单不存在"})
		return
	}

	// 检查订单状态
	if order.Status != models.OrderStatusPending {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "订单状态不允许支付"})
		return
	}

	// 模拟支付成功
	now := time.Now()
	order.Status = models.OrderStatusWaiting
	order.PayStatus = models.PayStatusPaid
	order.PayMethod = req.PayMethod
	order.PayTime = &now
	order.CheckoutTime = &now
	order.AlipayOrderNo = fmt.Sprintf("MOCK-%s", order.Number) // 模拟一个外部订单号

	if err := pc.DB.Save(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "订单状态更新失败"})
		return
	}

	// 广播新订单通知
	notification := map[string]interface{}{
		"type":    "new_order",
		"payload": gin.H{
			"order_id": order.ID,
			"message":  "您有一个订单等待处理",
		},
	}
	message, _ := json.Marshal(notification)
	websocket.HubInstance.Broadcast(message)

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "模拟支付成功",
	})
}

// QueryPaymentStatus 查询支付状态
func (pc *PaymentController) QueryPaymentStatus(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)

	orderIDStr := c.Param("id")
	orderID, err := strconv.Atoi(orderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的订单ID"})
		return
	}

	// 查询订单
	var order models.Order
	if err := pc.DB.Where("id = ? AND user_id = ?", orderID, userClaims.UserID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "查询成功",
		"data": gin.H{
			"order_id":   order.ID,
			"pay_status": order.PayStatus,
			"status":     order.Status,
			"pay_time":   order.PayTime,
		},
	})
}
