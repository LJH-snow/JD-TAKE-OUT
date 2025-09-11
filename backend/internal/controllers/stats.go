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

// StatsController 统计控制器
type StatsController struct {
	DB *gorm.DB
}

// DashboardOverview 工作台概览数据
type DashboardOverview struct {
	Date           string  `json:"date"`
	TotalRevenue   float64 `json:"total_revenue"`
	RevenueChange  float64 `json:"revenue_change"`
	ValidOrders    int     `json:"valid_orders"`
	OrdersChange   float64 `json:"orders_change"`
	CompletionRate float64 `json:"completion_rate"`
	RateChange     float64 `json:"rate_change"`
	AveragePrice   float64 `json:"average_price"`
	PriceChange    float64 `json:"price_change"`
	NewUsers       int     `json:"new_users"`
	UsersChange    float64 `json:"users_change"`
	UpdateTime     string  `json:"update_time"`
}

// SalesTrendData 销售趋势数据
type SalesTrendData struct {
	Date      string  `json:"date"`
	Revenue   float64 `json:"revenue"`
	Orders    int     `json:"orders"`
	Customers int     `json:"customers"`
	Growth    float64 `json:"growth"`
}

// DishRankingData 菜品排行数据
type DishRankingData struct {
	DishID   int     `json:"dish_id"`
	Name     string  `json:"name"`
	Category string  `json:"category"`
	Quantity int     `json:"quantity"`
	Revenue  float64 `json:"revenue"`
	Price    float64 `json:"price"`
	Growth   float64 `json:"growth"`
	Rank     int     `json:"rank"`
}

// CategoryStatsData 分类统计数据
type CategoryStatsData struct {
	Category   string  `json:"category"`
	Revenue    float64 `json:"revenue"`
	Quantity   int     `json:"quantity"`
	Percentage float64 `json:"percentage"`
	Growth     float64 `json:"growth"`
}

// parseDates is a helper function to parse and set the time for date strings
func parseDates(startDateStr, endDateStr string) (time.Time, time.Time, error) {
	layout := "2006-01-02"
	startDate, err1 := time.Parse(layout, startDateStr)
	endDate, err2 := time.Parse(layout, endDateStr)

	if err1 != nil || err2 != nil {
		return time.Time{}, time.Time{}, fmt.Errorf("日期格式错误，请使用 YYYY-MM-DD")
	}

	loc, _ := time.LoadLocation("Local")
	startDate = time.Date(startDate.Year(), startDate.Month(), startDate.Day(), 0, 0, 0, 0, loc)
	endDate = time.Date(endDate.Year(), endDate.Month(), endDate.Day(), 23, 59, 59, 0, loc)

	return startDate, endDate, nil
}

// GetDashboardOverview 获取工作台概览数据
func (sc *StatsController) GetDashboardOverview(c *gin.Context) {
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var overviewStats struct {
		TotalRevenue float64 `json:"total_revenue"`
		ValidOrders  int64   `json:"valid_orders"`
	}

	err = sc.DB.Model(&models.Order{}).
		Select("COALESCE(SUM(amount), 0) as total_revenue, COUNT(*) as valid_orders").
		Where("order_time >= ? AND order_time <= ? AND status = ?", startDate, endDate, 5).
		Scan(&overviewStats).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询营业数据失败"})
		return
	}

	var newUsers int64
	sc.DB.Model(&models.User{}).
		Where("created_at >= ? AND created_at <= ?", startDate, endDate).
		Count(&newUsers)

	var totalOrders int64
	sc.DB.Model(&models.Order{}).
		Where("order_time >= ? AND order_time <= ?", startDate, endDate).
		Count(&totalOrders)

	completionRate := 0.0
	if totalOrders > 0 {
		completionRate = float64(overviewStats.ValidOrders) / float64(totalOrders) * 100
	}

	averagePrice := 0.0
	if overviewStats.ValidOrders > 0 {
		averagePrice = overviewStats.TotalRevenue / float64(overviewStats.ValidOrders)
	}

	overview := gin.H{
		"date_range":      fmt.Sprintf("%s to %s", startDate.Format("2006-01-02"), endDate.Format("2006-01-02")),
		"total_revenue":   overviewStats.TotalRevenue,
		"valid_orders":    overviewStats.ValidOrders,
		"completion_rate": completionRate,
		"average_price":   averagePrice,
		"new_users":       newUsers,
		"update_time":     time.Now().Format("2006-01-02 15:04:05"),
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    overview,
		"message": "获取成功",
	})
}

