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

	// 查询 orders 表的结构
	fmt.Println("=== orders 表字段信息 ===")
	var columns []struct {
		ColumnName string `json:"column_name"`
		DataType   string `json:"data_type"`
		IsNullable string `json:"is_nullable"`
	}

	err = db.Raw(`
		SELECT column_name, data_type, is_nullable 
		FROM information_schema.columns 
		WHERE table_name = 'orders' AND table_schema = 'public'
		ORDER BY ordinal_position
	`).Scan(&columns).Error

	if err != nil {
		log.Fatal("Failed to query orders table structure:", err)
	}

	fmt.Printf("orders 表包含 %d 个字段:\n", len(columns))
	for i, col := range columns {
		fmt.Printf("%d. %s (%s) - %s\n", i+1, col.ColumnName, col.DataType, col.IsNullable)
	}

	// 检查缺失的字段
	fmt.Println("\n=== 检查Order模型中要求的字段 ===")
	requiredFields := []string{
		"cancel_reason",
		"rejection_reason",
		"cancel_time",
		"estimated_delivery_time",
		"delivery_status",
		"delivery_time",
		"pack_amount",
		"tableware_number",
		"tableware_status",
		"deleted_at",
	}

	existingFields := make(map[string]bool)
	for _, col := range columns {
		existingFields[col.ColumnName] = true
	}

	var missingFields []string
	for _, field := range requiredFields {
		if !existingFields[field] {
			missingFields = append(missingFields, field)
		}
	}

	if len(missingFields) > 0 {
		fmt.Printf("❌ 缺失的字段 (%d个):\n", len(missingFields))
		for _, field := range missingFields {
			fmt.Printf("  - %s\n", field)
		}
	} else {
		fmt.Println("✅ 所有必需字段都存在")
	}
}
