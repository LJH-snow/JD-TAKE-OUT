package main

import (
	"fmt"
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"
	"log"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 连接数据库
	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// 创建测试员工账号
	employees := []struct {
		Name     string
		Username string
		Password string
		Phone    string
		Sex      string
		IdNumber string
	}{
		{
			Name:     "张三",
			Username: "zhangsan",
			Password: "123456",
			Phone:    "13800138001",
			Sex:      "1",
			IdNumber: "110101199001011234",
		},
		{
			Name:     "李四",
			Username: "lisi",
			Password: "123456",
			Phone:    "13800138002",
			Sex:      "1",
			IdNumber: "110101199002021234",
		},
		{
			Name:     "王五",
			Username: "wangwu",
			Password: "123456",
			Phone:    "13800138003",
			Sex:      "0",
			IdNumber: "110101199003031234",
		},
	}

	for _, emp := range employees {
		// 检查员工是否已存在
		var existingEmployee models.Employee
		if err := db.Where("username = ?", emp.Username).First(&existingEmployee).Error; err == nil {
			fmt.Printf("员工 %s (%s) 已存在，跳过创建\n", emp.Name, emp.Username)
			continue
		}

		// 密码加密
		hashedPassword, err := utils.HashPassword(emp.Password)
		if err != nil {
			log.Printf("密码加密失败 for %s: %v", emp.Username, err)
			continue
		}

		// 创建员工
		employee := models.Employee{
			Name:       emp.Name,
			Username:   emp.Username,
			Password:   hashedPassword,
			Phone:      emp.Phone,
			Sex:        emp.Sex,
			IdNumber:   emp.IdNumber,
			Status:     1, // 启用状态
			CreateUser: 1, // 由admin创建
			UpdateUser: 1,
		}

		if err := db.Create(&employee).Error; err != nil {
			log.Printf("创建员工失败 %s: %v", emp.Username, err)
			continue
		}

		fmt.Printf("✅ 成功创建员工: %s (用户名: %s, 密码: %s)\n", emp.Name, emp.Username, emp.Password)
	}

	fmt.Println("\n🎉 测试员工账号创建完成！")
	fmt.Println("\n📋 员工登录信息:")
	fmt.Println("用户名: zhangsan, 密码: 123456 (张三)")
	fmt.Println("用户名: lisi, 密码: 123456 (李四)")
	fmt.Println("用户名: wangwu, 密码: 123456 (王五)")
	fmt.Println("\n💡 这些员工账号可以登录管理端，但只有员工权限，无法访问管理员功能")
}