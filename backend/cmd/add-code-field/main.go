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

	fmt.Println("添加dishes表的code字段...")

	err = db.Exec("ALTER TABLE dishes ADD COLUMN IF NOT EXISTS code VARCHAR(32)").Error
	if err != nil {
		log.Fatal("添加code字段失败:", err)
	}

	fmt.Println("✅ 成功添加code字段")

	// 验证
	var columns []struct {
		ColumnName string `json:"column_name"`
	}

	err = db.Raw(`
		SELECT column_name 
		FROM information_schema.columns 
		WHERE table_name = 'dishes' AND table_schema = 'public'
		ORDER BY ordinal_position
	`).Scan(&columns).Error

	if err != nil {
		log.Fatal("查询dishes表结构失败:", err)
	}

	fmt.Printf("dishes 表现在包含 %d 个字段:\n", len(columns))
	for i, col := range columns {
		fmt.Printf("%d. %s\n", i+1, col.ColumnName)
	}
}
