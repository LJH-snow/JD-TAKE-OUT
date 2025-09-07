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

	log.Println("开始快速重新初始化测试数据（保留员工）...")

	// 只清理非员工数据
	if err := clearNonEmployeeData(db); err != nil {
		log.Fatalf("Failed to clear data: %v", err)
	}

	// 重新初始化完整数据
	if err := database.SeedData(db); err != nil {
		log.Fatalf("Failed to seed data: %v", err)
	}

	log.Println("✅ 数据重置和初始化完成!")
}

// 清理非员工数据
func clearNonEmployeeData(db *gorm.DB) error {
	fmt.Println("\n=== 清理业务数据（保留员工） ===")

	// 按依赖关系的逆序删除（不删除employees）
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
