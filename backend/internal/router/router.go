package router

import (
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/controllers"
	"jd-take-out-backend/internal/middleware"
	"jd-take-out-backend/pkg/utils"
	
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	// Swagger
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(db *gorm.DB, cfg *config.Config) *gin.Engine {
	r := gin.Default()

	// CORS中间件
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:5173", "http://localhost:5174"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// 全局中间件
	r.Use(middleware.Logger())
	r.Use(gin.Recovery())

	// 初始化JWT工具
	jwtUtil := utils.NewJWTUtil(cfg.JWT.Secret, cfg.JWT.Expire)

	// 初始化控制器
	statsController := &controllers.StatsController{DB: db}
	dishController := &controllers.DishController{DB: db}
	categoryController := &controllers.CategoryController{DB: db}
	orderController := &controllers.OrderController{DB: db}
	setmealController := &controllers.SetmealController{DB: db} // 新增套餐控制器
	authController := &controllers.AuthController{
		DB:      db,
		Config:  cfg,
		JWTUtil: jwtUtil,
	}

	// API路由组
	api := r.Group("/api/v1")
	{
		// 认证相关路由
		auth := api.Group("/auth")
		{
			auth.POST("/login", authController.Login)
			auth.POST("/register", authController.Register)
			auth.POST("/refresh", authController.RefreshToken)
		}

		// 管理员路由（需要认证）
		admin := api.Group("/admin")
		admin.Use(middleware.AuthRequired(jwtUtil))
		admin.Use(middleware.AdminRequired())
		{
			// 工作台统计
			admin.GET("/me", authController.GetCurrentUser) // 新增：用于验证token并获取用户信息
			admin.GET("/dashboard/overview", statsController.GetDashboardOverview)

			// 数据统计
			stats := admin.Group("/stats")
			{
				stats.GET("/sales", statsController.GetSalesTrend)
				stats.GET("/dishes", statsController.GetDishRanking)
				stats.GET("/categories", statsController.GetCategoryStats)
			}

			// 菜品管理
			dishes := admin.Group("/dishes")
			{
				dishes.GET("", dishController.ListDishes)
				dishes.POST("", dishController.CreateDish)
				dishes.GET("/:id", dishController.GetDishByID)
				dishes.PUT("/:id", dishController.UpdateDish)
				dishes.DELETE("/:id", dishController.DeleteDish)
			}

			// 分类管理
			categories := admin.Group("/categories")
			{
				categories.GET("/list", categoryController.ListCategories)
				categories.POST("", categoryController.CreateCategory)
				categories.PUT("/:id", categoryController.UpdateCategory)
				categories.DELETE("/:id", categoryController.DeleteCategory)
			}

			// 订单管理
			orders := admin.Group("/orders")
			{
				orders.GET("", orderController.ListOrders)
				orders.GET("/:id", orderController.GetOrderByID)
				orders.PUT("/:id/status", orderController.UpdateOrderStatus)
			}

			// 套餐管理
			setmeals := admin.Group("/setmeals")
			{
				setmeals.GET("", setmealController.ListSetmeals)
				setmeals.POST("", setmealController.CreateSetmeal)
				setmeals.GET("/:id", setmealController.GetSetmealByID)
				setmeals.PUT("/:id", setmealController.UpdateSetmeal)
				setmeals.DELETE("/:id", setmealController.DeleteSetmeal)
			}

			// 数据导出
			admin.POST("/export/data", statsController.ExportData)
		}

		// 用户端路由
		user := api.Group("/user")
		{
			user.GET("/dishes", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "User dishes endpoint"})
			})
		}
	}

	// 健康检查
	r.GET("/health", HealthCheck)

	// Swagger API文档 (仅在开发模式下启用)
	if cfg.Server.Mode != "release" {
		r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
		r.GET("/docs", func(c *gin.Context) {
			c.Redirect(302, "/swagger/index.html")
		})
	}

	return r
}

// HealthCheck 系统健康检查
//
//	@Summary		系统健康检查
//	@Description	检查系统服务状态，返回服务器运行情况
//	@Tags			健康检查
//	@Accept			json
//	@Produce		json
//	@Success		200	{object}	map[string]interface{}	"服务正常"
//	@Router			/health [get]
func HealthCheck(c *gin.Context) {
	c.JSON(200, gin.H{
		"status":    "ok",
		"message":   "JD外卖后端服务运行正常",
		"timestamp": time.Now().Format("2006-01-02 15:04:05"),
	})
}
