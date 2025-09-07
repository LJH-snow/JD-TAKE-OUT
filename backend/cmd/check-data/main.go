package main

import (
	"fmt"
	"log"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// 连接数据库
	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	fmt.Println("=== 数据库现有数据统计 ===")

	// 统计各表数据量
	tables := map[string]string{
		"用户":   "users",
		"员工":   "employees",
		"分类":   "categories",
		"菜品":   "dishes",
		"菜品口味": "dish_flavors",
		"套餐":   "setmeals",
		"套餐菜品": "setmeal_dishes",
		"订单":   "orders",
		"订单详情": "order_details",
		"地址簿":  "address_books",
		"购物车":  "shopping_carts",
	}

	for name, table := range tables {
		var count int64
		err := db.Raw(fmt.Sprintf("SELECT COUNT(*) FROM %s", table)).Scan(&count).Error
		if err != nil {
			fmt.Printf("%s表查询失败: %v\n", name, err)
		} else {
			fmt.Printf("%s: %d 条\n", name, count)
		}
	}

	// 检查最近订单
	fmt.Println("\n=== 最近订单统计 ===")
	var stats struct {
		TotalRevenue float64 `json:"total_revenue"`
		OrderCount   int64   `json:"order_count"`
		AvgAmount    float64 `json:"avg_amount"`
	}

	err = db.Raw(`
		SELECT 
			COALESCE(SUM(amount), 0) as total_revenue,
			COUNT(*) as order_count,
			COALESCE(AVG(amount), 0) as avg_amount
		FROM orders 
		WHERE status = 5
	`).Scan(&stats).Error

	if err != nil {
		fmt.Printf("订单统计查询失败: %v\n", err)
	} else {
		fmt.Printf("总营业额: ¥%.2f\n", stats.TotalRevenue)
		fmt.Printf("完成订单数: %d\n", stats.OrderCount)
		fmt.Printf("平均订单金额: ¥%.2f\n", stats.AvgAmount)
	}

	// 检查菜品销售
	fmt.Println("\n=== 菜品销售统计 ===")
	var dishStats []struct {
		DishName string  `json:"dish_name"`
		Quantity int64   `json:"quantity"`
		Revenue  float64 `json:"revenue"`
	}

	err = db.Raw(`
		SELECT 
			od.name as dish_name,
			SUM(od.number) as quantity,
			SUM(od.amount) as revenue
		FROM order_details od
		JOIN orders o ON od.order_id = o.id
		WHERE o.status = 5 AND od.dish_id IS NOT NULL
		GROUP BY od.name
		ORDER BY quantity DESC
		LIMIT 5
	`).Scan(&dishStats).Error

	if err != nil {
		fmt.Printf("菜品统计查询失败: %v\n", err)
	} else {
		fmt.Println("热销菜品TOP5:")
		for i, dish := range dishStats {
			fmt.Printf("%d. %s - 销量:%d, 收入:¥%.2f\n", i+1, dish.DishName, dish.Quantity, dish.Revenue)
		}
	}
}
