package controllers

import (
	"net/http"
	"strconv"

	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// EmployeeController 员工控制器
type EmployeeController struct {
	DB *gorm.DB
}

// CreateEmployeeRequest 定义了新增员工时的请求体
type CreateEmployeeRequest struct {
	Name     string `json:"name" binding:"required"`
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
	Phone    string `json:"phone" binding:"required"`
	Sex      string `json:"sex" binding:"required,oneof=0 1"`
	IdNumber string `json:"id_number" binding:"required,len=18"`
	Status   int    `json:"status" binding:"oneof=0 1"`
}

// UpdateEmployeeRequest 定义了更新员工时的请求体
type UpdateEmployeeRequest struct {
	Name     string `json:"name"`
	Username string `json:"username"`	// 用户名不允许修改
	Password string `json:"password"`
	Phone    string `json:"phone"`
	Sex      string `json:"sex" binding:"oneof=0 1"`
	IdNumber string `json:"id_number" binding:"len=18"`
	Status   int    `json:"status" binding:"oneof=0 1"`
}

// ListEmployees 获取员工分页列表
// @Summary      获取员工分页列表
// @Description  根据分页和筛选条件获取员工列表
// @Tags         员工管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        page     query    int     false  "页码"
// @Param        pageSize query    int     false  "每页数量"
// @Param        name     query    string  false  "员工姓名"
// @Param        username query    string  false  "用户名"
// @Param        phone    query    string  false  "手机号"
// @Param        status   query    int     false  "状态 (0:禁用, 1:启用)"
// @Success      200      {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/employees [get]
func (ec *EmployeeController) ListEmployees(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var employees []models.Employee
	var total int64

	db := ec.DB.Model(&models.Employee{})

	// 应用筛选
	if name := c.Query("name"); name != "" {
		db = db.Where("name LIKE ?", "%"+name+"%")
	}
	if username := c.Query("username"); username != "" {
		db = db.Where("username LIKE ?", "%"+username+"%")
	}
	if phone := c.Query("phone"); phone != "" {
		db = db.Where("phone LIKE ?", "%"+phone+"%")
	}
	if statusStr := c.Query("status"); statusStr != "" {
		status, _ := strconv.Atoi(statusStr)
		db = db.Where("status = ?", status)
	}

	// 获取总数
	if err := db.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取员工总数失败"})
		return
	}

	// 获取分页数据
	offset := (page - 1) * limit
	err := db.Order("created_at DESC").Offset(offset).Limit(limit).Find(&employees).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取员工列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"items": employees,
			"total": total,
		},
	})
}

// CreateEmployee 新增员工
// @Summary      新增员工
// @Description  创建一个新的员工账号
// @Tags         员工管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body     body      CreateEmployeeRequest  true   "员工信息"
// @Success      201      {object}  map[string]interface{}  "创建成功"
// @Router       /api/v1/admin/employees [post]
func (ec *EmployeeController) CreateEmployee(c *gin.Context) {
	var req CreateEmployeeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	// 检查用户名是否已存在
	var existingEmployee models.Employee
	if err := ec.DB.Where("username = ?", req.Username).First(&existingEmployee).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"code": 409, "message": "用户名已存在"})
		return
	}

	// 密码加密
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "密码加密失败"})
		return
	}

	createUserID, _ := c.Get("user_id")

	employee := models.Employee{
		Name:       req.Name,
		Username:   req.Username,
		Password:   hashedPassword,
		Phone:      req.Phone,
		Sex:        req.Sex,
		IdNumber:   req.IdNumber,
		Status:     req.Status,
		CreateUser: createUserID.(uint),
		UpdateUser: createUserID.(uint),
	}

	if err := ec.DB.Create(&employee).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "创建员工失败: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"code": 201, "message": "创建成功", "data": employee})
}

// GetEmployeeByID 获取单个员工详情
// @Summary      获取员工详情
// @Description  根据ID获取单个员工的详细信息
// @Tags         员工管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "员工ID"
// @Success      200  {object}  map[string]interface{}  "成功响应"
// @Router       /api/v1/admin/employees/{id} [get]
func (ec *EmployeeController) GetEmployeeByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var employee models.Employee
	if err := ec.DB.First(&employee, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "员工未找到"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "data": employee})
}

// UpdateEmployee 更新员工
// @Summary      更新员工信息
// @Description  更新指定ID的员工信息
// @Tags         员工管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int             true   "员工ID"
// @Param        body body      UpdateEmployeeRequest  true   "要更新的员工信息"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Router       /api/v1/admin/employees/{id} [put]
func (ec *EmployeeController) UpdateEmployee(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req UpdateEmployeeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数校验失败: " + err.Error()})
		return
	}

	var employee models.Employee
	if err := ec.DB.First(&employee, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "员工未找到"})
		return
	}

	// 不允许修改用户名
	if req.Username != "" && req.Username != employee.Username {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "不允许修改用户名"})
		return
	}

	// 如果提供了新密码，则加密
	hashedPassword := employee.Password // 默认保留旧密码
	if req.Password != "" {
		var err error
		hashedPassword, err = utils.HashPassword(req.Password)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "密码加密失败"})
			return
		}
	}

	updateUserID, _ := c.Get("user_id")

	// 更新字段
	updateData := map[string]interface{}{
		"name":        req.Name,
		"phone":       req.Phone,
		"sex":         req.Sex,
		"id_number":   req.IdNumber,
		"status":      req.Status,
		"update_user": updateUserID.(uint),
	}

	// 只有当新密码不为空时才更新密码
	if req.Password != "" {
		updateData["password"] = hashedPassword
	}

	// 检查是否是admin用户尝试禁用自己
	if employee.Username == "admin" && req.Status == 0 {
		claims, exists := c.Get("claims")
		if exists {
			userClaims := claims.(*utils.Claims)
			if userClaims.Username == "admin" && userClaims.UserID == employee.ID {
				c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "不允许禁用admin用户"})
				return
			}
		}
	}

	if err := ec.DB.Model(&employee).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新员工失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功"})
}

// DeleteEmployee 删除员工
// @Summary      删除员工
// @Description  根据ID删除指定员工
// @Tags         员工管理
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "员工ID"
// @Success      204  {object}  nil "删除成功"
// @Router       /api/v1/admin/employees/{id} [delete]
func (ec *EmployeeController) DeleteEmployee(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))

	var employee models.Employee
	if err := ec.DB.First(&employee, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "员工未找到"})
		return
	}

	// 不允许删除admin用户
	if employee.Username == "admin" {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "不允许删除admin用户"})
		return
	}

	if err := ec.DB.Delete(&models.Employee{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "删除员工失败"})
		return
	}

	c.Status(http.StatusNoContent)
}
