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

	fmt.Println("修复address_books表的is_default字段...")

	// 1. 删除默认值
	fmt.Println("1. 删除默认值...")
	err = db.Exec("ALTER TABLE address_books ALTER COLUMN is_default DROP DEFAULT").Error
	if err != nil {
		log.Printf("删除默认值失败: %v", err)
	} else {
		fmt.Println("✅ 默认值删除成功")
	}

	// 2. 修改字段类型
	fmt.Println("2. 修改字段类型...")
	err = db.Exec("ALTER TABLE address_books ALTER COLUMN is_default TYPE INTEGER USING is_default::integer").Error
	if err != nil {
		log.Fatal("修改字段类型失败:", err)
	}
	fmt.Println("✅ 字段类型修改成功")

	// 3. 添加新的默认值
	fmt.Println("3. 添加新的默认值...")
	err = db.Exec("ALTER TABLE address_books ALTER COLUMN is_default SET DEFAULT 0").Error
	if err != nil {
		log.Printf("添加默认值失败: %v", err)
	} else {
		fmt.Println("✅ 默认值设置成功")
	}

	fmt.Println("✅ is_default字段修复完成")
}
