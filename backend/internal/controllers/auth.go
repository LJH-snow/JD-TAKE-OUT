package controllers

import (
	"net/http"
	"strings"

	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// AuthController 认证控制器
type AuthController struct {
	DB      *gorm.DB
	Config  *config.Config
	JWTUtil *utils.JWTUtil
}

// LoginRequest 登录请求结构
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	UserType string `json:"user_type"` // admin(管理员) 或 user(用户)
}

// RegisterRequest 注册请求结构
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
	Phone    string `json:"phone" binding:"required"`
	Email    string `json:"email"`
}

// Login 用户登录
func (ac *AuthController) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误: " + err.Error(),
		})
		return
	}

	// 默认为管理员登录
	if req.UserType == "" {
		req.UserType = "admin"
	}

	if req.UserType == "admin" {
		// 管理员登录
		ac.adminLogin(c, req)
	} else {
		// 用户登录
		ac.userLogin(c, req)
	}
}

// adminLogin 管理员登录
func (ac *AuthController) adminLogin(c *gin.Context, req LoginRequest) {
	var employee models.Employee
	err := ac.DB.Where("username = ? AND status = ?", req.Username, 1).First(&employee).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "用户名或密码错误",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "服务器错误",
		})
		return
	}

	// 验证密码
	if !utils.CheckPassword(req.Password, employee.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "用户名或密码错误",
		})
		return
	}

	// 生成Token
	token, err := ac.JWTUtil.GenerateToken(employee.ID, employee.Username, "admin")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "Token生成失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "登录成功",
		"data": gin.H{
			"token": token,
			"user": gin.H{
				"id":       employee.ID,
				"username": employee.Username,
				"name":     employee.Name,
				"role":     "admin",
			},
		},
	})
}

// userLogin 用户登录
func (ac *AuthController) userLogin(c *gin.Context, req LoginRequest) {
	var user models.User
	err := ac.DB.Where("phone = ? AND is_active = ?", req.Username, true).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "用户不存在或已禁用",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "服务器错误",
		})
		return
	}

	// 对于普通用户，可以支持密码登录或短信验证码登录
	// 这里简化处理，如果用户没有设置密码，则不验证密码
	if user.Password != "" {
		if !utils.CheckPassword(req.Password, user.Password) {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "密码错误",
			})
			return
		}
	}

	// 生成Token
	token, err := ac.JWTUtil.GenerateToken(user.ID, user.Phone, "user")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "Token生成失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "登录成功",
		"data": gin.H{
			"token": token,
			"user": gin.H{
				"id":    user.ID,
				"name":  user.Name,
				"phone": user.Phone,
				"role":  "user",
			},
		},
	})
}

// Register 用户注册
func (ac *AuthController) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误: " + err.Error(),
		})
		return
	}

	// 检查用户是否已存在
	var existingUser models.User
	err := ac.DB.Where("phone = ?", req.Phone).First(&existingUser).Error
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"code":    409,
			"message": "手机号已注册",
		})
		return
	}

	// 密码加密
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "密码加密失败",
		})
		return
	}

	// 创建用户
	user := models.User{
		Name:     req.Name,
		Phone:    req.Phone,
		Email:    req.Email,
		Password: hashedPassword,
		IsActive: true,
	}

	if err := ac.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "用户创建失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "注册成功",
		"data": gin.H{
			"user_id": user.ID,
		},
	})
}

// RefreshToken 刷新令牌
func (ac *AuthController) RefreshToken(c *gin.Context) {
	// 从请求头获取当前的Token
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "请提供认证令牌",
		})
		return
	}

	// 解析Bearer Token
	parts := strings.SplitN(authHeader, " ", 2)
	if !(len(parts) == 2 && parts[0] == "Bearer") {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "认证令牌格式错误",
		})
		return
	}

	// 刷新Token
	newToken, err := ac.JWTUtil.RefreshToken(parts[1])
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "Token刷新失败: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "令牌刷新成功",
		"data": gin.H{
			"token": newToken,
		},
	})
}