// GetSalesTrend 获取销售趋势数据
func (sc *StatsController) GetSalesTrend(c *gin.Context) {
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var salesData []SalesTrendData
	err = sc.DB.Model(&models.Order{}).
		Select("DATE(order_time) as date, COALESCE(SUM(amount), 0) as revenue, COUNT(*) as orders, COUNT(DISTINCT user_id) as customers").
		Where("order_time >= ? AND order_time <= ? AND status = ?", startDate, endDate, 5).
		Group("DATE(order_time)").
		Order("date ASC").
		Scan(&salesData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询销售数据失败"})
		return
	}

	if salesData == nil {
		salesData = make([]SalesTrendData, 0)
	}

	for i := range salesData {
		if len(salesData[i].Date) >= 10 {
			salesData[i].Date = salesData[i].Date[:10]
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    salesData,
		"message": "获取成功",
	})
}

// GetDishRanking 获取菜品排行数据
func (sc *StatsController) GetDishRanking(c *gin.Context) {
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var dishData []DishRankingData
	err = sc.DB.Table("order_details od").
		Select("d.id as dish_id, od.name, c.name as category, SUM(od.number) as quantity, SUM(od.amount) as revenue, d.price").
		Joins("JOIN orders o ON od.order_id = o.id").
		Joins("JOIN dishes d ON od.dish_id = d.id").
		Joins("JOIN categories c ON d.category_id = c.id").
		Where("o.order_time >= ? AND o.order_time <= ? AND o.status = ? AND od.dish_id IS NOT NULL", startDate, endDate, 5).
		Group("d.id, od.name, c.name, d.price").
		Order("quantity DESC").
		Limit(limit).
		Scan(&dishData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询菜品数据失败"})
		return
	}

	if dishData == nil {
		dishData = make([]DishRankingData, 0)
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    dishData,
		"message": "获取成功",
	})
}

// GetCategoryStats 获取分类统计数据
func (sc *StatsController) GetCategoryStats(c *gin.Context) {
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var categoryData []CategoryStatsData
	err = sc.DB.Table("order_details od").
		Select("c.name as category, SUM(od.amount) as revenue, SUM(od.number) as quantity").
		Joins("JOIN orders o ON od.order_id = o.id").
		Joins("JOIN dishes d ON od.dish_id = d.id").
		Joins("JOIN categories c ON d.category_id = c.id").
		Where("o.order_time >= ? AND o.order_time <= ? AND o.status = ? AND od.dish_id IS NOT NULL", startDate, endDate, 5).
		Group("c.id, c.name").
		Order("revenue DESC").
		Scan(&categoryData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询分类数据失败"})
		return
	}

	if categoryData == nil {
		categoryData = make([]CategoryStatsData, 0)
	}

	var totalRevenue float64
	for _, cat := range categoryData {
		totalRevenue += cat.Revenue
	}

	for i := range categoryData {
		if totalRevenue > 0 {
			categoryData[i].Percentage = categoryData[i].Revenue / totalRevenue * 100
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    categoryData,
		"message": "获取成功",
	})
}

// ExportSalesData 导出销售趋势数据
func (sc *StatsController) ExportSalesData(c *gin.Context) {
	format := c.DefaultQuery("format", "xlsx")
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var salesData []SalesTrendData
	err = sc.DB.Model(&models.Order{}).
		Select("DATE(order_time) as date, COALESCE(SUM(amount), 0) as revenue, COUNT(*) as orders, COUNT(DISTINCT user_id) as customers").
		Where("order_time >= ? AND order_time <= ? AND status = ?", startDate, endDate, 5).
		Group("DATE(order_time)").
		Order("date ASC").
		Scan(&salesData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询销售数据失败"})
		return
	}

	if salesData == nil {
		salesData = make([]SalesTrendData, 0)
	}

	for i := range salesData {
		if len(salesData[i].Date) >= 10 {
			salesData[i].Date = salesData[i].Date[:10]
		}
	}

	if format == "xlsx" {
		sc.exportSalesExcel(c, salesData)
	} else if format == "csv" {
		sc.exportSalesCSV(c, salesData)
	} else {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "不支持的导出格式"})
	}
}

