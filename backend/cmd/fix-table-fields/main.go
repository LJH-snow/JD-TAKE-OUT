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

	fmt.Println("开始修复所有表的缺失字段...")

	// 修复各表的字段
	tables := []struct {
		name   string
		fields []string
	}{
		{
			name: "categories",
			fields: []string{
				"ALTER TABLE categories ADD COLUMN IF NOT EXISTS create_user BIGINT",
				"ALTER TABLE categories ADD COLUMN IF NOT EXISTS update_user BIGINT",
				"ALTER TABLE categories ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP",
				"CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON categories(deleted_at)",
			},
		},
		{
			name: "dishes",
			fields: []string{
				"ALTER TABLE dishes ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP",
				"CREATE INDEX IF NOT EXISTS idx_dishes_deleted_at ON dishes(deleted_at)",
			},
		},
		{
			name: "setmeals",
			fields: []string{
				"ALTER TABLE setmeals ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP",
				"CREATE INDEX IF NOT EXISTS idx_setmeals_deleted_at ON setmeals(deleted_at)",
			},
		},
		{
			name: "order_details",
			fields: []string{
				"ALTER TABLE order_details ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
				"ALTER TABLE order_details ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP",
				"CREATE INDEX IF NOT EXISTS idx_order_details_deleted_at ON order_details(deleted_at)",
			},
		},
	}

	for _, table := range tables {
		fmt.Printf("\n修复 %s 表...\n", table.name)
		for _, fieldSQL := range table.fields {
			err := db.Exec(fieldSQL).Error
			if err != nil {
				log.Printf("❌ 执行失败: %s - %v", fieldSQL, err)
			} else {
				fmt.Printf("✅ 成功: %s\n", fieldSQL)
			}
		}
	}

	fmt.Println("\n✅ 表结构修复完成！")

	// 验证修复结果
	fmt.Println("\n验证表结构...")
	checkTables := []string{"categories", "dishes", "setmeals", "order_details", "orders"}

	for _, tableName := range checkTables {
		var columns []struct {
			ColumnName string `json:"column_name"`
		}

		err = db.Raw(`
			SELECT column_name 
			FROM information_schema.columns 
			WHERE table_name = ? AND table_schema = 'public'
			ORDER BY ordinal_position
		`, tableName).Scan(&columns).Error

		if err != nil {
			log.Printf("❌ 查询 %s 表结构失败: %v", tableName, err)
			continue
		}

		fmt.Printf("%s 表包含 %d 个字段\n", tableName, len(columns))
	}
}
