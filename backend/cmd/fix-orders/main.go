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

	fmt.Println("开始修复 orders 表结构...")

	// 添加缺失的字段
	alterStatements := []struct {
		SQL         string
		Description string
	}{
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancel_reason VARCHAR(255)",
			Description: "添加取消原因字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(255)",
			Description: "添加拒绝原因字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancel_time TIMESTAMP",
			Description: "添加取消时间字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_status INTEGER DEFAULT 1 NOT NULL",
			Description: "添加配送状态字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS pack_amount INTEGER",
			Description: "添加打包费字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS tableware_number INTEGER",
			Description: "添加餐具数量字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS tableware_status INTEGER DEFAULT 1 NOT NULL",
			Description: "添加餐具数量状态字段",
		},
		{
			SQL:         "ALTER TABLE orders ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP",
			Description: "添加软删除字段",
		},
	}

	for _, stmt := range alterStatements {
		fmt.Printf("执行: %s\n", stmt.Description)
		err := db.Exec(stmt.SQL).Error
		if err != nil {
			log.Printf("❌ %s 失败: %v", stmt.Description, err)
		} else {
			fmt.Printf("✅ %s 成功\n", stmt.Description)
		}
	}

	// 创建软删除索引
	fmt.Println("\n创建索引...")
	indexSQL := "CREATE INDEX IF NOT EXISTS idx_orders_deleted_at ON orders(deleted_at)"
	err = db.Exec(indexSQL).Error
	if err != nil {
		log.Printf("❌ 创建软删除索引失败: %v", err)
	} else {
		fmt.Println("✅ 创建软删除索引成功")
	}

	// 验证修复结果
	fmt.Println("\n验证修复结果...")
	var columns []struct {
		ColumnName string `json:"column_name"`
		DataType   string `json:"data_type"`
	}

	err = db.Raw(`
		SELECT column_name, data_type 
		FROM information_schema.columns 
		WHERE table_name = 'orders' AND table_schema = 'public'
		ORDER BY ordinal_position
	`).Scan(&columns).Error

	if err != nil {
		log.Fatal("验证失败:", err)
	}

	fmt.Printf("\norders 表现在包含 %d 个字段:\n", len(columns))
	for i, col := range columns {
		fmt.Printf("%d. %s (%s)\n", i+1, col.ColumnName, col.DataType)
	}

	fmt.Println("\n✅ orders 表结构修复完成！")
}