func (sc *StatsController) exportSalesExcel(c *gin.Context, data []SalesTrendData) {
	f := excelize.NewFile()
	streamWriter, _ := f.NewStreamWriter("Sheet1")
	style, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true}})
	headers := []interface{}{"日期", "营业额", "订单数", "顾客数"}
	streamWriter.SetRow("A1", headers, excelize.RowOpts{StyleID: style})

	for i, item := range data {
		row := []interface{}{
			item.Date,
			item.Revenue,
			item.Orders,
			item.Customers,
		}
		streamWriter.SetRow(fmt.Sprintf("A%d", i+2), row)
	}
	streamWriter.Flush()

	fileName := "sales_trend_" + time.Now().Format("20060102") + ".xlsx"
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename="+fileName)
	f.Write(c.Writer)
}

func (sc *StatsController) exportSalesCSV(c *gin.Context, data []SalesTrendData) {
	fileName := "sales_trend_" + time.Now().Format("20060102") + ".csv"
	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", "attachment; filename="+fileName)
	c.Writer.Write([]byte("\xEF\xBB\xBF")) // UTF-8 BOM

	w := csv.NewWriter(c.Writer)
	headers := []string{"日期", "营业额", "订单数", "顾客数"}
	w.Write(headers)

	for _, item := range data {
		row := []string{
			item.Date,
			fmt.Sprintf("%.2f", item.Revenue),
			strconv.Itoa(item.Orders),
			strconv.Itoa(item.Customers),
		}
		w.Write(row)
	}
	w.Flush()
}

// ExportDishRanking 导出菜品排行数据
func (sc *StatsController) ExportDishRanking(c *gin.Context) {
	format := c.DefaultQuery("format", "xlsx")
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var dishData []DishRankingData
	// 导出时获取所有数据，不受limit限制
	err = sc.DB.Table("order_details od").
		Select("d.id as dish_id, od.name, c.name as category, SUM(od.number) as quantity, SUM(od.amount) as revenue, d.price").
		Joins("JOIN orders o ON od.order_id = o.id").
		Joins("JOIN dishes d ON od.dish_id = d.id").
		Joins("JOIN categories c ON d.category_id = c.id").
		Where("o.order_time >= ? AND o.order_time <= ? AND o.status = ? AND od.dish_id IS NOT NULL", startDate, endDate, 5).
		Group("d.id, od.name, c.name, d.price").
		Order("quantity DESC").
		Scan(&dishData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询菜品数据失败"})
		return
	}

	if dishData == nil {
		dishData = make([]DishRankingData, 0)
	}

	if format == "xlsx" {
		f := excelize.NewFile()
		streamWriter, _ := f.NewStreamWriter("Sheet1")
		style, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true}})
		headers := []interface{}{"菜品名称", "所属分类", "销量", "销售额", "单价"}
		streamWriter.SetRow("A1", headers, excelize.RowOpts{StyleID: style})
		for i, item := range dishData {
			row := []interface{}{item.Name, item.Category, item.Quantity, item.Revenue, item.Price}
			streamWriter.SetRow(fmt.Sprintf("A%d", i+2), row)
		}
		streamWriter.Flush()
		fileName := "dish_ranking_" + time.Now().Format("20060102") + ".xlsx"
		c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
		c.Header("Content-Disposition", "attachment; filename="+fileName)
		f.Write(c.Writer)
	} else if format == "csv" {
		fileName := "dish_ranking_" + time.Now().Format("20060102") + ".csv"
		c.Header("Content-Type", "text/csv; charset=utf-8")
		c.Header("Content-Disposition", "attachment; filename="+fileName)
		c.Writer.Write([]byte("\xEF\xBB\xBF"))
		w := csv.NewWriter(c.Writer)
		headers := []string{"菜品名称", "所属分类", "销量", "销售额", "单价"}
		w.Write(headers)
		for _, item := range dishData {
			row := []string{item.Name, item.Category, strconv.Itoa(item.Quantity), fmt.Sprintf("%.2f", item.Revenue), fmt.Sprintf("%.2f", item.Price)}
			w.Write(row)
		}
		w.Flush()
	}
}

