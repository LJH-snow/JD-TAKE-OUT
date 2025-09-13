package controllers

import (
	"jd-take-out-backend/internal/models"
	"net/http"
	"strconv"
	"time"

	"jd-take-out-backend/pkg/utils"

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
	Status   []int  `form:"status[]"`
	Number   string `form:"number"`
	Phone    string `form:"phone"`
	DateFrom string `form:"date_from"`
	DateTo   string `form:"date_to"`
}

// UpdateOrderStatusRequest 更新订单状态请求
type UpdateOrderStatusRequest struct {
	Status int `json:"status" binding:"required,oneof=3 4 5 6"` // 3:已接单 4:派送中 5:已完成 6:已取消
}

// SubmitOrderRequest 提交订单请求
type SubmitOrderRequest struct {
	AddressBookID uint   `json:"address_book_id" binding:"required"`
	PayMethod     int    `json:"pay_method" binding:"required,oneof=1 2"` // 1:微信支付 2:支付宝
	Remark        string `json:"remark"`
	TablewareNumber int  `json:"tableware_number"` // 餐具数量
}

// ListOrders 获取订单分页列表
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
	if len(req.Status) > 0 {
		db = db.Where("status IN (?)", req.Status)
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
	}

	if err := oc.DB.Model(&order).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新订单状态失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}

// SubmitOrder 提交订单
func (oc *OrderController) SubmitOrder(c *gin.Context) {
	var req SubmitOrderRequest
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

	// 1. 获取用户购物车数据
	var shoppingCartItems []models.ShoppingCart
	if err := oc.DB.Where("user_id = ?", userID).Find(&shoppingCartItems).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取购物车失败"})
		return
	}
	if len(shoppingCartItems) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "购物车为空，无法提交订单"})
		return
	}

	// 2. 验证收货地址
	var addressBook models.AddressBook
	if err := oc.DB.Where("id = ? AND user_id = ?", req.AddressBookID, userID).First(&addressBook).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "收货地址不存在或不属于当前用户"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询收货地址失败"})
		return
	}

	// 3. 计算订单总金额
	var totalAmount float64
	for _, item := range shoppingCartItems {
		totalAmount += item.Amount * float64(item.Number)
	}

	// 4. 生成订单号
	orderNumber := time.Now().Format("20060102150405") + strconv.Itoa(int(userID)) + strconv.Itoa(int(time.Now().UnixNano()%10000))

	// 5. 开启数据库事务
	tx := oc.DB.Begin()
	if tx.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "开启事务失败"})
		return
	}

	// 6. 创建订单
	order := models.Order{
		Number:        orderNumber,
		Status:        models.OrderStatusPending, // 待付款
		UserID:        userID,
		AddressBookID: req.AddressBookID,
		OrderTime:     time.Now(),
		PayMethod:     req.PayMethod,
		PayStatus:     models.PayStatusUnpaid, // 默认未支付
		Amount:        totalAmount,
		Remark:        req.Remark,
		Phone:         addressBook.Phone,
		Address:       addressBook.Detail, // 简化处理，实际可能需要拼接完整地址
		UserName:      userClaims.Username, // 从claims获取用户名
		Consignee:     addressBook.Consignee,
		TablewareNumber: req.TablewareNumber,
		TablewareStatus: 1, // 默认1
	}

	if err := tx.Create(&order).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建订单失败"})
		return
	}

	// 7. 创建订单明细
	var orderDetails []models.OrderDetail
	for _, item := range shoppingCartItems {
		orderDetail := models.OrderDetail{
			Name:       item.Name,
			Image:      item.Image,
			OrderID:    order.ID,
			DishID:     item.DishID,
			SetmealID:  item.SetmealID,
			DishFlavor: item.DishFlavor,
			Number:     item.Number,
			Amount:     item.Amount,
			CreatedAt:  time.Now(),
		}
		orderDetails = append(orderDetails, orderDetail)
	}

	if err := tx.Create(&orderDetails).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建订单明细失败"})
		return
	}

	// 8. 清空购物车
	if err := tx.Where("user_id = ?", userID).Delete(&models.ShoppingCart{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "清空购物车失败"})
		return
	}

	// 9. 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "提交事务失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "订单提交成功", "data": gin.H{"order_id": order.ID, "order_number": order.Number, "amount": order.Amount}})
}

