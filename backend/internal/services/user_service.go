package services

import (
	"jd-take-out-backend/internal/models"

	"gorm.io/gorm"
)

// UserService 用户服务
type UserService struct {
	db *gorm.DB
}

// NewUserService 创建用户服务实例
func NewUserService(db *gorm.DB) *UserService {
	return &UserService{db: db}
}

// CreateUser 创建用户
func (s *UserService) CreateUser(user *models.User) error {
	return s.db.Create(user).Error
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(id uint) (*models.User, error) {
	var user models.User
	err := s.db.First(&user, id).Error
	return &user, err
}

// GetUserByOpenID 根据OpenID获取用户
func (s *UserService) GetUserByOpenID(openID string) (*models.User, error) {
	var user models.User
	err := s.db.Where("openid = ?", openID).First(&user).Error
	return &user, err
}

// UpdateUser 更新用户信息
func (s *UserService) UpdateUser(user *models.User) error {
	return s.db.Save(user).Error
}

// AuthService 认证服务
type AuthService struct {
	db *gorm.DB
}

// NewAuthService 创建认证服务实例
func NewAuthService(db *gorm.DB) *AuthService {
	return &AuthService{db: db}
}

// EmployeeLogin 员工登录
func (s *AuthService) EmployeeLogin(username, password string) (*models.Employee, error) {
	var employee models.Employee
	err := s.db.Where("username = ? AND status = ?", username, models.StatusEnabled).First(&employee).Error
	if err != nil {
		return nil, err
	}

	// TODO: 验证密码（使用bcrypt）
	// if !CheckPassword(password, employee.Password) {
	//     return nil, errors.New("password incorrect")
	// }

	return &employee, nil
}

// DishService 菜品服务
type DishService struct {
	db *gorm.DB
}

// NewDishService 创建菜品服务实例
func NewDishService(db *gorm.DB) *DishService {
	return &DishService{db: db}
}

// GetDishes 获取菜品列表
func (s *DishService) GetDishes(categoryID uint, status int, page, pageSize int) ([]models.Dish, int64, error) {
	var dishes []models.Dish
	var total int64

	query := s.db.Model(&models.Dish{}).Preload("Category").Preload("DishFlavors")

	if categoryID > 0 {
		query = query.Where("category_id = ?", categoryID)
	}
	if status >= 0 {
		query = query.Where("status = ?", status)
	}

	// 计算总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * pageSize
	err := query.Offset(offset).Limit(pageSize).Find(&dishes).Error

	return dishes, total, err
}

// GetDishByID 根据ID获取菜品
func (s *DishService) GetDishByID(id uint) (*models.Dish, error) {
	var dish models.Dish
	err := s.db.Preload("Category").Preload("DishFlavors").First(&dish, id).Error
	return &dish, err
}

// CreateDish 创建菜品
func (s *DishService) CreateDish(dish *models.Dish) error {
	return s.db.Create(dish).Error
}

// UpdateDish 更新菜品
func (s *DishService) UpdateDish(dish *models.Dish) error {
	return s.db.Save(dish).Error
}

// DeleteDish 删除菜品
func (s *DishService) DeleteDish(id uint) error {
	return s.db.Delete(&models.Dish{}, id).Error
}
