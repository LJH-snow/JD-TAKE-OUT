package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID            uint           `json:"id" gorm:"primarykey"`
	OpenID        string         `json:"openid" gorm:"column:openid;size:45"`
	Name          string         `json:"name" gorm:"size:32"`
	Phone         string         `json:"phone" gorm:"size:11;unique"`
	Email         string         `json:"email" gorm:"size:100"`
	Password      string         `json:"-" gorm:"size:64"`
	Sex           string         `json:"sex" gorm:"size:2"`
	Avatar        string         `json:"avatar" gorm:"size:500"`
	LoginType     int            `json:"login_type" gorm:"default:1"`
	LastLoginTime *time.Time     `json:"last_login_time"`
	IsActive      bool           `json:"is_active" gorm:"default:true"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`
}

// Employee 员工模型
type Employee struct {
	ID         uint           `json:"id" gorm:"primarykey"`
	Name       string         `json:"name" gorm:"size:32;not null"`
	Username   string         `json:"username" gorm:"size:32;uniqueIndex;not null"`
	Password   string         `json:"-" gorm:"size:64;not null"`
	Phone      string         `json:"phone" gorm:"size:11;not null"`
	Sex        string         `json:"sex" gorm:"size:2;not null"`
	IdNumber   string         `json:"id_number" gorm:"column:id_number;size:18;not null"`
	Status     int            `json:"status" gorm:"default:1;not null"` // 0:禁用 1:启用
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	CreateUser uint           `json:"create_user"`
	UpdateUser uint           `json:"update_user"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// Category 分类模型
type Category struct {
	ID         uint           `json:"id" gorm:"primarykey"`
	Type       int            `json:"type"`                                     // 1:菜品分类 2:套餐分类
	Name       string         `json:"name" gorm:"size:32;uniqueIndex;not null"` // 分类名称唯一
	Sort       int            `json:"sort" gorm:"default:0;not null"`           // 排序
	Status     int            `json:"status"`                                   // 0:禁用 1:启用
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	CreateUser uint           `json:"create_user"`
	UpdateUser uint           `json:"update_user"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// Dish 菜品模型
type Dish struct {
	ID          uint           `json:"id" gorm:"primarykey"`
	Name        string         `json:"name" gorm:"size:32;uniqueIndex;not null"` // 菜品名称唯一
	CategoryID  uint           `json:"category_id" gorm:"not null"`              // 分类ID
	Price       float64        `json:"price" gorm:"type:decimal(10,2);default:0"`
	Code        string         `json:"code" gorm:"size:32;uniqueIndex"` // 菜品编码
	Image       string         `json:"image" gorm:"size:255"`
	Description string         `json:"description" gorm:"size:255"`
	Status      int            `json:"status" gorm:"default:1"` // 0:停售 1:起售
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	CreateUser  uint           `json:"create_user"`
	UpdateUser  uint           `json:"update_user"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	Category    Category     `json:"category" gorm:"foreignKey:CategoryID"`
	DishFlavors []DishFlavor `json:"flavors" gorm:"foreignKey:DishID"`
}

// DishFlavor 菜品口味模型
type DishFlavor struct {
	ID     uint   `json:"id" gorm:"primarykey"`
	DishID uint   `json:"dish_id" gorm:"not null"`
	Name   string `json:"name" gorm:"size:32"`
	Value  string `json:"value" gorm:"size:255"`
}

// AddressBook 地址簿模型
type AddressBook struct {
	ID               uint           `json:"id" gorm:"primarykey"`
	UserID           uint           `json:"user_id" gorm:"not null"`
	Consignee        string         `json:"consignee" gorm:"size:50"`
	Sex              string         `json:"sex" gorm:"size:2"`
	Phone            string         `json:"phone" gorm:"size:11;not null"`
	ProvinceCode     string         `json:"province_code" gorm:"size:12"`
	ProvinceName     string         `json:"province_name" gorm:"size:32"`
	CityCode         string         `json:"city_code" gorm:"size:12"`
	CityName         string         `json:"city_name" gorm:"size:32"`
	DistrictCode     string         `json:"district_code" gorm:"size:12"`
	DistrictName     string         `json:"district_name" gorm:"size:32"`
	Detail           string         `json:"detail" gorm:"size:200"`
	Label            string         `json:"label" gorm:"size:100"`
	IsDefault        int            `json:"is_default" gorm:"default:0"`         // 默认地址 0:非默认 1:默认
	Longitude        float64        `json:"longitude" gorm:"type:decimal(10,7)"` // 经度
	Latitude         float64        `json:"latitude" gorm:"type:decimal(10,7)"`  // 纬度
	FormattedAddress string         `json:"formatted_address" gorm:"size:500"`   // 格式化地址
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `json:"-" gorm:"index"`
}

// StoreSetting 店铺设置模型
type StoreSetting struct {
	ID          uint           `json:"id" gorm:"primarykey"`
	Name        string         `json:"name" gorm:"size:100;not null"`
	Address     string         `json:"address" gorm:"size:255"`
	Phone       string         `json:"phone" gorm:"size:20"`
	Description string         `json:"description" gorm:"size:500"`
	Logo        string         `json:"logo" gorm:"size:255"`
	IsOpen      bool           `json:"is_open" gorm:"default:true"` // Added field
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	CreateUser  uint           `json:"create_user"`
	UpdateUser  uint           `json:"update_user"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}