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

// AdminListOrdersRequest 管理员/员工列表请求参数 (针对单个状态筛选)
type AdminListOrdersRequest struct {
	Page     int    `form:"page,default=1"`
	PageSize int    `form:"pageSize,default=10"`
	Status   int    `form:"status"` // Changed to single int
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
	AddressBookID   uint   `json:"address_book_id" binding:"required"`
	PayMethod       int    `json:"pay_method" binding:"required,oneof=1 2"` // 1:微信支付 2:支付宝
	Remark          string `json:"remark"`
	TablewareNumber int    `json:"tableware_number"` // 餐具数量
}

// ListOrders 获取订单分页列表
func (oc *OrderController) ListOrders(c *gin.Context) {
	var req AdminListOrdersRequest
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
		Number:          orderNumber,
		Status:          models.OrderStatusPending, // 待付款
		UserID:          userID,
		AddressBookID:   req.AddressBookID,
		OrderTime:       time.Now(),
		PayMethod:       req.PayMethod,
		PayStatus:       models.PayStatusUnpaid, // 默认未支付
		Amount:          totalAmount,
		Remark:          req.Remark,
		Phone:           addressBook.Phone,
		Address:         addressBook.Detail,  // 简化处理，实际可能需要拼接完整地址
		UserName:        userClaims.Username, // 从claims获取用户名
		Consignee:       addressBook.Consignee,
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
		"status":        models.OrderStatusCancelled,
		"cancel_time":   time.Now(),
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

// DeleteOrderByAdmin 管理端软删除订单
func (oc *OrderController) DeleteOrderByAdmin(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}
	if err := oc.DB.Delete(&models.Order{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除订单失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "删除成功"})
}

// DeleteOrderByUser 用户删除自己的订单（仅限已完成/已取消）
func (oc *OrderController) DeleteOrderByUser(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, _ := c.Get("claims")
	userID := claims.(*utils.Claims).UserID

	var order models.Order
	// 先按ID查询，便于区分“不存在/已删除”与“非本人订单”
	if err := oc.DB.First(&order, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "订单未找到或已删除"})
		return
	}

	if order.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "该订单不属于当前用户，无法删除"})
		return
	}

	if order.Status != models.OrderStatusCompleted && order.Status != models.OrderStatusCancelled {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "仅支持删除已完成或已取消的订单"})
		return
	}

	if err := oc.DB.Delete(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除订单失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "删除成功"})
}

// GetUserOrderStatusCounts 获取当前用户按状态分组的订单数量
func (oc *OrderController) GetUserOrderStatusCounts(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)

	type CountRow struct {
		Status int   `json:"status"`
		Count  int64 `json:"count"`
	}

	var rows []CountRow
	if err := oc.DB.Table("orders").
		Select("status, COUNT(*) as count").
		Where("user_id = ?", userClaims.UserID).
		Group("status").
		Find(&rows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "统计订单数量失败"})
		return
	}

	counts := map[string]int64{
		"pending":    0,
		"waiting":    0,
		"confirmed":  0,
		"delivering": 0,
		"completed":  0,
		"cancelled":  0,
		"refunded":   0,
		"all":        0,
	}

	var total int64 = 0
	for _, r := range rows {
		total += r.Count
		switch r.Status {
		case models.OrderStatusPending:
			counts["pending"] = r.Count
		case models.OrderStatusWaiting:
			counts["waiting"] = r.Count
		case models.OrderStatusConfirmed:
			counts["confirmed"] = r.Count
		case models.OrderStatusDelivering:
			counts["delivering"] = r.Count
		case models.OrderStatusCompleted:
			counts["completed"] = r.Count
		case models.OrderStatusCancelled:
			counts["cancelled"] = r.Count
		case models.OrderStatusRefunded:
			counts["refunded"] = r.Count
		}
	}
	counts["all"] = total

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    counts,
	})
}

// GetUserOrderStats 获取当前用户在日期范围内的订单统计
// 返回总金额、订单数以及每日聚合数据
func (oc *OrderController) GetUserOrderStats(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)

	dateFrom := c.DefaultQuery("date_from", "")
	dateTo := c.DefaultQuery("date_to", "")

	type StatRow struct {
		SaleDate    string  `json:"date"`
		OrderCount  int64   `json:"order_count"`
		TotalAmount float64 `json:"amount"`
	}

	// 构建基础查询
	db := oc.DB.Table("orders").
		Select("DATE(order_time) as sale_date, COUNT(*) as order_count, SUM(amount) as total_amount").
		Where("user_id = ?", userClaims.UserID).
		Where("pay_status = ?", models.PayStatusPaid)

	if dateFrom != "" && dateTo != "" {
		db = db.Where("order_time BETWEEN ? AND ?", dateFrom+" 00:00:00", dateTo+" 23:59:59")
	}

	db = db.Group("DATE(order_time)").Order("sale_date ASC")

	var rows []StatRow
	if err := db.Find(&rows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "统计查询失败"})
		return
	}

	var totalAmount float64 = 0
	var orderCount int64 = 0
	for _, r := range rows {
		totalAmount += r.TotalAmount
		orderCount += r.OrderCount
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"total_amount": totalAmount,
			"order_count":  orderCount,
			"daily":        rows,
		},
	})
}
