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

	// 查询所有表名
	var tables []string
	err = db.Raw("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename").Scan(&tables).Error
	if err != nil {
		log.Fatal("Failed to query tables:", err)
	}

	fmt.Println("当前数据库中的表：")
	for i, table := range tables {
		fmt.Printf("%d. %s\n", i+1, table)
	}

	// 检查可能的重复表
	fmt.Println("\n检查可能的重复表：")
	checkDuplicates(tables)
}

func checkDuplicates(tables []string) {
	// 检查单数/复数形式的重复
	pluralMap := map[string]string{
		"address_book":  "address_books",
		"category":      "categories",
		"dish":          "dishes",
		"dish_flavor":   "dish_flavors",
		"employee":      "employees",
		"order":         "orders",
		"order_detail":  "order_details",
		"setmeal":       "setmeals",
		"setmeal_dish":  "setmeal_dishes",
		"shopping_cart": "shopping_carts",
		"user":          "users",
	}

	tableSet := make(map[string]bool)
	for _, table := range tables {
		tableSet[table] = true
	}

	var duplicatesFound bool
	for singular, plural := range pluralMap {
		if tableSet[singular] && tableSet[plural] {
			fmt.Printf("❌ 发现重复表: %s 和 %s\n", singular, plural)
			duplicatesFound = true
		} else if tableSet[singular] {
			fmt.Printf("⚠️  发现单数形式表: %s (应该是 %s)\n", singular, plural)
			duplicatesFound = true
		} else if tableSet[plural] {
			fmt.Printf("✅ 正确的复数形式表: %s\n", plural)
		}
	}

	// 检查其他非标准表
	fmt.Println("\n其他表：")
	for _, table := range tables {
		found := false
		for singular, plural := range pluralMap {
			if table == singular || table == plural {
				found = true
				break
			}
		}
		if !found {
			fmt.Printf("⚠️  非标准表: %s\n", table)
		}
	}

	if !duplicatesFound {
		fmt.Println("✅ 未发现重复表！")
	}
}
