package main

import (
	"fmt"
	"log"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
)

type Table struct {
	TableName string `gorm:"column:table_name"`
}

type Column struct {
	ColumnName    string `gorm:"column:column_name"`
	DataType      string `gorm:"column:data_type"`
	IsNullable    string `gorm:"column:is_nullable"`
	ColumnDefault string `gorm:"column:column_default"`
}

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	fmt.Println("=== PostgreSQL Database Schema ===")

	var tables []Table
	err = db.Raw("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name").Scan(&tables).Error
	if err != nil {
		log.Fatal("Failed to query tables:", err)
	}

	for _, table := range tables {
		fmt.Printf("\n--- Table: %s ---\n", table.TableName)

		var columns []Column
		// Query for columns and their basic information, without trying to get comments from DB
		err = db.Raw(`
			SELECT 
				c.column_name, 
				c.data_type, 
				c.is_nullable, 
				c.column_default
			FROM information_schema.columns c
			WHERE c.table_schema = 'public' AND c.table_name = ?
			ORDER BY c.ordinal_position
		`, table.TableName).Scan(&columns).Error

		if err != nil {
			log.Printf("Failed to query columns for table %s: %v\n", table.TableName, err)
			continue
		}

		if len(columns) == 0 {
			fmt.Println("  (No columns found or accessible)")
		} else {
			for _, col := range columns {
				fmt.Printf("  - %s (Type: %s, Nullable: %s, Default: %s)\n",
					col.ColumnName, col.DataType, col.IsNullable, col.ColumnDefault)
			}
		}
	}
	fmt.Println("\n=== Schema Dump Complete ===")
}
