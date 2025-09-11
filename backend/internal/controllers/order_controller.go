package controllers

import (
	"encoding/csv"
	"fmt"
	"jd-take-out-backend/internal/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"
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

// ExportOrders 导出订单数据
// @Summary      导出订单
// @Description  根据筛选条件导出订单数据为Excel或CSV文件
// @Tags         订单管理
// @Accept       json
// @Produce      application/octet-stream
// @Security     BearerAuth
// @Param        format    query    string  true   "导出格式 (xlsx or csv)"
// @Param        status    query    int     false  "订单状态"
// @Param        number    query    string  false  "订单号"
// @Param        phone     query    string  false  "用户手机号"
// @Param        date_from query    string  false  "开始日期 (YYYY-MM-DD)"
// @Param        date_to   query    string  false  "结束日期 (YYYY-MM-DD)"
// @Success      200       {file}    binary  "文件流"
// @Router       /api/v1/admin/orders/export [get]
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
	f := excelize.NewFile()
	streamWriter, err := f.NewStreamWriter("Sheet1")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": err.Error()})
		return
	}

	// 设置表头样式
	style, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true}})
	headers := []interface{}{"订单号", "下单用户", "手机号", "订单金额", "订单状态", "下单时间", "收货地址"}
	if err := streamWriter.SetRow("A1", headers, excelize.RowOpts{StyleID: style}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": err.Error()})
		return
	}

	// 写入数据行
	for i, order := range orders {
		row := []interface{}{
			order.Number,
			order.User.Name,
			order.Phone,
			order.Amount,
			order.GetStatusText(),
			order.OrderTime.Format("2006-01-02 15:04:05"),
			order.Address,
		}
		if err := streamWriter.SetRow(fmt.Sprintf("A%d", i+2), row); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": err.Error()})
			return
		}
	}

	if err := streamWriter.Flush(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": err.Error()})
		return
	}

	fileName := "orders_" + time.Now().Format("20060102150405") + ".xlsx"
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename="+fileName)
	if err := f.Write(c.Writer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "写入文件流失败"})
	}
}

// exportCSV 生成并写入CSV文件流
func (oc *OrderController) exportCSV(c *gin.Context, orders []models.Order) {
	fileName := "orders_" + time.Now().Format("20060102150405") + ".csv"
	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", "attachment; filename="+fileName)

	// 写入UTF-8 BOM，防止Excel打开乱码
	c.Writer.Write([]byte("\xEF\xBB\xBF"))

	w := csv.NewWriter(c.Writer)

	// 写入表头
	headers := []string{"订单号", "下单用户", "手机号", "订单金额", "订单状态", "下单时间", "收货地址"}
	w.Write(headers)

	// 写入数据行
	for _, order := range orders {
		row := []string{
			order.Number,
			order.User.Name,
			order.Phone,
			fmt.Sprintf("%.2f", order.Amount),
			order.GetStatusText(),
			order.OrderTime.Format("2006-01-02 15:04:05"),
			order.Address,
		}
		w.Write(row)
	}

	w.Flush()
}

// GetStatusText 是一个辅助函数，需要添加到 models.Order 中
// func (o *Order) GetStatusText() string {
// 	switch o.Status {
// 	case 1: return "待付款"
// 	case 2: return "待接单"
// 	case 3: return "已接单"
// 	case 4: return "派送中"
// 	case 5: return "已完成"
// 	case 6: return "已取消"
// 	default: return "未知状态"
// 	}
// }