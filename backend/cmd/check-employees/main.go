package main

import (
	"fmt"
	"log"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"
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

	fmt.Println("=== 管理员账户信息 ===")

	var employees []models.Employee
	err = db.Find(&employees).Error
	if err != nil {
		fmt.Printf("查询失败: %v\n", err)
		return
	}

	fmt.Printf("找到 %d 个员工账户:\n", len(employees))
	for _, emp := range employees {
		fmt.Printf("ID: %d, 姓名: %s, 用户名: %s, 手机: %s, 状态: %d\n",
			emp.ID, emp.Name, emp.Username, emp.Phone, emp.Status)
	}
}
