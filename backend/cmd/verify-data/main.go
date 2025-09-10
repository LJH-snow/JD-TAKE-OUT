package main

import (
	"fmt"
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"
	"log"
	"time"
)

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	fmt.Println("--- Verifying Data Directly From Database ---")

	// --- Last 7 Days ---
	endDate7 := time.Date(2025, 9, 9, 23, 59, 59, 0, time.UTC)
	startDate7 := endDate7.AddDate(0, 0, -6)
	startDate7Str := startDate7.Format("2006-01-02")
	endDate7Str := endDate7.Format("2006-01-02")

	var totalRevenue7 float64
	var validOrders7 int64

	db.Model(&models.Order{}).
		Select("COALESCE(SUM(amount), 0)").
		Where("DATE(order_time) BETWEEN ? AND ?", startDate7Str, endDate7Str).
		Where("status = ?", 5).
		Row().Scan(&totalRevenue7)

	db.Model(&models.Order{}).
		Where("DATE(order_time) BETWEEN ? AND ?", startDate7Str, endDate7Str).
		Where("status = ?", 5).
		Count(&validOrders7)

	fmt.Printf("\n[Query for Last 7 Days (%s to %s)]\n", startDate7Str, endDate7Str)
	fmt.Printf("DB Result -> Total Revenue: %.2f\n", totalRevenue7)
	fmt.Printf("DB Result -> Valid Orders: %d\n", validOrders7)

	// --- Last 30 Days ---
	endDate30 := time.Date(2025, 9, 9, 23, 59, 59, 0, time.UTC)
	startDate30 := endDate30.AddDate(0, 0, -29)
	startDate30Str := startDate30.Format("2006-01-02")
	endDate30Str := endDate30.Format("2006-01-02")

	var totalRevenue30 float64
	var validOrders30 int64

	db.Model(&models.Order{}).
		Select("COALESCE(SUM(amount), 0)").
		Where("DATE(order_time) BETWEEN ? AND ?", startDate30Str, endDate30Str).
		Where("status = ?", 5).
		Row().Scan(&totalRevenue30)

	db.Model(&models.Order{}).
		Where("DATE(order_time) BETWEEN ? AND ?", startDate30Str, endDate30Str).
		Where("status = ?", 5).
		Count(&validOrders30)

	fmt.Printf("\n[Query for Last 30 Days (%s to %s)]\n", startDate30Str, endDate30Str)
	fmt.Printf("DB Result -> Total Revenue: %.2f\n", totalRevenue30)
	fmt.Printf("DB Result -> Valid Orders: %d\n", validOrders30)

	fmt.Println("\n--- Verification Complete ---")
}
