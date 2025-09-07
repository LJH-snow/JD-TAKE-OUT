package controllers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
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

// GetDashboardOverview 获取工作台概览数据
func (sc *StatsController) GetDashboardOverview(c *gin.Context) {
	startDate := c.DefaultQuery("start", time.Now().Format("2006-01-02"))
	// endDate := c.DefaultQuery("end", time.Now().Format("2006-01-02"))

	// 查询今日数据
	var todayStats struct {
		TotalRevenue float64 `json:"total_revenue"`
		ValidOrders  int64   `json:"valid_orders"`
		NewUsers     int64   `json:"new_users"`
	}

	// 查询今日完成订单的营业额和数量
	err := sc.DB.Raw(`
		SELECT 
			COALESCE(SUM(amount), 0) as total_revenue,
			COUNT(*) as valid_orders
		FROM orders 
		WHERE DATE(order_time) = ? AND status = 5
	`, startDate).Scan(&todayStats).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "查询今日数据失败",
		})
		return
	}

	// 查询今日新增用户
	sc.DB.Raw(`
		SELECT COUNT(*) as new_users
		FROM users 
		WHERE DATE(created_at) = ?
	`, startDate).Scan(&todayStats.NewUsers)

	// 查询昨日数据用于计算环比
	yesterday := time.Now().AddDate(0, 0, -1).Format("2006-01-02")
	var yesterdayStats struct {
		TotalRevenue float64 `json:"total_revenue"`
		ValidOrders  int64   `json:"valid_orders"`
		NewUsers     int64   `json:"new_users"`
	}

	// 查询昨日数据
	sc.DB.Raw(`
		SELECT 
			COALESCE(SUM(amount), 0) as total_revenue,
			COUNT(*) as valid_orders
		FROM orders 
		WHERE DATE(order_time) = ? AND status = 5
	`, yesterday).Scan(&yesterdayStats)

	sc.DB.Raw(`
		SELECT COUNT(*) as new_users
		FROM users 
		WHERE DATE(created_at) = ?
	`, yesterday).Scan(&yesterdayStats.NewUsers)

	// 计算总订单完成率
	var totalOrders, completedOrders int64
	sc.DB.Raw(`
		SELECT 
			COUNT(*) as total_orders,
			SUM(CASE WHEN status = 5 THEN 1 ELSE 0 END) as completed_orders
		FROM orders 
		WHERE DATE(order_time) = ?
	`, startDate).Row().Scan(&totalOrders, &completedOrders)

	completionRate := 0.0
	if totalOrders > 0 {
		completionRate = float64(completedOrders) / float64(totalOrders) * 100
	}

	// 计算平均订单金额
	averagePrice := 0.0
	if todayStats.ValidOrders > 0 {
		averagePrice = todayStats.TotalRevenue / float64(todayStats.ValidOrders)
	}

	// 计算环比变化
	revenueChange := 0.0
	if yesterdayStats.TotalRevenue > 0 {
		revenueChange = (todayStats.TotalRevenue - yesterdayStats.TotalRevenue) / yesterdayStats.TotalRevenue * 100
	}

	ordersChange := 0.0
	if yesterdayStats.ValidOrders > 0 {
		ordersChange = float64(todayStats.ValidOrders-yesterdayStats.ValidOrders) / float64(yesterdayStats.ValidOrders) * 100
	}

	usersChange := 0.0
	if yesterdayStats.NewUsers > 0 {
		usersChange = float64(todayStats.NewUsers-yesterdayStats.NewUsers) / float64(yesterdayStats.NewUsers) * 100
	}

	// 昨日完成率用于计算环比
	var yesterdayTotalOrders, yesterdayCompletedOrders int64
	sc.DB.Raw(`
		SELECT 
			COUNT(*) as total_orders,
			SUM(CASE WHEN status = 5 THEN 1 ELSE 0 END) as completed_orders
		FROM orders 
		WHERE DATE(order_time) = ?
	`, yesterday).Row().Scan(&yesterdayTotalOrders, &yesterdayCompletedOrders)

	yesterdayCompletionRate := 0.0
	if yesterdayTotalOrders > 0 {
		yesterdayCompletionRate = float64(yesterdayCompletedOrders) / float64(yesterdayTotalOrders) * 100
	}

	rateChange := 0.0
	if yesterdayCompletionRate > 0 {
		rateChange = (completionRate - yesterdayCompletionRate) / yesterdayCompletionRate * 100
	}

	// 昨日平均价格
	yesterdayAveragePrice := 0.0
	if yesterdayStats.ValidOrders > 0 {
		yesterdayAveragePrice = yesterdayStats.TotalRevenue / float64(yesterdayStats.ValidOrders)
	}

	priceChange := 0.0
	if yesterdayAveragePrice > 0 {
		priceChange = (averagePrice - yesterdayAveragePrice) / yesterdayAveragePrice * 100
	}

	overview := DashboardOverview{
		Date:           startDate,
		TotalRevenue:   todayStats.TotalRevenue,
		RevenueChange:  revenueChange,
		ValidOrders:    int(todayStats.ValidOrders),
		OrdersChange:   ordersChange,
		CompletionRate: completionRate,
		RateChange:     rateChange,
		AveragePrice:   averagePrice,
		PriceChange:    priceChange,
		NewUsers:       int(todayStats.NewUsers),
		UsersChange:    usersChange,
		UpdateTime:     time.Now().Format("2006-01-02 15:04:05"),
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    overview,
		"message": "获取成功",
	})
}