// ListUserOrders 获取用户订单分页列表
func (oc *OrderController) ListUserOrders(c *gin.Context) {
	var req ListOrdersRequest // Reuse ListOrdersRequest for query parameters
	if err := c.ShouldBindQuery(&req); err != nil {
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

	var orders []models.Order
	var total int64

	db := oc.DB.Model(&models.Order{}).Where("user_id = ?", userID) // Filter by current user ID

	// Apply filters (similar to admin ListOrders)
	if len(req.Status) > 0 {
		db = db.Where("status IN (?)", req.Status)
	}
	if req.Number != "" {
		db = db.Where("number LIKE ?", "%"+req.Number+"%")
	}
	// Note: req.Phone is not used here as we filter by user_id
	if req.DateFrom != "" && req.DateTo != "" {
		db = db.Where("order_time BETWEEN ? AND ?", req.DateFrom+" 00:00:00", req.DateTo+" 23:59:59")
	}

	// Get total count
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取订单总数失败"})
		return
	}

	// Get paginated data
	offset := (req.Page - 1) * req.PageSize
	err := db.Preload("OrderDetails").Order("order_time DESC").Offset(offset).Limit(req.PageSize).Find(&orders).Error // Preload OrderDetails
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

// ExportOrders 导出订单数据
func (oc *OrderController) ExportOrders(c *gin.Context) {
	format := c.DefaultQuery("format", "xlsx")

	var req ListOrdersRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	var orders []models.Order
	db := oc.DB.Model(&models.Order{})

	// 应用与列表页完全相同的筛选逻辑
	if len(req.Status) > 0 {
		db = db.Where("status IN (?)", req.Status)
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

	// 导出时获取所有符合条件的记录，不分页
	err := db.Preload("User").Order("order_time DESC").Find(&orders).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取订单列表失败"})
		return
	}

	// 根据格式生成文件
	if format == "xlsx" {
		oc.exportExcel(c, orders)
	} else if format == "csv" {
		oc.exportCSV(c, orders)
	} else {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "不支持的导出格式"})
	}
}

// exportExcel 生成并写入Excel文件流
func (oc *OrderController) exportExcel(c *gin.Context, orders []models.Order) {
    // ... function body
}

// exportCSV 生成并写入CSV文件流
func (oc *OrderController) exportCSV(c *gin.Context, orders []models.Order) {
    // ... function body
}

// --- MVP API IMPLEMENTATIONS ---

// GetUserOrderByID 获取单个订单详情(用户端)
func (oc *OrderController) GetUserOrderByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, _ := c.Get("claims")
	userID := claims.(*utils.Claims).UserID

	var order models.Order
	err = oc.DB.Preload("OrderDetails").Where("id = ? AND user_id = ?", id, userID).First(&order).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到或不属于当前用户"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "data": order})
}

// CancelOrder 用户取消订单
func (oc *OrderController) CancelOrder(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, _ := c.Get("claims")
	userID := claims.(*utils.Claims).UserID

	var order models.Order
	if err := oc.DB.Where("id = ? AND user_id = ?", id, userID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到"})
		return
	}

	if order.Status != models.OrderStatusPending {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "只有待付款的订单才能取消"})
		return
	}

	updateData := map[string]interface{}{
		"status":      models.OrderStatusCancelled,
		"cancel_time": time.Now(),
		"cancel_reason": "用户自行取消",
	}

	if err := oc.DB.Model(&order).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "取消订单失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "订单已取消"})
}

// ConfirmOrder 用户确认收货
func (oc *OrderController) ConfirmOrder(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, _ := c.Get("claims")
	userID := claims.(*utils.Claims).UserID

	var order models.Order
	if err := oc.DB.Where("id = ? AND user_id = ?", id, userID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到"})
		return
	}

	if order.Status != models.OrderStatusDelivering {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "只有派送中的订单才能确认收货"})
		return
	}

	updateData := map[string]interface{}{
		"status":        models.OrderStatusCompleted,
		"delivery_time": time.Now(),
	}

	if err := oc.DB.Model(&order).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "确认收货失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "操作成功"})
}