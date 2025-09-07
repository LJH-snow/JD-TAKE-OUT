package main

import (
	"fmt"
	"log"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"

	"gorm.io/gorm"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 连接数据库
	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	log.Println("开始强制初始化完整的测试数据...")

	// 强制执行完整的数据初始化
	if err := database.SeedData(db); err != nil {
		log.Fatalf("Failed to seed data: %v", err)
	}

	log.Println("完整测试数据初始化完成!")

	// 验证数据
	if err := verifyData(db); err != nil {
		log.Printf("Data verification failed: %v", err)
	} else {
		log.Println("✅ 数据验证成功!")
	}
}

// 验证数据完整性
func verifyData(db *gorm.DB) error {
	fmt.Println("\n=== 数据验证 ===")

	// 检查各表数据量
	tables := map[string]string{
		"employees":     "员工",
		"users":         "用户",
		"categories":    "分类",
		"dishes":        "菜品",
		"address_books": "地址",
		"orders":        "订单",
	}

	for table, name := range tables {
		var count int64
		err := db.Table(table).Count(&count).Error
		if err != nil {
			return fmt.Errorf("查询 %s 表失败: %w", name, err)
		}
		fmt.Printf("%s表: %d 条记录\n", name, count)
	}

	return nil
}
