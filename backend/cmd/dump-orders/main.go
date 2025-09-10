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

	fmt.Println("--- Querying for orders in August 2025 ---")

	startDate := time.Date(2025, 8, 1, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(2025, 8, 31, 23, 59, 59, 0, time.UTC)

	var orders []models.Order
	db.Select("id", "amount", "order_time").
		Where("order_time >= ? AND order_time <= ? AND status = ?", startDate, endDate, 5).
		Order("order_time DESC").
		Find(&orders)

	if len(orders) == 0 {
		fmt.Println("Result: No completed orders found in August 2025.")
		return
	}

	fmt.Printf("Found %d completed orders in August 2025:\n", len(orders))
	fmt.Println("-------------------------------------------------")
	fmt.Println("Order ID\tAmount\tOrder Time")
	fmt.Println("-------------------------------------------------")

	for _, order := range orders {
		fmt.Printf("%d\t\t%.2f\t%s\n", order.ID, order.Amount, order.OrderTime.Format("2006-01-02 15:04:05"))
	}
	fmt.Println("-------------------------------------------------")
}