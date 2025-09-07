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

	fmt.Println("检查 admins 表的内容...")

	// 查看 admins 表结构
	fmt.Println("\n1. admins 表结构:")
	var columns []struct {
		ColumnName string `json:"column_name"`
		DataType   string `json:"data_type"`
		IsNullable string `json:"is_nullable"`
	}

	err = db.Raw(`
		SELECT column_name, data_type, is_nullable 
		FROM information_schema.columns 
		WHERE table_name = 'admins' AND table_schema = 'public'
		ORDER BY ordinal_position
	`).Scan(&columns).Error

	if err != nil {
		log.Fatal("查询表结构失败:", err)
	}

	for _, col := range columns {
		fmt.Printf("  %s: %s (nullable: %s)\n", col.ColumnName, col.DataType, col.IsNullable)
	}

	// 查看 admins 表数据
	fmt.Println("\n2. admins 表数据:")
	var adminData []map[string]interface{}
	err = db.Raw("SELECT * FROM admins").Scan(&adminData).Error
	if err != nil {
		log.Fatal("查询 admins 表数据失败:", err)
	}

	for i, admin := range adminData {
		fmt.Printf("记录 %d:\n", i+1)
		for key, value := range admin {
			fmt.Printf("  %s: %v\n", key, value)
		}
		fmt.Println()
	}

	// 查看 employees 表结构
	fmt.Println("3. employees 表结构:")
	err = db.Raw(`
		SELECT column_name, data_type, is_nullable 
		FROM information_schema.columns 
		WHERE table_name = 'employees' AND table_schema = 'public'
		ORDER BY ordinal_position
	`).Scan(&columns).Error

	if err != nil {
		log.Fatal("查询 employees 表结构失败:", err)
	}

	for _, col := range columns {
		fmt.Printf("  %s: %s (nullable: %s)\n", col.ColumnName, col.DataType, col.IsNullable)
	}

	fmt.Println("\n建议: 如果 admins 表的数据结构与 employees 表兼容，可以考虑迁移数据")
}
