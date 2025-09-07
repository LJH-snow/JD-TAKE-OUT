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

	log.Println("开始重置并重新初始化所有测试数据...")

	// 清理现有数据
	if err := clearData(db); err != nil {
		log.Fatalf("Failed to clear data: %v", err)
	}

	// 重新初始化完整数据
	if err := database.SeedData(db); err != nil {
		log.Fatalf("Failed to seed data: %v", err)
	}

	log.Println("✅ 数据重置和初始化完成!")

	// 验证数据
	if err := verifyData(db); err != nil {
		log.Printf("Data verification failed: %v", err)
	} else {
		log.Println("✅ 数据验证成功!")
	}
}

// 清理现有数据
func clearData(db *gorm.DB) error {
	fmt.Println("\n=== 清理现有数据 ===")

	// 按依赖关系的逆序删除
	tables := []string{
		"order_details",
		"orders",
		"setmeal_dishes",
		"setmeals",
		"dish_flavors",
		"dishes",
		"address_books",
		"shopping_carts",
		"categories",
		"users",
		// 同时清理员工数据，以避免重复键冲突
		"employees",
	}

	for _, table := range tables {
		result := db.Exec(fmt.Sprintf("DELETE FROM %s", table))
		if result.Error != nil {
			log.Printf("警告: 清理 %s 表失败: %v", table, result.Error)
		} else {
			fmt.Printf("✓ 清理 %s 表，删除 %d 条记录\n", table, result.RowsAffected)
		}
	}

	return nil
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
		"dish_flavors":  "菜品口味",
		"address_books": "地址",
		"setmeals":      "套餐",
		"orders":        "订单",
		"order_details": "订单明细",
	}

	for table, name := range tables {
		var count int64
		err := db.Table(table).Count(&count).Error
		if err != nil {
			return fmt.Errorf("查询 %s 表失败: %w", name, err)
		}
		fmt.Printf("%s表: %d 条记录\n", name, count)

		// 检查关键表是否有数据
		if table == "users" && count == 0 {
			return fmt.Errorf("用户表为空，数据初始化失败")
		}
		if table == "categories" && count == 0 {
			return fmt.Errorf("分类表为空，数据初始化失败")
		}
	}

	return nil
}
