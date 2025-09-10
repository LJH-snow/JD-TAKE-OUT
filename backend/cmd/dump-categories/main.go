package main

import (
	"fmt"
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"
	"log"
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

	fmt.Println("--- Dumping Categories Table --- ")

	var categories []models.Category
	db.Find(&categories)

	if len(categories) == 0 {
		fmt.Println("Result: No records found in the categories table.")
		return
	}

	fmt.Printf("Found %d records in categories table:\n", len(categories))
	fmt.Println("-------------------------------------------------")
	fmt.Println("ID\tName\t\tType\tStatus")
	fmt.Println("-------------------------------------------------")

	for _, cat := range categories {
		fmt.Printf("%d\t%s\t\t%d\t%d\n", cat.ID, cat.Name, cat.Type, cat.Status)
	}
	fmt.Println("-------------------------------------------------")
}

