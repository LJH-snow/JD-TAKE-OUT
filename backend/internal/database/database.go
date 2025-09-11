package database

import (
	"fmt"
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/models"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Connect(cfg *config.Config) (*gorm.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		cfg.Database.Host,
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.Port,
		cfg.Database.SSLMode,
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})

	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	log.Println("Database connection established successfully")
	return db, nil
}

func Migrate(db *gorm.DB) error {
	// 一个一个表进行迁移，更好地处理错误
	models := []interface{}{
		&models.User{},
		&models.Employee{},
		&models.Category{},
		&models.Dish{},
		&models.DishFlavor{},
		&models.AddressBook{},
		&models.Order{},
		&models.OrderDetail{},
		&models.ShoppingCart{},
		&models.Setmeal{},
		&models.SetmealDish{},
		&models.StoreSetting{},
	}

	for _, model := range models {
		if err := db.AutoMigrate(model); err != nil {
			log.Printf("Warning: Failed to migrate model %T: %v", model, err)
			// 继续处理其他模型
		}
	}

	log.Println("Database migration completed")
	return nil
}
