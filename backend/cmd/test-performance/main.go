package main

import (
	"fmt"
	"log"
	"time"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"

	"gorm.io/gorm"
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

	fmt.Println("=== 数据库性能测试对比 ===")

	// 测试统计查询性能
	testQueries := []struct {
		name      string
		query     string
		viewQuery string
	}{
		{
			name: "今日销售统计",
			query: `
				SELECT 
					COALESCE(SUM(amount), 0) as total_revenue,
					COUNT(*) as valid_orders,
					COUNT(DISTINCT user_id) as customers
				FROM orders 
				WHERE DATE(order_time) = CURRENT_DATE AND status = 5
			`,
			viewQuery: "SELECT * FROM v_daily_sales WHERE date = CURRENT_DATE",
		},
		{
			name: "菜品销售排行",
			query: `
				SELECT 
					d.id as dish_id,
					od.name,
					c.name as category,
					SUM(od.number) as quantity,
					SUM(od.amount) as revenue,
					d.price
				FROM order_details od
				JOIN orders o ON od.order_id = o.id
				JOIN dishes d ON od.dish_id = d.id
				JOIN categories c ON d.category_id = c.id
				WHERE DATE(o.order_time) BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
					AND o.status = 5 AND od.dish_id IS NOT NULL
				GROUP BY d.id, od.name, c.name, d.price
				ORDER BY quantity DESC
				LIMIT 10
			`,
			viewQuery: "SELECT * FROM v_dish_ranking LIMIT 10",
		},
		{
			name: "分类销售统计",
			query: `
				SELECT 
					c.name as category,
					SUM(od.amount) as revenue,
					SUM(od.number) as quantity
				FROM order_details od
				JOIN orders o ON od.order_id = o.id
				JOIN dishes d ON od.dish_id = d.id
				JOIN categories c ON d.category_id = c.id
				WHERE DATE(o.order_time) BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
					AND o.status = 5 AND od.dish_id IS NOT NULL
				GROUP BY c.id, c.name
				ORDER BY revenue DESC
			`,
			viewQuery: "SELECT * FROM v_category_stats",
		},
	}

	for _, test := range testQueries {
		fmt.Printf("\n--- %s ---\n", test.name)

		// 测试原始查询
		start := time.Now()
		var result1 []map[string]interface{}
		err := db.Raw(test.query).Scan(&result1).Error
		duration1 := time.Since(start)

		if err != nil {
			fmt.Printf("❌ 原始查询失败: %v\n", err)
		} else {
			fmt.Printf("🔍 原始查询: %v, 结果: %d 条\n", duration1, len(result1))
		}

		// 测试视图查询
		start = time.Now()
		var result2 []map[string]interface{}
		err = db.Raw(test.viewQuery).Scan(&result2).Error
		duration2 := time.Since(start)

		if err != nil {
			fmt.Printf("❌ 视图查询失败: %v\n", err)
		} else {
			fmt.Printf("⚡ 视图查询: %v, 结果: %d 条\n", duration2, len(result2))
		}

		// 性能提升计算
		if duration1 > 0 && duration2 > 0 {
			improvement := float64(duration1-duration2) / float64(duration1) * 100
			if improvement > 0 {
				fmt.Printf("✅ 性能提升: %.1f%%\n", improvement)
			} else {
				fmt.Printf("📊 性能对比: 视图查询耗时稍长 %.1f%%\n", -improvement)
			}
		}
	}

	// 测试索引效果
	fmt.Println("\n=== 索引效果测试 ===")
	testIndexes(db)

	fmt.Println("\n✅ 性能测试完成!")
}

func testIndexes(db *gorm.DB) {
	indexTests := []struct {
		name  string
		query string
	}{
		{
			name:  "订单日期查询",
			query: "SELECT COUNT(*) FROM orders WHERE order_time >= CURRENT_DATE - INTERVAL '7 days'",
		},
		{
			name:  "用户订单查询",
			query: "SELECT COUNT(*) FROM orders WHERE user_id = 1",
		},
		{
			name:  "菜品分类查询",
			query: "SELECT COUNT(*) FROM dishes WHERE category_id = 1 AND status = 1",
		},
		{
			name:  "订单详情关联查询",
			query: "SELECT COUNT(*) FROM order_details WHERE order_id IN (SELECT id FROM orders WHERE status = 5)",
		},
	}

	for _, test := range indexTests {
		start := time.Now()
		var count int64
		err := db.Raw(test.query).Scan(&count).Error
		duration := time.Since(start)

		if err != nil {
			fmt.Printf("❌ %s 失败: %v\n", test.name, err)
		} else {
			fmt.Printf("⚡ %s: %v (结果: %d)\n", test.name, duration, count)
		}
	}
}
