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

	fmt.Println("=== 开始数据库性能优化 ===")

	// 1. 创建核心业务索引
	createBusinessIndexes(db)

	// 2. 创建统计查询视图
	createStatsViews(db)

	// 3. 验证索引创建结果
	verifyOptimization(db)

	fmt.Println("\n✅ 数据库优化完成!")
}

func createBusinessIndexes(db *gorm.DB) {
	fmt.Println("\n1. 创建业务索引...")

	indexes := []struct {
		name        string
		description string
		sql         string
	}{
		// 订单表索引优化
		{
			name:        "idx_orders_order_time",
			description: "订单时间索引 - 优化按日期查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_orders_order_time ON orders(order_time)",
		},
		{
			name:        "idx_orders_status",
			description: "订单状态索引 - 优化状态筛选",
			sql:         "CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status)",
		},
		{
			name:        "idx_orders_user_id",
			description: "用户ID索引 - 优化用户订单查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id)",
		},
		{
			name:        "idx_orders_composite",
			description: "订单复合索引 - 优化统计查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_orders_composite ON orders(order_time, status, user_id)",
		},

		// 订单详情表索引优化
		{
			name:        "idx_order_details_order_id",
			description: "订单ID索引 - 优化关联查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_order_details_order_id ON order_details(order_id)",
		},
		{
			name:        "idx_order_details_dish_id",
			description: "菜品ID索引 - 优化菜品统计",
			sql:         "CREATE INDEX IF NOT EXISTS idx_order_details_dish_id ON order_details(dish_id)",
		},
		{
			name:        "idx_order_details_setmeal_id",
			description: "套餐ID索引 - 优化套餐统计",
			sql:         "CREATE INDEX IF NOT EXISTS idx_order_details_setmeal_id ON order_details(setmeal_id)",
		},

		// 菜品表索引优化
		{
			name:        "idx_dishes_category_id",
			description: "分类ID索引 - 优化分类查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_dishes_category_id ON dishes(category_id)",
		},
		{
			name:        "idx_dishes_status",
			description: "菜品状态索引 - 优化状态筛选",
			sql:         "CREATE INDEX IF NOT EXISTS idx_dishes_status ON dishes(status)",
		},
		{
			name:        "idx_dishes_composite",
			description: "菜品复合索引 - 优化综合查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_dishes_composite ON dishes(category_id, status)",
		},

		// 用户表索引优化
		{
			name:        "idx_users_created_at",
			description: "用户创建时间索引 - 优化新用户统计",
			sql:         "CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)",
		},
		{
			name:        "idx_users_phone",
			description: "手机号索引 - 优化用户查找",
			sql:         "CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone)",
		},

		// 分类表索引优化
		{
			name:        "idx_categories_type",
			description: "分类类型索引 - 优化分类筛选",
			sql:         "CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type)",
		},
		{
			name:        "idx_categories_status",
			description: "分类状态索引 - 优化状态查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_categories_status ON categories(status)",
		},

		// 套餐表索引优化
		{
			name:        "idx_setmeals_category_id",
			description: "套餐分类索引 - 优化分类查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_setmeals_category_id ON setmeals(category_id)",
		},
		{
			name:        "idx_setmeals_status",
			description: "套餐状态索引 - 优化状态筛选",
			sql:         "CREATE INDEX IF NOT EXISTS idx_setmeals_status ON setmeals(status)",
		},

		// 地址簿索引优化
		{
			name:        "idx_address_books_user_id",
			description: "用户地址索引 - 优化用户地址查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_address_books_user_id ON address_books(user_id)",
		},
		{
			name:        "idx_address_books_default",
			description: "默认地址索引 - 优化默认地址查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_address_books_default ON address_books(user_id, is_default)",
		},

		// 购物车索引优化
		{
			name:        "idx_shopping_carts_user_id",
			description: "用户购物车索引 - 优化购物车查询",
			sql:         "CREATE INDEX IF NOT EXISTS idx_shopping_carts_user_id ON shopping_carts(user_id)",
		},
	}

	for _, idx := range indexes {
		fmt.Printf("创建索引: %s\n", idx.description)
		err := db.Exec(idx.sql).Error
		if err != nil {
			log.Printf("❌ %s 创建失败: %v", idx.name, err)
		} else {
			fmt.Printf("✅ %s 创建成功\n", idx.name)
		}
	}
}

