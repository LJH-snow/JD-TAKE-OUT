package services

import (
	"jd-take-out-backend/internal/models"
	"time"

	"gorm.io/gorm"
)

// StatsService 统计服务
type StatsService struct {
	db *gorm.DB
}

// NewStatsService 创建统计服务实例
func NewStatsService(db *gorm.DB) *StatsService {
	return &StatsService{db: db}
}

// DashboardStats 工作台统计数据
type DashboardStats struct {
	TotalRevenue   float64 `json:"total_revenue"`
	RevenueChange  float64 `json:"revenue_change"`
	ValidOrders    int64   `json:"valid_orders"`
	OrdersChange   float64 `json:"orders_change"`
	CompletionRate float64 `json:"completion_rate"`
	RateChange     float64 `json:"rate_change"`
	AveragePrice   float64 `json:"average_price"`
	PriceChange    float64 `json:"price_change"`
	NewUsers       int64   `json:"new_users"`
	UsersChange    float64 `json:"users_change"`
	UpdateTime     string  `json:"update_time"`
}

// SalesTrendData 销售趋势数据
type SalesTrendData struct {
	Date      string  `json:"date"`
	Revenue   float64 `json:"revenue"`
	Orders    int64   `json:"orders"`
	Customers int64   `json:"customers"`
	Growth    float64 `json:"growth"`
}

// DishRankingData 菜品排行数据
type DishRankingData struct {
	DishID   uint    `json:"dish_id"`
	Name     string  `json:"name"`
	Category string  `json:"category"`
	Quantity int64   `json:"quantity"`
	Revenue  float64 `json:"revenue"`
	Price    float64 `json:"price"`
	Growth   float64 `json:"growth"`
	Rank     int     `json:"rank"`
}

// CategoryStatsData 分类统计数据
type CategoryStatsData struct {
	Category   string  `json:"category"`
	Revenue    float64 `json:"revenue"`
	Quantity   int64   `json:"quantity"`
	Percentage float64 `json:"percentage"`
	Growth     float64 `json:"growth"`
}

// GetDashboardStats 获取工作台统计数据
func (s *StatsService) GetDashboardStats(startDate, endDate string) (*DashboardStats, error) {
	var stats DashboardStats

	// 查询当前时间段数据
	currentData, err := s.getPeriodStats(startDate, endDate)
	if err != nil {
		return nil, err
	}

	// 查询对比时间段数据（计算环比）
	compareData, err := s.getComparePeriodStats(startDate, endDate)
	if err != nil {
		return nil, err
	}

	// 计算统计数据
	stats.TotalRevenue = currentData.Revenue
	stats.ValidOrders = currentData.Orders
	stats.CompletionRate = currentData.CompletionRate
	stats.AveragePrice = currentData.AveragePrice
	stats.NewUsers = currentData.NewUsers

	// 计算环比变化
	if compareData.Revenue > 0 {
		stats.RevenueChange = (currentData.Revenue - compareData.Revenue) / compareData.Revenue * 100
	}
	if compareData.Orders > 0 {
		stats.OrdersChange = float64(currentData.Orders-compareData.Orders) / float64(compareData.Orders) * 100
	}
	if compareData.CompletionRate > 0 {
		stats.RateChange = (currentData.CompletionRate - compareData.CompletionRate) / compareData.CompletionRate * 100
	}
	if compareData.AveragePrice > 0 {
		stats.PriceChange = (currentData.AveragePrice - compareData.AveragePrice) / compareData.AveragePrice * 100
	}
	if compareData.NewUsers > 0 {
		stats.UsersChange = float64(currentData.NewUsers-compareData.NewUsers) / float64(compareData.NewUsers) * 100
	}

	stats.UpdateTime = time.Now().Format("2006-01-02 15:04:05")

	return &stats, nil
}

// getPeriodStats 获取时间段统计数据
func (s *StatsService) getPeriodStats(startDate, endDate string) (*periodStats, error) {
	var stats periodStats

	// 查询订单统计
	err := s.db.Model(&models.Order{}).
		Select(`
			COALESCE(SUM(amount), 0) as revenue,
			COUNT(*) as orders,
			COUNT(DISTINCT user_id) as customers,
			ROUND(AVG(amount), 2) as average_price,
			ROUND(
				COUNT(CASE WHEN status = ? THEN 1 END) * 100.0 / 
				NULLIF(COUNT(CASE WHEN status IN (?,?,?,?) THEN 1 END), 0), 
				2
			) as completion_rate
		`, models.OrderStatusCompleted,
			models.OrderStatusWaiting, models.OrderStatusConfirmed,
			models.OrderStatusDelivering, models.OrderStatusCompleted).
		Where("DATE(order_time) BETWEEN ? AND ?", startDate, endDate).
		Scan(&stats).Error

	if err != nil {
		return nil, err
	}

	// 查询新增用户数
	err = s.db.Model(&models.User{}).
		Where("DATE(created_at) BETWEEN ? AND ?", startDate, endDate).
		Count(&stats.NewUsers).Error

	return &stats, err
}

