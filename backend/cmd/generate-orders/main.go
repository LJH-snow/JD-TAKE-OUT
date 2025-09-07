package main

import (
	"fmt"
	"log"
	"math/rand"
	"time"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/models"

	"gorm.io/gorm"
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

	fmt.Println("开始生成订单数据...")

	// 检查是否已有订单数据
	var orderCount int64
	db.Model(&models.Order{}).Count(&orderCount)
	if orderCount > 0 {
		fmt.Printf("已存在 %d 个订单，清空后重新创建...\n", orderCount)
		// 清空现有订单数据
		db.Exec("DELETE FROM order_details")
		db.Exec("DELETE FROM orders")
		db.Exec("ALTER SEQUENCE orders_id_seq RESTART WITH 1")
		db.Exec("ALTER SEQUENCE order_details_id_seq RESTART WITH 1")
	}

	// 获取用户和菜品数据
	var users []models.User
	var dishes []models.Dish

	db.Find(&users)
	db.Find(&dishes)

	if len(users) == 0 || len(dishes) == 0 {
		log.Fatal("缺少基础数据，请先运行用户和菜品初始化")
	}

	fmt.Printf("用户数量: %d, 菜品数量: %d\n", len(users), len(dishes))

	// 生成过去30天的订单数据
	rand.Seed(time.Now().UnixNano())
	orderNumber := 1

	for days := 30; days >= 0; days-- {
		orderDate := time.Now().AddDate(0, 0, -days)

		// 每天生成5-15个订单
		dailyOrderCount := rand.Intn(11) + 5

		for i := 0; i < dailyOrderCount; i++ {
			order := generateRandomOrder(users, orderDate, orderNumber)
			orderNumber++

			// 创建订单
			if err := db.Create(&order).Error; err != nil {
				log.Printf("创建订单失败: %v", err)
				continue
			}

			// 为订单创建1-4个订单详情
			detailCount := rand.Intn(4) + 1
			var totalAmount float64

			for j := 0; j < detailCount; j++ {
				dish := dishes[rand.Intn(len(dishes))]
				quantity := rand.Intn(3) + 1
				amount := dish.Price * float64(quantity)
				totalAmount += amount

				detail := models.OrderDetail{
					Name:    dish.Name,
					OrderID: order.ID,
					DishID:  &dish.ID,
					Number:  quantity,
					Amount:  amount,
					Image:   dish.Image,
				}

				if err := db.Create(&detail).Error; err != nil {
					log.Printf("创建订单详情失败: %v", err)
				}
			}

			// 更新订单总金额
			db.Model(&order).Update("amount", totalAmount)
		}

		fmt.Printf("生成 %s 的 %d 个订单\n", orderDate.Format("2006-01-02"), dailyOrderCount)
	}

	// 统计生成结果
	var finalOrderCount, finalDetailCount int64
	db.Model(&models.Order{}).Count(&finalOrderCount)
	db.Model(&models.OrderDetail{}).Count(&finalDetailCount)

	fmt.Printf("\n✅ 订单数据生成完成!\n")
	fmt.Printf("总订单数: %d\n", finalOrderCount)
	fmt.Printf("总订单详情数: %d\n", finalDetailCount)

	// 显示统计信息
	showOrderStats(db)
}

func generateRandomOrder(users []models.User, orderDate time.Time, orderNumber int) models.Order {
	user := users[rand.Intn(len(users))]

	// 随机生成订单时间（当天的随机时间）
	hour := rand.Intn(24)
	minute := rand.Intn(60)
	orderTime := time.Date(orderDate.Year(), orderDate.Month(), orderDate.Day(), hour, minute, 0, 0, time.Local)

	// 大部分订单是已完成状态
	status := models.OrderStatusCompleted
	if rand.Float32() < 0.1 { // 10%的订单是其他状态
		statuses := []int{
			models.OrderStatusPending,
			models.OrderStatusConfirmed,
			models.OrderStatusDelivering,
			models.OrderStatusCancelled,
		}
		status = statuses[rand.Intn(len(statuses))]
	}

	// 随机支付方式
	payMethods := []int{models.PayMethodWechat, models.PayMethodAlipay}
	payMethod := payMethods[rand.Intn(len(payMethods))]

	payStatus := models.PayStatusPaid
	if status == models.OrderStatusCancelled {
		payStatus = models.PayStatusRefund
	}

	order := models.Order{
		Number:        fmt.Sprintf("ORDER%s%04d", orderTime.Format("20060102"), orderNumber),
		Status:        status,
		UserID:        user.ID,
		AddressBookID: 1, // 假设使用第一个地址
		OrderTime:     orderTime,
		PayMethod:     payMethod,
		PayStatus:     payStatus,
		Amount:        0, // 稍后更新
		Phone:         user.Phone,
		Address:       "北京市朝阳区建国门外大街1号",
		UserName:      user.Name,
		Consignee:     user.Name,
		Remark:        generateRandomRemark(),
	}

	// 如果是已完成订单，设置结账时间和配送时间
	if status == models.OrderStatusCompleted {
		checkoutTime := orderTime.Add(time.Minute * time.Duration(rand.Intn(30)+10))
		deliveryTime := checkoutTime.Add(time.Minute * time.Duration(rand.Intn(40)+20))
		order.CheckoutTime = &checkoutTime
		order.DeliveryTime = &deliveryTime
	}

	return order
}

func generateRandomRemark() string {
	remarks := []string{
		"",
		"不要香菜",
		"少放辣椒",
		"多加米饭",
		"打包好一点",
		"送餐快一点",
		"不要葱",
		"口味清淡一些",
	}
	return remarks[rand.Intn(len(remarks))]
}

func showOrderStats(db *gorm.DB) {
	fmt.Println("\n=== 订单统计信息 ===")

	// 总营业额
	var totalRevenue float64
	db.Model(&models.Order{}).
		Where("status = ?", models.OrderStatusCompleted).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalRevenue)
	fmt.Printf("总营业额: ¥%.2f\n", totalRevenue)

	// 按状态统计订单
	var statusStats []struct {
		Status string `json:"status"`
		Count  int64  `json:"count"`
	}

	db.Model(&models.Order{}).
		Select("status, COUNT(*) as count").
		Group("status").
		Scan(&statusStats)

	fmt.Println("订单状态分布:")
	statusNames := map[int]string{
		1: "待付款",
		2: "待接单",
		3: "已接单",
		4: "派送中",
		5: "已完成",
		6: "已取消",
	}

	for _, stat := range statusStats {
		statusInt := 0
		fmt.Sscanf(stat.Status, "%d", &statusInt)
		name := statusNames[statusInt]
		if name == "" {
			name = "未知状态"
		}
		fmt.Printf("  %s: %d 订单\n", name, stat.Count)
	}

	// 最近7天每日统计
	fmt.Println("\n最近7天销售统计:")
	var dailyStats []struct {
		Date    string  `json:"date"`
		Revenue float64 `json:"revenue"`
		Orders  int64   `json:"orders"`
	}

	db.Raw(`
		SELECT 
			DATE(order_time) as date,
			COALESCE(SUM(amount), 0) as revenue,
			COUNT(*) as orders
		FROM orders 
		WHERE order_time >= CURRENT_DATE - INTERVAL '7 days'
			AND status = 5
		GROUP BY DATE(order_time)
		ORDER BY date DESC
	`).Scan(&dailyStats)

	for _, stat := range dailyStats {
		fmt.Printf("  %s: ¥%.2f (%d单)\n", stat.Date, stat.Revenue, stat.Orders)
	}
}