func createStatsViews(db *gorm.DB) {
	fmt.Println("\n2. 创建统计查询视图...")

	views := []struct {
		name        string
		description string
		sql         string
	}{
		// 每日销售统计视图
		{
			name:        "v_daily_sales",
			description: "每日销售统计视图 - 优化销售趋势查询",
			sql: `
				CREATE OR REPLACE VIEW v_daily_sales AS
				SELECT 
					DATE(order_time) as date,
					COALESCE(SUM(amount), 0) as revenue,
					COUNT(*) as orders,
					COUNT(DISTINCT user_id) as customers,
					ROUND(AVG(amount), 2) as avg_amount
				FROM orders 
				WHERE status = 5 AND deleted_at IS NULL
				GROUP BY DATE(order_time)
				ORDER BY date DESC
			`,
		},

		// 菜品销售排行视图
		{
			name:        "v_dish_ranking",
			description: "菜品销售排行视图 - 优化菜品统计查询",
			sql: `
				CREATE OR REPLACE VIEW v_dish_ranking AS
				SELECT 
					d.id as dish_id,
					d.name as dish_name,
					c.name as category_name,
					d.price as dish_price,
					COALESCE(SUM(od.number), 0) as total_quantity,
					COALESCE(SUM(od.amount), 0) as total_revenue,
					COUNT(DISTINCT o.id) as order_count,
					ROUND(AVG(od.amount), 2) as avg_revenue
				FROM dishes d
				LEFT JOIN categories c ON d.category_id = c.id
				LEFT JOIN order_details od ON d.id = od.dish_id
				LEFT JOIN orders o ON od.order_id = o.id AND o.status = 5 AND o.deleted_at IS NULL
				WHERE d.deleted_at IS NULL
				GROUP BY d.id, d.name, c.name, d.price
				ORDER BY total_quantity DESC, total_revenue DESC
			`,
		},

		// 分类销售统计视图
		{
			name:        "v_category_stats",
			description: "分类销售统计视图 - 优化分类统计查询",
			sql: `
				CREATE OR REPLACE VIEW v_category_stats AS
				SELECT 
					c.id as category_id,
					c.name as category_name,
					c.type as category_type,
					COALESCE(SUM(od.amount), 0) as total_revenue,
					COALESCE(SUM(od.number), 0) as total_quantity,
					COUNT(DISTINCT od.dish_id) as dish_count,
					COUNT(DISTINCT o.id) as order_count
				FROM categories c
				LEFT JOIN dishes d ON c.id = d.category_id AND d.deleted_at IS NULL
				LEFT JOIN order_details od ON d.id = od.dish_id
				LEFT JOIN orders o ON od.order_id = o.id AND o.status = 5 AND o.deleted_at IS NULL
				WHERE c.deleted_at IS NULL
				GROUP BY c.id, c.name, c.type
				ORDER BY total_revenue DESC
			`,
		},

		// 用户活跃度统计视图
		{
			name:        "v_user_activity",
			description: "用户活跃度统计视图 - 优化用户分析查询",
			sql: `
				CREATE OR REPLACE VIEW v_user_activity AS
				SELECT 
					u.id as user_id,
					u.name as user_name,
					u.phone as user_phone,
					DATE(u.created_at) as register_date,
					COALESCE(COUNT(o.id), 0) as total_orders,
					COALESCE(SUM(o.amount), 0) as total_spent,
					COALESCE(MAX(o.order_time), u.created_at) as last_order_time,
					CASE 
						WHEN MAX(o.order_time) >= CURRENT_DATE - INTERVAL '7 days' THEN 'active'
						WHEN MAX(o.order_time) >= CURRENT_DATE - INTERVAL '30 days' THEN 'inactive'
						ELSE 'dormant'
					END as activity_status
				FROM users u
				LEFT JOIN orders o ON u.id = o.user_id AND o.status = 5 AND o.deleted_at IS NULL
				WHERE u.deleted_at IS NULL
				GROUP BY u.id, u.name, u.phone, u.created_at
				ORDER BY total_spent DESC
			`,
		},

		// 月度营收统计视图
		{
			name:        "v_monthly_revenue",
			description: "月度营收统计视图 - 优化月度报表查询",
			sql: `
				CREATE OR REPLACE VIEW v_monthly_revenue AS
				SELECT 
					EXTRACT(YEAR FROM order_time) as year,
					EXTRACT(MONTH FROM order_time) as month,
					TO_CHAR(order_time, 'YYYY-MM') as year_month,
					COUNT(*) as total_orders,
					COALESCE(SUM(amount), 0) as total_revenue,
					ROUND(AVG(amount), 2) as avg_order_amount,
					COUNT(DISTINCT user_id) as unique_customers
				FROM orders 
				WHERE status = 5 AND deleted_at IS NULL
				GROUP BY EXTRACT(YEAR FROM order_time), EXTRACT(MONTH FROM order_time), TO_CHAR(order_time, 'YYYY-MM')
				ORDER BY year DESC, month DESC
			`,
		},
	}

	for _, view := range views {
		fmt.Printf("创建视图: %s\n", view.description)
		err := db.Exec(view.sql).Error
		if err != nil {
			log.Printf("❌ %s 创建失败: %v", view.name, err)
		} else {
			fmt.Printf("✅ %s 创建成功\n", view.name)
		}
	}
}

