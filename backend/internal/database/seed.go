package database

import (
	"fmt"
	"log"
	"time"

	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"

	"gorm.io/gorm"
)

// SeedData 初始化基础测试数据
func SeedData(db *gorm.DB) error {
	log.Println("开始初始化基础测试数据...")

	// 检查是否已有数据，避免重复初始化
	var employeeCount int64
	db.Model(&models.Employee{}).Count(&employeeCount)
	var orderCount int64
	db.Model(&models.Order{}).Count(&orderCount)
	var userCount int64
	db.Model(&models.User{}).Count(&userCount)

	if employeeCount > 0 && orderCount > 0 && userCount > 0 {
		log.Println("检测到已有完整数据，跳过数据初始化")
		return nil
	}

	// 如果数据不完整，需要完整重新初始化

	// 1. 创建管理员账户
	if err := seedEmployees(db); err != nil {
		return err
	}

	// 2. 创建菜品分类
	if err := seedCategories(db); err != nil {
		return err
	}

	// 3. 创建示例菜品
	if err := seedDishes(db); err != nil {
		return err
	}

	// 4. 创建测试用户
	if err := seedUsers(db); err != nil {
		return err
	}

	// 5. 创建示例套餐
	if err := seedSetmeals(db); err != nil {
		return err
	}

	// 6. 创建示例订单
	if err := CreateSampleOrders(db); err != nil {
		return err
	}

	log.Println("基础测试数据初始化完成!")
	return nil
}

// seedEmployees 创建管理员账户
func seedEmployees(db *gorm.DB) error {
	log.Println("创建管理员账户...")

	// 检查是否已存在admin用户
	var adminCount int64
	db.Model(&models.Employee{}).Where("username = ?", "admin").Count(&adminCount)
	if adminCount > 0 {
		log.Println("管理员账户已存在，跳过创建")
		return nil
	}

	// 生成加密密码 (原始密码: admin123)
	hashedPassword, err := utils.HashPassword("admin123")
	if err != nil {
		return err
	}

	employees := []models.Employee{
		{
			Name:     "系统管理员",
			Username: "admin",
			Password: hashedPassword,
			Phone:    "13800138000",
			Sex:      "1", // 1-男性
			IdNumber: "110101199001011234",
			Status:   1, // 1-启用
		},
		{
			Name:     "店长",
			Username: "manager",
			Password: hashedPassword,
			Phone:    "13800138001",
			Sex:      "0", // 0-女性
			IdNumber: "110101199002021234",
			Status:   1,
		},
	}

	for _, employee := range employees {
		if err := db.Create(&employee).Error; err != nil {
			log.Printf("创建员工 %s 失败: %v", employee.Name, err)
			return err
		}
		log.Printf("创建员工: %s (用户名: %s)", employee.Name, employee.Username)
	}

	return nil
}

