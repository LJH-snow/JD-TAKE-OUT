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

	fmt.Println("检查address_books表的is_default字段类型...")

	var result struct {
		ColumnName string `json:"column_name"`
		DataType   string `json:"data_type"`
	}

	err = db.Raw(`
		SELECT column_name, data_type 
		FROM information_schema.columns 
		WHERE table_name = 'address_books' AND column_name = 'is_default' AND table_schema = 'public'
	`).Scan(&result).Error

	if err != nil {
		log.Fatal("查询失败:", err)
	}

	fmt.Printf("字段名: %s, 数据类型: %s\n", result.ColumnName, result.DataType)

	// 如果是boolean类型，修改为integer
	if result.DataType == "boolean" {
		fmt.Println("is_default字段是boolean类型，修改为integer...")

		err = db.Exec("ALTER TABLE address_books ALTER COLUMN is_default TYPE INTEGER USING is_default::integer").Error
		if err != nil {
			log.Fatal("修改字段类型失败:", err)
		}

		fmt.Println("✅ 字段类型修改成功")
	} else {
		fmt.Printf("字段类型已经是 %s，无需修改\n", result.DataType)
	}
}