// ExportCategoryStats 导出分类统计数据
func (sc *StatsController) ExportCategoryStats(c *gin.Context) {
	format := c.DefaultQuery("format", "xlsx")
	startDateStr := c.Query("start")
	endDateStr := c.Query("end")

	startDate, endDate, err := parseDates(startDateStr, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}

	var categoryData []CategoryStatsData
	err = sc.DB.Table("order_details od").
		Select("c.name as category, SUM(od.amount) as revenue, SUM(od.number) as quantity").
		Joins("JOIN orders o ON od.order_id = o.id").
		Joins("JOIN dishes d ON od.dish_id = d.id").
		Joins("JOIN categories c ON d.category_id = c.id").
		Where("o.order_time >= ? AND o.order_time <= ? AND o.status = ? AND od.dish_id IS NOT NULL", startDate, endDate, 5).
		Group("c.id, c.name").
		Order("revenue DESC").
		Scan(&categoryData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询分类数据失败"})
		return
	}

	if categoryData == nil {
		categoryData = make([]CategoryStatsData, 0)
	}

	var totalRevenue float64
	for _, cat := range categoryData {
		totalRevenue += cat.Revenue
	}

	for i := range categoryData {
		if totalRevenue > 0 {
			categoryData[i].Percentage = categoryData[i].Revenue / totalRevenue * 100
		}
	}

	if format == "xlsx" {
		f := excelize.NewFile()
		streamWriter, _ := f.NewStreamWriter("Sheet1")
		style, _ := f.NewStyle(&excelize.Style{Font: &excelize.Font{Bold: true}})
		headers := []interface{}{"分类名称", "销售额", "销量", "销售额占比(%)"}
		streamWriter.SetRow("A1", headers, excelize.RowOpts{StyleID: style})
		for i, item := range categoryData {
			row := []interface{}{item.Category, item.Revenue, item.Quantity, item.Percentage}
			streamWriter.SetRow(fmt.Sprintf("A%d", i+2), row)
		}
		streamWriter.Flush()
		fileName := "category_stats_" + time.Now().Format("20060102") + ".xlsx"
		c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
		c.Header("Content-Disposition", "attachment; filename="+fileName)
		f.Write(c.Writer)
	} else if format == "csv" {
		fileName := "category_stats_" + time.Now().Format("20060102") + ".csv"
		c.Header("Content-Type", "text/csv; charset=utf-8")
		c.Header("Content-Disposition", "attachment; filename="+fileName)
		c.Writer.Write([]byte("\xEF\xBB\xBF"))
		w := csv.NewWriter(c.Writer)
		headers := []string{"分类名称", "销售额", "销量", "销售额占比(%)"}
		w.Write(headers)
		for _, item := range categoryData {
			row := []string{item.Category, fmt.Sprintf("%.2f", item.Revenue), strconv.Itoa(item.Quantity), fmt.Sprintf("%.2f", item.Percentage)}
			w.Write(row)
		}
		w.Flush()
	}
}

// ExportData 导出数据 (旧的存根，可以删除或重构)
func (sc *StatsController) ExportData(c *gin.Context) {
	// TODO: 实现数据导出逻辑
	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "数据导出功能待实现",
		"data": gin.H{
			"download_url": "/downloads/sample.xlsx",
			"file_name":    "statistics_" + time.Now().Format("20060102") + ".xlsx",
			"expires_at":   time.Now().Add(24 * time.Hour).Format("2006-01-02 15:04:05"),
		},
	})
}