// getComparePeriodStats 获取对比时间段统计数据
func (s *StatsService) getComparePeriodStats(startDate, endDate string) (*periodStats, error) {
	// 计算对比时间段（上一个相同长度的时间段）
	start, _ := time.Parse("2006-01-02", startDate)
	end, _ := time.Parse("2006-01-02", endDate)
	duration := end.Sub(start)

	compareStart := start.Add(-duration).Format("2006-01-02")
	compareEnd := start.AddDate(0, 0, -1).Format("2006-01-02")

	return s.getPeriodStats(compareStart, compareEnd)
}

// GetSalesTrend 获取销售趋势数据
func (s *StatsService) GetSalesTrend(startDate, endDate string) ([]SalesTrendData, error) {
	var trendData []SalesTrendData

	err := s.db.Model(&models.Order{}).
		Select(`
			DATE(order_time) as date,
			COALESCE(SUM(amount), 0) as revenue,
			COUNT(*) as orders,
			COUNT(DISTINCT user_id) as customers,
			0 as growth
		`).
		Where("DATE(order_time) BETWEEN ? AND ? AND status = ?",
			startDate, endDate, models.OrderStatusCompleted).
		Group("DATE(order_time)").
		Order("DATE(order_time)").
		Scan(&trendData).Error

	// 计算增长率
	for i := 1; i < len(trendData); i++ {
		if trendData[i-1].Revenue > 0 {
			trendData[i].Growth = (trendData[i].Revenue - trendData[i-1].Revenue) / trendData[i-1].Revenue * 100
		}
	}

	return trendData, err
}

// GetDishRanking 获取菜品排行数据
func (s *StatsService) GetDishRanking(startDate, endDate, category, sortBy string, limit int) ([]DishRankingData, error) {
	var rankingData []DishRankingData

	query := s.db.Table("order_detail od").
		Select(`
			d.id as dish_id,
			d.name,
			c.name as category,
			COALESCE(SUM(od.number), 0) as quantity,
			COALESCE(SUM(od.amount), 0) as revenue,
			d.price,
			0 as growth,
			ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(od.number), 0) DESC) as rank
		`).
		Joins("LEFT JOIN dish d ON od.dish_id = d.id").
		Joins("LEFT JOIN category c ON d.category_id = c.id").
		Joins("LEFT JOIN orders o ON od.order_id = o.id").
		Where("DATE(o.order_time) BETWEEN ? AND ? AND o.status = ?",
			startDate, endDate, models.OrderStatusCompleted)

	if category != "all" && category != "" {
		query = query.Where("c.name = ?", category)
	}

	query = query.Group("d.id, d.name, c.name, d.price")

	// 根据排序方式调整ORDER BY
	if sortBy == "revenue" {
		query = query.Order("revenue DESC")
	} else {
		query = query.Order("quantity DESC")
	}

	if limit > 0 {
		query = query.Limit(limit)
	}

	err := query.Scan(&rankingData).Error
	return rankingData, err
}

// GetCategoryStats 获取分类统计数据
func (s *StatsService) GetCategoryStats(startDate, endDate string) ([]CategoryStatsData, error) {
	var categoryData []CategoryStatsData

	err := s.db.Table("order_detail od").
		Select(`
			c.name as category,
			COALESCE(SUM(od.amount), 0) as revenue,
			COALESCE(SUM(od.number), 0) as quantity,
			0 as percentage,
			0 as growth
		`).
		Joins("LEFT JOIN dish d ON od.dish_id = d.id").
		Joins("LEFT JOIN category c ON d.category_id = c.id").
		Joins("LEFT JOIN orders o ON od.order_id = o.id").
		Where("DATE(o.order_time) BETWEEN ? AND ? AND o.status = ?",
			startDate, endDate, models.OrderStatusCompleted).
		Group("c.id, c.name").
		Order("revenue DESC").
		Scan(&categoryData).Error

	if err != nil {
		return nil, err
	}

	// 计算百分比
	var totalRevenue float64
	for _, item := range categoryData {
		totalRevenue += item.Revenue
	}

	for i := range categoryData {
		if totalRevenue > 0 {
			categoryData[i].Percentage = categoryData[i].Revenue / totalRevenue * 100
		}
	}

	return categoryData, err
}

// periodStats 时间段统计数据
type periodStats struct {
	Revenue        float64 `json:"revenue"`
	Orders         int64   `json:"orders"`
	Customers      int64   `json:"customers"`
	AveragePrice   float64 `json:"average_price"`
	CompletionRate float64 `json:"completion_rate"`
	NewUsers       int64   `json:"new_users"`
}