// seedCategories 创建菜品分类
func seedCategories(db *gorm.DB) error {
	log.Println("创建菜品分类...")

	categories := []models.Category{
		{
			Type:       1, // 菜品分类
			Name:       "川菜",
			Sort:       1,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
		{
			Type:       1,
			Name:       "粤菜",
			Sort:       2,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
		{
			Type:       1,
			Name:       "湘菜",
			Sort:       3,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
		{
			Type:       1,
			Name:       "鲁菜",
			Sort:       4,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
		{
			Type:       2, // 套餐分类
			Name:       "商务套餐",
			Sort:       1,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
		{
			Type:       2,
			Name:       "儿童套餐",
			Sort:       2,
			Status:     1,
			CreateUser: 1,
			UpdateUser: 1,
		},
	}

	for _, category := range categories {
		if err := db.Create(&category).Error; err != nil {
			log.Printf("创建分类 %s 失败: %v", category.Name, err)
			return err
		}
		log.Printf("创建分类: %s (类型: %s)", category.Name,
			map[int]string{1: "菜品", 2: "套餐"}[category.Type])
	}

	return nil
}

// seedDishes 创建示例菜品
func seedDishes(db *gorm.DB) error {
	log.Println("创建示例菜品...")

	// 动态获取分类ID
	var categories []models.Category
	err := db.Find(&categories).Error
	if err != nil {
		return fmt.Errorf("获取分类失败: %w", err)
	}

	if len(categories) < 4 {
		return fmt.Errorf("分类数量不足，需要至少4个分类")
	}

	// 按类型分组分类
	dishCategories := make(map[string]uint) // name -> id
	for _, cat := range categories {
		if cat.Type == 1 { // 菜品分类
			dishCategories[cat.Name] = cat.ID
		}
	}

	// 确保有必要的分类
	requiredCategories := []string{"川菜", "粤菜", "湘菜", "鲁菜"}
	for _, required := range requiredCategories {
		if _, exists := dishCategories[required]; !exists {
			return fmt.Errorf("缺少必要的分类: %s", required)
		}
	}

	dishes := []models.Dish{
		{
			Name:        "宫保鸡丁",
			CategoryID:  dishCategories["川菜"],
			Price:       28.00,
			Code:        "DISH001",
			Image:       "/images/dishes/gongbao_jiding.jpg",
			Description: "经典川菜，麻辣鲜香",
			Status:      1,
			CreateUser:  1,
			UpdateUser:  1,
		},
		{
			Name:        "麻婆豆腐",
			CategoryID:  dishCategories["川菜"],
			Price:       18.00,
			Code:        "DISH002",
			Image:       "/images/dishes/mapo_doufu.jpg",
			Description: "川菜名菜，麻辣鲜嫩",
			Status:      1,
			CreateUser:  1,
			UpdateUser:  1,
		},
		{
			Name:        "白切鸡",
			CategoryID:  dishCategories["粤菜"],
			Price:       38.00,
			Code:        "DISH003",
			Image:       "/images/dishes/baiqie_ji.jpg",
			Description: "粤式经典，清淡鲜美",
			Status:      1,
			CreateUser:  1,
			UpdateUser:  1,
		},
		{
			Name:        "剁椒鱼头",
			CategoryID:  dishCategories["湘菜"],
			Price:       58.00,
			Code:        "DISH004",
			Image:       "/images/dishes/duojiao_yutou.jpg",
			Description: "湘菜招牌，鲜辣开胃",
			Status:      1,
			CreateUser:  1,
			UpdateUser:  1,
		},
		{
			Name:        "糖醋里脊",
			CategoryID:  dishCategories["鲁菜"],
			Price:       35.00,
			Code:        "DISH005",
			Image:       "/images/dishes/tangcu_liji.jpg",
			Description: "酸甜可口，老少皆宜",
			Status:      1,
			CreateUser:  1,
			UpdateUser:  1,
		},
	}

	for _, dish := range dishes {
		if err := db.Create(&dish).Error; err != nil {
			log.Printf("创建菜品 %s 失败: %v", dish.Name, err)
			return err
		}
		log.Printf("创建菜品: %s (价格: ¥%.2f)", dish.Name, dish.Price)
	}

	// 创建菜品口味
	if err := seedDishFlavors(db); err != nil {
		return err
	}

	return nil
}

// seedDishFlavors 创建菜品口味
func seedDishFlavors(db *gorm.DB) error {
	log.Println("创建菜品口味...")

	// 动态获取菜品ID
	var dishes []models.Dish
	err := db.Find(&dishes).Error
	if err != nil {
		return fmt.Errorf("获取菜品失败: %w", err)
	}

	if len(dishes) < 2 {
		return fmt.Errorf("菜品数量不足，需要至少2个菜品")
	}

	// 按名称获取菜品ID
	dishMap := make(map[string]uint)
	for _, dish := range dishes {
		dishMap[dish.Name] = dish.ID
	}

	flavors := []models.DishFlavor{
		{
			DishID: dishMap["宫保鸡丁"],
			Name:   "辣度",
			Value:  "[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]",
		},
		{
			DishID: dishMap["宫保鸡丁"],
			Name:   "口味",
			Value:  "[\"甜味\",\"咸味\",\"酸甜\",\"麻辣\"]",
		},
		{
			DishID: dishMap["麻婆豆腐"],
			Name:   "辣度",
			Value:  "[\"微辣\",\"中辣\",\"重辣\"]",
		},
		{
			DishID: dishMap["剁椒鱼头"],
			Name:   "辣度",
			Value:  "[\"中辣\",\"重辣\",\"特辣\"]",
		},
	}

	for _, flavor := range flavors {
		// 检查菜品是否存在
		if flavor.DishID == 0 {
			log.Printf("警告: 未找到对应的菜品，跳过口味创建")
			continue
		}

		if err := db.Create(&flavor).Error; err != nil {
			log.Printf("创建口味失败: %v", err)
			return err
		}
	}

	log.Printf("创建 %d 个菜品口味选项", len(flavors))
	return nil
}

// seedUsers 创建测试用户
func seedUsers(db *gorm.DB) error {
	log.Println("创建测试用户...")

	users := []models.User{
		{
			OpenID:   "test_openid_001",
			Name:     "张三",
			Phone:    "13912345678",
			Sex:      "1",
			Avatar:   "/images/avatars/default_male.png",
			IsActive: true,
		},
		{
			OpenID:   "test_openid_002",
			Name:     "李四",
			Phone:    "13912345679",
			Sex:      "0",
			Avatar:   "/images/avatars/default_female.png",
			IsActive: true,
		},
		{
			OpenID:   "test_openid_003",
			Name:     "王五",
			Phone:    "13912345680",
			Sex:      "1",
			Avatar:   "/images/avatars/default_male.png",
			IsActive: true,
		},
	}

	for _, user := range users {
		if err := db.Create(&user).Error; err != nil {
			log.Printf("创建用户 %s 失败: %v", user.Name, err)
			return err
		}
		log.Printf("创建用户: %s (手机: %s)", user.Name, user.Phone)
	}

	// 创建用户地址
	if err := seedAddressBooks(db); err != nil {
		return err
	}

	return nil
}

// seedAddressBooks 创建用户地址
func seedAddressBooks(db *gorm.DB) error {
	log.Println("创建用户地址...")

	addresses := []models.AddressBook{
		{
			UserID:       1,
			Consignee:    "张三",
			Sex:          "1",
			Phone:        "13912345678",
			ProvinceCode: "110000",
			ProvinceName: "北京市",
			CityCode:     "110100",
			CityName:     "北京市",
			DistrictCode: "110101",
			DistrictName: "东城区",
			Detail:       "王府井大街1号",
			Label:        "家",
			IsDefault:    1,
		},
		{
			UserID:       1,
			Consignee:    "张三",
			Sex:          "1",
			Phone:        "13912345678",
			ProvinceCode: "110000",
			ProvinceName: "北京市",
			CityCode:     "110100",
			CityName:     "北京市",
			DistrictCode: "110105",
			DistrictName: "朝阳区",
			Detail:       "建国门外大街2号",
			Label:        "公司",
			IsDefault:    0,
		},
	}

	for _, address := range addresses {
		if err := db.Create(&address).Error; err != nil {
			log.Printf("创建地址失败: %v", err)
			return err
		}
	}

	log.Printf("创建 %d 个用户地址", len(addresses))
	return nil
}

// seedSetmeals 创建示例套餐
func seedSetmeals(db *gorm.DB) error {
	log.Println("创建示例套餐...")

	setmeals := []models.Setmeal{
		{
			CategoryID:  5, // 商务套餐
			Name:        "经典商务套餐",
			Price:       88.00,
			Status:      1,
			Description: "宫保鸡丁+白切鸡+米饭+汤",
			Image:       "/images/setmeals/business_classic.jpg",
			CreateUser:  1,
			UpdateUser:  1,
		},
		{
			CategoryID:  6, // 儿童套餐
			Name:        "开心儿童套餐",
			Price:       38.00,
			Status:      1,
			Description: "糖醋里脊+蒸蛋+米饭+果汁",
			Image:       "/images/setmeals/kids_happy.jpg",
			CreateUser:  1,
			UpdateUser:  1,
		},
	}

	for _, setmeal := range setmeals {
		if err := db.Create(&setmeal).Error; err != nil {
			log.Printf("创建套餐 %s 失败: %v", setmeal.Name, err)
			return err
		}
		log.Printf("创建套餐: %s (价格: ¥%.2f)", setmeal.Name, setmeal.Price)
	}

	// 创建套餐菜品关系
	if err := seedSetmealDishes(db); err != nil {
		return err
	}

	return nil
}

// seedSetmealDishes 创建套餐菜品关系
func seedSetmealDishes(db *gorm.DB) error {
	log.Println("创建套餐菜品关系...")

	setmealDishes := []models.SetmealDish{
		// 经典商务套餐
		{
			SetmealID: 1,
			DishID:    1, // 宫保鸡丁
			Name:      "宫保鸡丁",
			Price:     28.00,
			Copies:    1,
		},
		{
			SetmealID: 1,
			DishID:    3, // 白切鸡
			Name:      "白切鸡",
			Price:     38.00,
			Copies:    1,
		},
		// 开心儿童套餐
		{
			SetmealID: 2,
			DishID:    5, // 糖醋里脊
			Name:      "糖醋里脊",
			Price:     35.00,
			Copies:    1,
		},
	}

	for _, setmealDish := range setmealDishes {
		if err := db.Create(&setmealDish).Error; err != nil {
			log.Printf("创建套餐菜品关系失败: %v", err)
			return err
		}
	}

	log.Printf("创建 %d 个套餐菜品关系", len(setmealDishes))
	return nil
}

// CreateSampleOrders 创建示例订单（可选调用）
func CreateSampleOrders(db *gorm.DB) error {
	log.Println("创建示例订单...")

	orders := []models.Order{
		{
			Number:        "ORDER" + time.Now().Format("20060102150405") + "001",
			Status:        models.OrderStatusCompleted,
			UserID:        1,
			AddressBookID: 1,
			OrderTime:     time.Now().Add(-24 * time.Hour),
			CheckoutTime:  func() *time.Time { t := time.Now().Add(-23 * time.Hour); return &t }(),
			PayMethod:     models.PayMethodWechat,
			PayStatus:     models.PayStatusPaid,
			Amount:        56.00,
			Phone:         "13912345678",
			Address:       "北京市东城区王府井大街1号",
			UserName:      "张三",
			Consignee:     "张三",
			DeliveryTime:  func() *time.Time { t := time.Now().Add(-22 * time.Hour); return &t }(),
		},
		{
			Number:        "ORDER" + time.Now().Format("20060102150405") + "002",
			Status:        models.OrderStatusCompleted,
			UserID:        2,
			AddressBookID: 1,
			OrderTime:     time.Now().Add(-12 * time.Hour),
			CheckoutTime:  func() *time.Time { t := time.Now().Add(-11 * time.Hour); return &t }(),
			PayMethod:     models.PayMethodAlipay,
			PayStatus:     models.PayStatusPaid,
			Amount:        88.00,
			Phone:         "13912345679",
			Address:       "北京市朝阳区建国门外大街2号",
			UserName:      "李四",
			Consignee:     "李四",
			DeliveryTime:  func() *time.Time { t := time.Now().Add(-10 * time.Hour); return &t }(),
		},
	}

	for _, order := range orders {
		if err := db.Create(&order).Error; err != nil {
			log.Printf("创建订单失败: %v", err)
			return err
		}
		log.Printf("创建订单: %s (金额: ¥%.2f)", order.Number, order.Amount)
	}

	// 创建订单明细
	orderDetails := []models.OrderDetail{
		{
			Name:    "宫保鸡丁",
			OrderID: 1,
			DishID:  func() *uint { id := uint(1); return &id }(),
			Number:  1,
			Amount:  28.00,
		},
		{
			Name:    "麻婆豆腐",
			OrderID: 1,
			DishID:  func() *uint { id := uint(2); return &id }(),
			Number:  1,
			Amount:  18.00,
		},
		{
			Name:      "经典商务套餐",
			OrderID:   2,
			SetmealID: func() *uint { id := uint(1); return &id }(),
			Number:    1,
			Amount:    88.00,
		},
	}

	for _, detail := range orderDetails {
		if err := db.Create(&detail).Error; err != nil {
			log.Printf("创建订单明细失败: %v", err)
			return err
		}
	}

	log.Printf("创建 %d 个示例订单和明细", len(orders))
	return nil
}
