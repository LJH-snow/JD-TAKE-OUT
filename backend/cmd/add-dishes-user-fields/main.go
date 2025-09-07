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

	fmt.Println("添加dishes表的create_user和update_user字段...")

	sqls := []string{
		"ALTER TABLE dishes ADD COLUMN IF NOT EXISTS create_user BIGINT",
		"ALTER TABLE dishes ADD COLUMN IF NOT EXISTS update_user BIGINT",
	}

	for _, sql := range sqls {
		err = db.Exec(sql).Error
		if err != nil {
			log.Printf("执行失败: %s - %v", sql, err)
		} else {
			fmt.Printf("✅ 成功: %s\n", sql)
		}
	}

	fmt.Println("✅ 所有字段添加完成")
}