// GetSalesTrend 获取销售趋势数据
func (sc *StatsController) GetSalesTrend(c *gin.Context) {
	startDate := c.Query("start")
	endDate := c.Query("end")

	if startDate == "" || endDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "开始日期和结束日期不能为空",
		})
		return
	}

	// 从数据库查询真实销售数据
	var salesData []SalesTrendData
	err := sc.DB.Raw(`
		SELECT 
			DATE(order_time) as date,
			COALESCE(SUM(amount), 0) as revenue,
			COUNT(*) as orders,
			COUNT(DISTINCT user_id) as customers
		FROM orders 
		WHERE DATE(order_time) BETWEEN ? AND ? 
			AND status = 5
		GROUP BY DATE(order_time)
		ORDER BY date ASC
	`, startDate, endDate).Scan(&salesData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "查询销售数据失败",
		})
		return
	}

	// 计算每日增长率
	for i := range salesData {
		if i == 0 {
			salesData[i].Growth = 0 // 第一天无增长率
		} else {
			prevRevenue := salesData[i-1].Revenue
			if prevRevenue > 0 {
				salesData[i].Growth = (salesData[i].Revenue - prevRevenue) / prevRevenue * 100
			} else {
				salesData[i].Growth = 0
			}
		}

		// 格式化日期为字符串
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
	startDate := c.Query("start")
	endDate := c.Query("end")
	category := c.DefaultQuery("category", "all")
	_ = c.DefaultQuery("sort", "quantity") // 暂时不使用
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if startDate == "" || endDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "开始日期和结束日期不能为空",
		})
		return
	}

	// 从数据库查询真实菜品排行数据
	var dishData []DishRankingData
	sql := `
		SELECT 
			d.id as dish_id,
			od.name,
			c.name as category,
			SUM(od.number) as quantity,
			SUM(od.amount) as revenue,
			d.price,
			0 as growth,
			ROW_NUMBER() OVER (ORDER BY SUM(od.number) DESC) as rank
		FROM order_details od
		JOIN orders o ON od.order_id = o.id
		JOIN dishes d ON od.dish_id = d.id
		JOIN categories c ON d.category_id = c.id
		WHERE DATE(o.order_time) BETWEEN ? AND ? 
			AND o.status = 5 
			AND od.dish_id IS NOT NULL
	`

	args := []interface{}{startDate, endDate}

	// 按分类筛选
	if category != "all" {
		sql += " AND c.name = ?"
		args = append(args, category)
	}

	sql += `
		GROUP BY d.id, od.name, c.name, d.price
		ORDER BY quantity DESC
		LIMIT ?
	`
	args = append(args, limit)

	err := sc.DB.Raw(sql, args...).Scan(&dishData).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "查询菜品数据失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"data":    dishData,
		"message": "获取成功",
	})
}

// GetCategoryStats 获取分类统计数据
func (sc *StatsController) GetCategoryStats(c *gin.Context) {
	startDate := c.Query("start")
	endDate := c.Query("end")

	if startDate == "" || endDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "开始日期和结束日期不能为空",
		})
		return
	}

	// 从数据库查询真实分类统计数据
	var categoryData []CategoryStatsData
	err := sc.DB.Raw(`
		SELECT 
			c.name as category,
			SUM(od.amount) as revenue,
			SUM(od.number) as quantity,
			0 as percentage,
			0 as growth
		FROM order_details od
		JOIN orders o ON od.order_id = o.id
		JOIN dishes d ON od.dish_id = d.id
		JOIN categories c ON d.category_id = c.id
		WHERE DATE(o.order_time) BETWEEN ? AND ? 
			AND o.status = 5
			AND od.dish_id IS NOT NULL
		GROUP BY c.id, c.name
		ORDER BY revenue DESC
	`, startDate, endDate).Scan(&categoryData).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "查询分类数据失败",
		})
		return
	}

	// 计算百分比
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

// ExportData 导出数据
func (sc *StatsController) ExportData(c *gin.Context) {
	// TODO: 实现数据导出逻辑
	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "导出功能开发中",
		"data": gin.H{
			"download_url": "/downloads/sample.xlsx",
			"file_name":    "statistics_" + time.Now().Format("20060102") + ".xlsx",
			"expires_at":   time.Now().Add(24 * time.Hour).Format("2006-01-02 15:04:05"),
		},
	})
}
