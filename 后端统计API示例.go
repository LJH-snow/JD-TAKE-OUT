// 后端统计API示例代码 (Golang + Gin)

package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// 统计数据结构体
type DashboardStats struct {
	TodaySales    float64 `json:"today_sales"`
	TodayOrders   int     `json:"today_orders"`
	ActiveUsers   int     `json:"active_users"`
	AvgRating     float64 `json:"avg_rating"`
	SalesChange   float64 `json:"sales_change"`
	OrdersChange  float64 `json:"orders_change"`
	UsersChange   float64 `json:"users_change"`
	RatingChange  float64 `json:"rating_change"`
}

type DailySales struct {
	Date        string  `json:"date"`
	Amount      float64 `json:"amount"`
	OrderCount  int     `json:"order_count"`
	AvgAmount   float64 `json:"avg_amount"`
}

type TopDish struct {
	DishID      int     `json:"dish_id"`
	Name        string  `json:"name"`
	SalesCount  int     `json:"sales_count"`
	Revenue     float64 `json:"revenue"`
	Category    string  `json:"category"`
}

type CategoryStats struct {
	Category   string  `json:"category"`
	Amount     float64 `json:"amount"`
	Percentage float64 `json:"percentage"`
}

type HourlyStats struct {
	Hour       int `json:"hour"`
	OrderCount int `json:"order_count"`
}

// ============= 1. 仪表板总览数据 =============
func GetDashboardStats(c *gin.Context) {
	db := GetDB() // 获取数据库连接

	var stats DashboardStats
	today := time.Now().Format("2006-01-02")
	yesterday := time.Now().AddDate(0, 0, -1).Format("2006-01-02")

	// 今日销售额
	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as today_sales
		FROM orders 
		WHERE DATE(created_at) = ? AND status = 5
	`, today).Scan(&stats.TodaySales)

	// 昨日销售额用于计算增长率
	var yesterdaySales float64
	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as yesterday_sales
		FROM orders 
		WHERE DATE(created_at) = ? AND status = 5
	`, yesterday).Scan(&yesterdaySales)

	// 今日订单数
	db.Raw(`
		SELECT COUNT(*) as today_orders
		FROM orders 
		WHERE DATE(created_at) = ?
	`, today).Scan(&stats.TodayOrders)

	// 昨日订单数
	var yesterdayOrders int
	db.Raw(`
		SELECT COUNT(*) as yesterday_orders
		FROM orders 
		WHERE DATE(created_at) = ?
	`, yesterday).Scan(&yesterdayOrders)

	// 活跃用户数（最近7天下过单的用户）
	db.Raw(`
		SELECT COUNT(DISTINCT user_id) as active_users
		FROM orders 
		WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
	`).Scan(&stats.ActiveUsers)

	// 计算增长率
	if yesterdaySales > 0 {
		stats.SalesChange = ((stats.TodaySales - yesterdaySales) / yesterdaySales) * 100
	}
	if yesterdayOrders > 0 {
		stats.OrdersChange = (float64(stats.TodayOrders-yesterdayOrders) / float64(yesterdayOrders)) * 100
	}

	// 平均评分（模拟数据，实际需要评价表）
	stats.AvgRating = 4.8
	stats.RatingChange = 0.2

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": stats,
	})
}

// ============= 2. 销售趋势数据 =============
func GetSalesTrend(c *gin.Context) {
	db := GetDB()
	period := c.DefaultQuery("period", "30d")

	var days int
	switch period {
	case "7d":
		days = 7
	case "30d":
		days = 30
	case "90d":
		days = 90
	default:
		days = 30
	}

	var dailySales []DailySales
	db.Raw(`
		SELECT 
			DATE(created_at) as date,
			COALESCE(SUM(amount), 0) as amount,
			COUNT(*) as order_count,
			COALESCE(AVG(amount), 0) as avg_amount
		FROM orders 
		WHERE created_at >= CURRENT_DATE - INTERVAL ? DAY
			AND status = 5
		GROUP BY DATE(created_at)
		ORDER BY date ASC
	`, days).Scan(&dailySales)

	// 计算总销售额和增长率
	var totalAmount float64
	for _, sale := range dailySales {
		totalAmount += sale.Amount
	}

	var growthRate float64
	if len(dailySales) > 1 {
		firstAmount := dailySales[0].Amount
		lastAmount := dailySales[len(dailySales)-1].Amount
		if firstAmount > 0 {
			growthRate = ((lastAmount - firstAmount) / firstAmount) * 100
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"daily_sales":  dailySales,
			"total_amount": totalAmount,
			"growth_rate":  growthRate,
		},
	})
}

