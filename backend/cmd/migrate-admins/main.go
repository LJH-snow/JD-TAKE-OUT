package main

import (
	"fmt"
	"log"
	"time"

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

	fmt.Println("开始迁移 admins 表数据到 employees 表...")

	// 1. 检查 employees 表中是否已有相同用户名的记录
	var existingCount int64
	err = db.Raw("SELECT COUNT(*) FROM employees WHERE username = 'admin'").Scan(&existingCount).Error
	if err != nil {
		log.Fatal("检查 employees 表失败:", err)
	}

	if existingCount > 0 {
		fmt.Println("employees 表中已存在 admin 用户，跳过迁移")

		// 直接删除 admins 表
		fmt.Println("删除 admins 表...")
		err = db.Exec("DROP TABLE IF EXISTS admins CASCADE").Error
		if err != nil {
			log.Printf("删除 admins 表失败: %v", err)
		} else {
			fmt.Println("✓ 已删除 admins 表")
		}
		return
	}

	// 2. 获取 admins 表数据
	var adminData struct {
		ID        int64     `json:"id"`
		Username  string    `json:"username"`
		Password  string    `json:"password"`
		Name      string    `json:"name"`
		Phone     string    `json:"phone"`
		Status    int       `json:"status"`
		CreatedAt time.Time `json:"created_at"`
		UpdatedAt time.Time `json:"updated_at"`
	}

	err = db.Raw("SELECT * FROM admins WHERE username = 'admin'").Scan(&adminData).Error
	if err != nil {
		log.Fatal("查询 admins 表数据失败:", err)
	}

	fmt.Printf("准备迁移用户: %s (%s)\n", adminData.Username, adminData.Name)

	// 3. 插入到 employees 表
	insertSQL := `
		INSERT INTO employees (name, username, password, phone, sex, id_number, status, created_at, updated_at, create_user, update_user)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`

	err = db.Exec(insertSQL,
		adminData.Name,
		adminData.Username,
		adminData.Password,
		adminData.Phone,
		"1",                  // 默认性别为男性
		"000000000000000000", // 默认身份证号
		adminData.Status,
		adminData.CreatedAt,
		adminData.UpdatedAt,
		0, // create_user
		0, // update_user
	).Error

	if err != nil {
		log.Printf("迁移数据到 employees 表失败: %v", err)
		return
	}

	fmt.Println("✓ 成功迁移数据到 employees 表")

	// 4. 删除 admins 表
	fmt.Println("删除 admins 表...")
	err = db.Exec("DROP TABLE IF EXISTS admins CASCADE").Error
	if err != nil {
		log.Printf("删除 admins 表失败: %v", err)
	} else {
		fmt.Println("✓ 已删除 admins 表")
	}

	// 5. 验证迁移结果
	var migratedCount int64
	err = db.Raw("SELECT COUNT(*) FROM employees WHERE username = 'admin'").Scan(&migratedCount).Error
	if err != nil {
		log.Fatal("验证迁移结果失败:", err)
	}

	if migratedCount > 0 {
		fmt.Println("✅ 迁移成功！admin 用户已存在于 employees 表中")
	} else {
		fmt.Println("❌ 迁移失败！admin 用户未在 employees 表中找到")
	}

	// 6. 最终检查表列表
	fmt.Println("\n最终表列表：")
	var tables []string
	err = db.Raw("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename").Scan(&tables).Error
	if err != nil {
		log.Fatal("Failed to query tables:", err)
	}

	for i, table := range tables {
		fmt.Printf("%d. %s\n", i+1, table)
	}

	fmt.Println("\n✅ 表清理和数据迁移完成！")
}