func verifyOptimization(db *gorm.DB) {
	fmt.Println("\n3. 验证优化效果...")

	// 检查索引创建情况
	fmt.Println("\n检查索引:")
	var indexes []string

	err := db.Raw(`
		SELECT indexname
		FROM pg_indexes 
		WHERE schemaname = 'public' 
		AND indexname LIKE 'idx_%'
		ORDER BY indexname
	`).Scan(&indexes).Error

	if err != nil {
		log.Printf("❌ 查询索引失败: %v", err)
	} else {
		fmt.Printf("✅ 创建了 %d 个业务索引:\n", len(indexes))
		for _, idx := range indexes {
			fmt.Printf("  - %s\n", idx)
		}
	}

	// 检查视图创建情况
	fmt.Println("\n检查视图:")
	var views []string

	err = db.Raw(`
		SELECT viewname 
		FROM pg_views 
		WHERE schemaname = 'public' 
		AND viewname LIKE 'v_%'
		ORDER BY viewname
	`).Scan(&views).Error

	if err != nil {
		log.Printf("❌ 查询视图失败: %v", err)
	} else {
		fmt.Printf("✅ 创建了 %d 个统计视图:\n", len(views))
		for _, view := range views {
			fmt.Printf("  - %s\n", view)
		}
	}

	// 测试关键查询性能
	fmt.Println("\n测试查询性能:")
	testQueries := []struct {
		name string
		sql  string
	}{
		{
			name: "今日销售统计",
			sql:  "SELECT * FROM v_daily_sales WHERE date = CURRENT_DATE",
		},
		{
			name: "菜品排行TOP10",
			sql:  "SELECT * FROM v_dish_ranking LIMIT 10",
		},
		{
			name: "分类销售统计",
			sql:  "SELECT * FROM v_category_stats",
		},
	}

	for _, test := range testQueries {
		start := time.Now()
		var result []map[string]interface{}
		err := db.Raw(test.sql).Scan(&result).Error
		duration := time.Since(start)

		if err != nil {
			fmt.Printf("❌ %s 查询失败: %v\n", test.name, err)
		} else {
			fmt.Printf("✅ %s 查询成功 - 耗时: %v, 结果: %d 条\n",
				test.name, duration, len(result))
		}
	}
}