// ============= 3. 热销菜品排行 =============
func GetTopDishes(c *gin.Context) {
	db := GetDB()
	limitStr := c.DefaultQuery("limit", "10")
	limit, _ := strconv.Atoi(limitStr)

	var topDishes []TopDish
	db.Raw(`
		SELECT 
			d.id as dish_id,
			d.name,
			SUM(od.number) as sales_count,
			SUM(od.amount) as revenue,
			c.name as category
		FROM dishes d
		JOIN order_details od ON d.id = od.dish_id
		JOIN orders o ON od.order_id = o.id
		JOIN categories c ON d.category_id = c.id
		WHERE o.status = 5
		GROUP BY d.id, d.name, c.name
		ORDER BY sales_count DESC
		LIMIT ?
	`, limit).Scan(&topDishes)

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"top_dishes": topDishes,
		},
	})
}

// ============= 4. 分类销售统计 =============
func GetCategoryStats(c *gin.Context) {
	db := GetDB()

	var categoryStats []CategoryStats
	db.Raw(`
		SELECT 
			c.name as category,
			SUM(od.amount) as amount
		FROM categories c
		JOIN dishes d ON c.id = d.category_id
		JOIN order_details od ON d.id = od.dish_id
		JOIN orders o ON od.order_id = o.id
		WHERE o.status = 5
		GROUP BY c.id, c.name
		ORDER BY amount DESC
	`).Scan(&categoryStats)

	// 计算占比
	var totalAmount float64
	for _, stat := range categoryStats {
		totalAmount += stat.Amount
	}

	for i := range categoryStats {
		if totalAmount > 0 {
			categoryStats[i].Percentage = (categoryStats[i].Amount / totalAmount) * 100
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"category_stats": categoryStats,
		},
	})
}

// ============= 5. 订单时段分布 =============
func GetHourlyOrderStats(c *gin.Context) {
	db := GetDB()

	var hourlyStats []HourlyStats
	db.Raw(`
		SELECT 
			EXTRACT(HOUR FROM created_at) as hour,
			COUNT(*) as order_count
		FROM orders 
		WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
			AND status = 5
		GROUP BY EXTRACT(HOUR FROM created_at)
		ORDER BY hour
	`).Scan(&hourlyStats)

	// 确保24小时都有数据，没有订单的时段填充0
	hourlyMap := make(map[int]int)
	for _, stat := range hourlyStats {
		hourlyMap[stat.Hour] = stat.OrderCount
	}

	var completeStats []HourlyStats
	for hour := 0; hour < 24; hour++ {
		completeStats = append(completeStats, HourlyStats{
			Hour:       hour,
			OrderCount: hourlyMap[hour],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"hourly_stats": completeStats,
		},
	})
}

// ============= 6. 用户消费分析 =============
func GetUserConsumptionStats(c *gin.Context) {
	db := GetDB()

	type UserStats struct {
		UserID      int     `json:"user_id"`
		Name        string  `json:"name"`
		Phone       string  `json:"phone"`
		OrderCount  int     `json:"order_count"`
		TotalAmount float64 `json:"total_consumption"`
		AvgAmount   float64 `json:"avg_order_amount"`
		LastOrder   string  `json:"last_order_time"`
	}

	var userStats []UserStats
	db.Raw(`
		SELECT 
			u.id as user_id,
			u.name,
			u.phone,
			COUNT(o.id) as order_count,
			SUM(o.amount) as total_amount,
			AVG(o.amount) as avg_amount,
			MAX(o.created_at) as last_order
		FROM users u
		JOIN orders o ON u.id = o.user_id
		WHERE o.status = 5
		GROUP BY u.id, u.name, u.phone
		ORDER BY total_amount DESC
		LIMIT 20
	`).Scan(&userStats)

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"user_stats": userStats,
		},
	})
}

