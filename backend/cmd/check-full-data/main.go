package main

import (
	"fmt"
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"
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

	fmt.Println("=== 检查当前数据状态 ===")

	// 检查各表的数据量
	var count int64

	db.Model(&models.Employee{}).Count(&count)
	fmt.Printf("员工表 (employees): %d 条记录\n", count)

	db.Model(&models.User{}).Count(&count)
	fmt.Printf("用户表 (users): %d 条记录\n", count)

	db.Model(&models.Category{}).Count(&count)
	fmt.Printf("分类表 (categories): %d 条记录\n", count)

	db.Model(&models.Dish{}).Count(&count)
	fmt.Printf("菜品表 (dishes): %d 条记录\n", count)

	db.Model(&models.DishFlavor{}).Count(&count)
	fmt.Printf("菜品口味表 (dish_flavors): %d 条记录\n", count)

	db.Model(&models.AddressBook{}).Count(&count)
	fmt.Printf("地址表 (address_books): %d 条记录\n", count)

	db.Model(&models.Order{}).Count(&count)
	fmt.Printf("订单表 (orders): %d 条记录\n", count)

	db.Model(&models.OrderDetail{}).Count(&count)
	fmt.Printf("订单明细表 (order_details): %d 条记录\n", count)

	db.Model(&models.ShoppingCart{}).Count(&count)
	fmt.Printf("购物车表 (shopping_carts): %d 条记录\n", count)

	db.Model(&models.Setmeal{}).Count(&count)
	fmt.Printf("套餐表 (setmeals): %d 条记录\n", count)

	db.Model(&models.SetmealDish{}).Count(&count)
	fmt.Printf("套餐菜品关系表 (setmeal_dishes): %d 条记录\n", count)

	fmt.Println("\n=== 详细数据示例 ===")

	// 查看员工数据（仅显示前5个）
	var employees []models.Employee
	db.Limit(5).Find(&employees)
	fmt.Printf("\n员工数据示例 (前5条):\n")
	for _, emp := range employees {
		fmt.Printf("  - ID: %d, 姓名: %s, 用户名: %s, 电话: %s, 状态: %d\n",
			emp.ID, emp.Name, emp.Username, emp.Phone, emp.Status)
	}

	// 查看分类数据
	var categories []models.Category
	db.Limit(5).Find(&categories)
	fmt.Printf("\n分类数据示例 (前5条):\n")
	for _, cat := range categories {
		fmt.Printf("  - ID: %d, 名称: %s, 类型: %d, 排序: %d, 状态: %d\n",
			cat.ID, cat.Name, cat.Type, cat.Sort, cat.Status)
	}

	// 查看菜品数据
	var dishes []models.Dish
	db.Limit(5).Find(&dishes)
	fmt.Printf("\n菜品数据示例 (前5条):\n")
	for _, dish := range dishes {
		fmt.Printf("  - ID: %d, 名称: %s, 价格: ¥%.2f, 分类ID: %d, 状态: %d\n",
			dish.ID, dish.Name, dish.Price, dish.CategoryID, dish.Status)
	}

	// 查看用户数据
	var users []models.User
	db.Limit(5).Find(&users)
	fmt.Printf("\n用户数据示例 (前5条):\n")
	for _, user := range users {
		fmt.Printf("  - ID: %d, 姓名: %s, 电话: %s, 状态: %t\n",
			user.ID, user.Name, user.Phone, user.IsActive)
	}

	fmt.Println("\n=== 数据检查完成 ===")
}
