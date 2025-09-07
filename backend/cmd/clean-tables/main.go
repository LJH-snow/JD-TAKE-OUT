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

	fmt.Println("开始清理重复表...")

	// 1. 检查 address_book 和 address_books 表
	fmt.Println("\n1. 处理 address_book 表重复问题...")

	// 检查两个表是否都存在
	var addressBookCount, addressBooksCount int64
	db.Raw("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'address_book' AND table_schema = 'public'").Scan(&addressBookCount)
	db.Raw("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'address_books' AND table_schema = 'public'").Scan(&addressBooksCount)

	if addressBookCount > 0 && addressBooksCount > 0 {
		fmt.Println("发现重复表: address_book 和 address_books")

		// 检查两个表的数据量
		var addressBookRows, addressBooksRows int64
		db.Raw("SELECT COUNT(*) FROM address_book").Scan(&addressBookRows)
		db.Raw("SELECT COUNT(*) FROM address_books").Scan(&addressBooksRows)

		fmt.Printf("address_book 表有 %d 行数据\n", addressBookRows)
		fmt.Printf("address_books 表有 %d 行数据\n", addressBooksRows)

		// 如果 address_books 表有数据，保留它；否则删除 address_book 表
		if addressBooksRows > 0 || addressBookRows == 0 {
			fmt.Println("删除单数形式的 address_book 表...")
			err := db.Exec("DROP TABLE IF EXISTS address_book CASCADE").Error
			if err != nil {
				log.Printf("删除 address_book 表失败: %v", err)
			} else {
				fmt.Println("✓ 已删除 address_book 表")
			}
		} else {
			// 如果 address_book 有数据而 address_books 没有，需要迁移数据
			fmt.Println("将数据从 address_book 迁移到 address_books...")

			// 先检查 address_books 表结构
			err := db.Exec("ALTER TABLE address_book RENAME TO address_books").Error
			if err != nil {
				log.Printf("重命名表失败: %v", err)
			} else {
				fmt.Println("✓ 已将 address_book 重命名为 address_books")
			}
		}
	} else if addressBookCount > 0 {
		fmt.Println("只发现 address_book 表，重命名为 address_books...")
		err := db.Exec("ALTER TABLE address_book RENAME TO address_books").Error
		if err != nil {
			log.Printf("重命名表失败: %v", err)
		} else {
			fmt.Println("✓ 已将 address_book 重命名为 address_books")
		}
	} else {
		fmt.Println("✓ address_books 表已正确存在")
	}

	// 2. 检查并处理 admins 表
	fmt.Println("\n2. 处理 admins 表...")
	var adminsCount int64
	db.Raw("SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'admins' AND table_schema = 'public'").Scan(&adminsCount)

	if adminsCount > 0 {
		var adminsRows int64
		db.Raw("SELECT COUNT(*) FROM admins").Scan(&adminsRows)
		fmt.Printf("发现 admins 表，包含 %d 行数据\n", adminsRows)

		if adminsRows == 0 {
			fmt.Println("admins 表为空，删除...")
			err := db.Exec("DROP TABLE IF EXISTS admins CASCADE").Error
			if err != nil {
				log.Printf("删除 admins 表失败: %v", err)
			} else {
				fmt.Println("✓ 已删除空的 admins 表")
			}
		} else {
			fmt.Println("⚠️  admins 表有数据，请手动检查是否需要迁移到 employees 表")
		}
	} else {
		fmt.Println("✓ 未发现 admins 表")
	}

	// 3. 最终检查
	fmt.Println("\n3. 最终表结构检查...")
	var tables []string
	err = db.Raw("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename").Scan(&tables).Error
	if err != nil {
		log.Fatal("Failed to query tables:", err)
	}

	fmt.Println("清理后的表列表：")
	for i, table := range tables {
		fmt.Printf("%d. %s\n", i+1, table)
	}

	fmt.Println("\n✅ 表清理完成！")
}
