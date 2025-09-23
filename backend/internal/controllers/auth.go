package controllers

import (
	"log"
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

// AdminLoginRequest 管理员登录请求结构
type AdminLoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// UserLoginRequest 用户登录请求结构
type UserLoginRequest struct {
	Phone    string `json:"phone" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginRequest 登录请求结构 (用于Swaggo文档)
// 为了兼容swaggo，我们将管理员和用户的登录字段合并到一个结构体中
// user_type字段用于在后端区分登录类型
type LoginRequest struct {
	UserType string `json:"user_type" example:"user"`      // 登录类型, "admin" 或 "user"
	Username string `json:"username,omitempty" example:"admin"` // 管理员登录时使用
	Phone    string `json:"phone,omitempty" example:"13800138000"`  // 用户登录时使用
	Password string `json:"password" binding:"required"`
}

// UserRegisterRequest 用户注册请求结构
type UserRegisterRequest struct {
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
	Phone    string `json:"phone" binding:"required"`
	Email    string `json:"email"`
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
//
//	@Summary		用户与管理员统一登录接口
//	@Description	支持管理员(username+password)和普通用户(phone+password)登录。user_type字段用于区分, "admin" 或 "user"。
//	@Tags			认证
//	@Accept			json
//	@Produce		json
//	@Param			body	body	LoginRequest	true	"统一登录请求参数"
//	@Success		200	{object}	map[string]interface{}	"登录成功"
//	@Failure		400	{object}	map[string]interface{}	"请求参数错误"
//	@Failure		401	{object}	map[string]interface{}	"认证失败"
//	@Failure		500	{object}	map[string]interface{}	"服务器错误"
//	@Router			/api/v1/auth/login [post]
func (ac *AuthController) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "请求参数错误: " + err.Error()})
		return
	}

	// [DEBUG] 打印解析后的请求体
	log.Printf("[Login Debug] Parsed request: %+v", req)

	// 默认为用户登录
	if req.UserType == "" {
		req.UserType = "user"
	}

	if req.UserType == "admin" {
		// 管理员登录
		if req.Username == "" {
			c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "管理员登录需要用户名(username)"})
			return
		}
		adminReq := AdminLoginRequest{
			Username: req.Username,
			Password: req.Password,
		}
		ac.adminLogin(c, adminReq)
	} else {
		// 用户登录
		if req.Phone == "" {
			c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "用户登录需要手机号(phone)"})
			return
		}
		userReq := UserLoginRequest{
			Phone:    req.Phone,
			Password: req.Password,
		}
		ac.userLogin(c, userReq)
	}
}

// adminLogin 管理员登录
func (ac *AuthController) adminLogin(c *gin.Context, req AdminLoginRequest) {
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

	// 根据用户名判断角色
	var role string
	if employee.Username == "admin" || employee.Username == "manager" {
		role = "admin"
	} else {
		role = "employee"
	}

	// 生成Token
	token, err := ac.JWTUtil.GenerateToken(employee.ID, employee.Username, role)
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
				"role":     role,
			},
		},
	})
}

// userLogin 用户登录
func (ac *AuthController) userLogin(c *gin.Context, req UserLoginRequest) {
	var user models.User
	err := ac.DB.Where("phone = ? AND is_active = ?", req.Phone, true).First(&user).Error
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
				"sex":   user.Sex,
				"avatar": user.Avatar,
				"role":  "user",
			},
		},
	})
}

// Register 用户注册
//
//	@Summary		用户注册
//	@Description	普通用户注册账号，支持手机号注册
//	@Tags			认证
//	@Accept			json
//	@Produce		json
//	@Param			body	body	UserRegisterRequest	true	"注册请求参数"
//	@Success		200	{object}	map[string]interface{}	"注册成功"
//	@Failure		400	{object}	map[string]interface{}	"请求参数错误"
//	@Failure		409	{object}	map[string]interface{}	"用户已存在"
//	@Failure		500	{object}	map[string]interface{}	"服务器错误"
//	@Router			/api/v1/auth/register [post]
func (ac *AuthController) Register(c *gin.Context) {
	var req UserRegisterRequest
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
//
//	@Summary		刷新令牌
//	@Description	刷新JWT Token，延长登录状态
//	@Tags			认证
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	map[string]interface{}	"令牌刷新成功"
//	@Failure		401	{object}	map[string]interface{}	"令牌无效或过期"
//	@Failure		500	{object}	map[string]interface{}	"服务器错误"
//	@Router			/api/v1/auth/refresh [post]
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

// GetCurrentUser 获取当前登录用户信息
// @Summary      获取当前用户信息
// @Description  根据提供的JWT令牌获取当前登录用户（管理员）的信息
// @Tags         认证
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "获取成功"
// @Failure      401  {object}  map[string]interface{}  "认证失败"
// @Failure      403  {object}  map[string]interface{}  "权限不足"
// @Router       /api/v1/admin/me [get]
func (ac *AuthController) GetCurrentUser(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "无效的认证令牌",
		})
		return
	}

	userClaims, ok := claims.(*utils.Claims)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "认证令牌格式错误",
		})
		return
	}

	// 支持管理员和员工角色
	if userClaims.Role != "admin" && userClaims.Role != "employee" {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "权限不足"})
		return
	}

	var employee models.Employee
	err := ac.DB.First(&employee, userClaims.UserID).Error
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "验证成功",
		"data": gin.H{
			"id":       employee.ID,
			"username": employee.Username,
			"name":     employee.Name,
			"role":     userClaims.Role,
		},
	})
}

// GetCurrentUserForUser 获取当前登录用户信息 (用户端)
// @Summary      获取当前用户信息 (用户端)
// @Description  根据提供的JWT令牌获取当前登录用户的信息
// @Tags         认证
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "获取成功"
// @Failure      401  {object}  map[string]interface{}  "认证失败"
// @Failure      403  {object}  map[string]interface{}  "权限不足"
// @Router       /api/v1/user/me [get]
func (ac *AuthController) GetCurrentUserForUser(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "无效的认证令牌",
		})
		return
	}

	userClaims, ok := claims.(*utils.Claims)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "认证令牌格式错误",
		})
		return
	}

	// 确保是用户角色
	if userClaims.Role != "user" {
		c.JSON(http.StatusForbidden, gin.H{"code": 403, "message": "权限不足"})
		return
	}

	var user models.User
	err := ac.DB.First(&user, userClaims.UserID).Error
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 200,
		"message": "验证成功",
		"data": gin.H{
			"id":    user.ID,
			"name":  user.Name,
			"phone": user.Phone,
			"email": user.Email,
			"sex":   user.Sex,
			"avatar": user.Avatar,
			"role":  userClaims.Role,
		},
	})
}