// ============= 7. 营业额对比分析 =============
func GetRevenueComparison(c *gin.Context) {
	db := GetDB()

	type RevenueComparison struct {
		Period      string  `json:"period"`
		ThisPeriod  float64 `json:"this_period"`
		LastPeriod  float64 `json:"last_period"`
		GrowthRate  float64 `json:"growth_rate"`
	}

	var comparisons []RevenueComparison

	// 本周 vs 上周
	var thisWeek, lastWeek float64
	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as revenue
		FROM orders 
		WHERE created_at >= date_trunc('week', CURRENT_DATE)
			AND status = 5
	`).Scan(&thisWeek)

	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as revenue
		FROM orders 
		WHERE created_at >= date_trunc('week', CURRENT_DATE) - INTERVAL '7 days'
			AND created_at < date_trunc('week', CURRENT_DATE)
			AND status = 5
	`).Scan(&lastWeek)

	weekGrowth := float64(0)
	if lastWeek > 0 {
		weekGrowth = ((thisWeek - lastWeek) / lastWeek) * 100
	}

	comparisons = append(comparisons, RevenueComparison{
		Period:     "本周",
		ThisPeriod: thisWeek,
		LastPeriod: lastWeek,
		GrowthRate: weekGrowth,
	})

	// 本月 vs 上月
	var thisMonth, lastMonth float64
	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as revenue
		FROM orders 
		WHERE created_at >= date_trunc('month', CURRENT_DATE)
			AND status = 5
	`).Scan(&thisMonth)

	db.Raw(`
		SELECT COALESCE(SUM(amount), 0) as revenue
		FROM orders 
		WHERE created_at >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
			AND created_at < date_trunc('month', CURRENT_DATE)
			AND status = 5
	`).Scan(&lastMonth)

	monthGrowth := float64(0)
	if lastMonth > 0 {
		monthGrowth = ((thisMonth - lastMonth) / lastMonth) * 100
	}

	comparisons = append(comparisons, RevenueComparison{
		Period:     "本月",
		ThisPeriod: thisMonth,
		LastPeriod: lastMonth,
		GrowthRate: monthGrowth,
	})

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "success",
		"data": gin.H{
			"revenue_comparisons": comparisons,
		},
	})
}

// ============= 8. 路由注册 =============
func RegisterStatsRoutes(r *gin.RouterGroup) {
	stats := r.Group("/stats")
	{
		stats.GET("/dashboard", GetDashboardStats)           // 仪表板总览
		stats.GET("/sales", GetSalesTrend)                   // 销售趋势
		stats.GET("/dishes", GetTopDishes)                   // 热销菜品
		stats.GET("/categories", GetCategoryStats)           // 分类统计
		stats.GET("/orders/hourly", GetHourlyOrderStats)     // 时段分布
		stats.GET("/users", GetUserConsumptionStats)         // 用户分析
		stats.GET("/revenue/comparison", GetRevenueComparison) // 营业额对比
	}
}

// ============= 9. 数据库连接示例 =============
func GetDB() *gorm.DB {
	// 这里应该返回你的数据库连接实例
	// 示例代码，实际使用时需要根据你的项目结构调整
	return nil
}

// ============= 10. 中间件：管理员权限验证 =============
func AdminAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// JWT token验证逻辑
		token := c.GetHeader("Authorization")
		if token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code": 401,
				"message": "未授权访问",
			})
			c.Abort()
			return
		}

		// 验证token和管理员权限
		// 这里添加你的JWT验证逻辑
		
		c.Next()
	}
}