package models

import (
	"time"

	"gorm.io/gorm"
)

// Order 订单模型
type Order struct {
	ID                    uint           `json:"id" gorm:"primarykey"`
	Number                string         `json:"number" gorm:"size:50"`                      // 订单号
	Status                int            `json:"status" gorm:"default:1;not null"`           // 订单状态
	UserID                uint           `json:"user_id" gorm:"not null"`                    // 用户ID
	AddressBookID         uint           `json:"address_book_id" gorm:"not null"`            // 地址ID
	OrderTime             time.Time      `json:"order_time" gorm:"not null"`                 // 下单时间
	CheckoutTime          *time.Time     `json:"checkout_time"`                              // 结账时间
	PayMethod             int            `json:"pay_method" gorm:"default:1;not null"`       // 支付方式
	PayStatus             int            `json:"pay_status" gorm:"default:0;not null"`       // 支付状态
	Amount                float64        `json:"amount" gorm:"type:decimal(10,2);not null"`  // 实收金额
	Remark                string         `json:"remark" gorm:"size:100"`                     // 备注
	Phone                 string         `json:"phone" gorm:"size:11"`                       // 电话
	Address               string         `json:"address" gorm:"size:255"`                    // 地址
	UserName              string         `json:"user_name" gorm:"size:32"`                   // 用户名
	Consignee             string         `json:"consignee" gorm:"size:32"`                   // 收货人
	CancelReason          string         `json:"cancel_reason" gorm:"size:255"`              // 取消原因
	RejectionReason       string         `json:"rejection_reason" gorm:"size:255"`           // 拒绝原因
	CancelTime            *time.Time     `json:"cancel_time"`                                // 取消时间
	EstimatedDeliveryTime *time.Time     `json:"estimated_delivery_time"`                    // 预计送达时间
	DeliveryStatus        int            `json:"delivery_status" gorm:"default:1;not null"`  // 配送状态
	DeliveryTime          *time.Time     `json:"delivery_time"`                              // 送达时间
	PackAmount            int            `json:"pack_amount"`                                // 打包费
	TablewareNumber       int            `json:"tableware_number"`                           // 餐具数量
	TablewareStatus       int            `json:"tableware_status" gorm:"default:1;not null"` // 餐具数量状态
	CreatedAt             time.Time      `json:"created_at"`
	UpdatedAt             time.Time      `json:"updated_at"`
	DeletedAt             gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	User         User          `json:"user" gorm:"foreignKey:UserID"`
	AddressBook  AddressBook   `json:"address_book" gorm:"foreignKey:AddressBookID"`
	OrderDetails []OrderDetail `json:"order_details" gorm:"foreignKey:OrderID"`
}

// OrderDetail 订单明细模型
type OrderDetail struct {
	ID         uint           `json:"id" gorm:"primarykey"`
	Name       string         `json:"name" gorm:"size:32"`
	Image      string         `json:"image" gorm:"size:255"`
	OrderID    uint           `json:"order_id" gorm:"not null"`
	DishID     *uint          `json:"dish_id"`
	SetmealID  *uint          `json:"setmeal_id"`
	DishFlavor string         `json:"dish_flavor" gorm:"size:50"`
	Number     int            `json:"number" gorm:"default:1;not null"`
	Amount     float64        `json:"amount" gorm:"type:decimal(10,2);not null"`
	CreatedAt  time.Time      `json:"created_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// ShoppingCart 购物车模型
type ShoppingCart struct {
	ID         uint           `json:"id" gorm:"primarykey"`
	Name       string         `json:"name" gorm:"size:32"`
	Image      string         `json:"image" gorm:"size:255"`
	UserID     uint           `json:"user_id" gorm:"not null"`
	DishID     *uint          `json:"dish_id"`
	SetmealID  *uint          `json:"setmeal_id"`
	DishFlavor string         `json:"dish_flavor" gorm:"size:50"`
	Number     int            `json:"number" gorm:"default:1;not null"`
	Amount     float64        `json:"amount" gorm:"type:decimal(10,2);not null"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// Setmeal 套餐模型
type Setmeal struct {
	ID          uint           `json:"id" gorm:"primarykey"`
	CategoryID  uint           `json:"category_id" gorm:"not null"`
	Name        string         `json:"name" gorm:"size:32;uniqueIndex;not null"`
	Price       float64        `json:"price" gorm:"type:decimal(10,2);not null"`
	Status      int            `json:"status" gorm:"default:1"`
	Description string         `json:"description" gorm:"size:255"`
	Image       string         `json:"image" gorm:"size:255"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	CreateUser  uint           `json:"create_user"`
	UpdateUser  uint           `json:"update_user"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	Category      Category      `json:"category" gorm:"foreignKey:CategoryID"`
	SetmealDishes []SetmealDish `json:"setmeal_dishes" gorm:"foreignKey:SetmealID"`
}

// SetmealDish 套餐菜品关系模型
type SetmealDish struct {
	ID        uint    `json:"id" gorm:"primarykey"`
	SetmealID uint    `json:"setmeal_id"`
	DishID    uint    `json:"dish_id"`
	Name      string  `json:"name" gorm:"size:32"`
	Price     float64 `json:"price" gorm:"type:decimal(10,2)"`
	Copies    int     `json:"copies"`
}

// 常量定义
const (
	// 订单状态
	OrderStatusPending    = 1 // 待付款
	OrderStatusWaiting    = 2 // 待接单
	OrderStatusConfirmed  = 3 // 已接单
	OrderStatusDelivering = 4 // 派送中
	OrderStatusCompleted  = 5 // 已完成
	OrderStatusCancelled  = 6 // 已取消
	OrderStatusRefunded   = 7 // 退款

	// 支付状态
	PayStatusUnpaid = 0 // 未支付
	PayStatusPaid   = 1 // 已支付
	PayStatusRefund = 2 // 退款

	// 支付方式
	PayMethodWechat = 1 // 微信支付
	PayMethodAlipay = 2 // 支付宝

	// 商品状态
	StatusDisabled = 0 // 禁用/停售
	StatusEnabled  = 1 // 启用/起售

	// 分类类型
	CategoryTypeDish    = 1 // 菜品分类
	CategoryTypeSetmeal = 2 // 套餐分类
)

// GetStatusText 返回订单状态的文本描述
func (o *Order) GetStatusText() string {
	switch o.Status {
	case OrderStatusPending:
		return "待付款"
	case OrderStatusWaiting:
		return "待接单"
	case OrderStatusConfirmed:
		return "已接单"
	case OrderStatusDelivering:
		return "派送中"
	case OrderStatusCompleted:
		return "已完成"
	case OrderStatusCancelled:
		return "已取消"
	case OrderStatusRefunded:
		return "已退款"
	default:
		return "未知状态"
	}
}