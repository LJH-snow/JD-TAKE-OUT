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
		// 在开发环境中允许所有来源，方便调试
		AllowAllOrigins:  true,
		// AllowOrigins:     []string{"http://localhost:5173", "http://localhost:5174", "http://10.0.2.2:5173"},
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
	setmealController := &controllers.SetmealController{DB: db}
	employeeController := &controllers.EmployeeController{DB: db}
	userController := &controllers.UserController{DB: db}
	settingController := &controllers.SettingController{DB: db}
    menuController := &controllers.MenuController{DB: db} // 补上这行
    shoppingCartController := &controllers.ShoppingCartController{DB: db} // ADD THIS LINE
    addressBookController := &controllers.AddressBookController{DB: db} // ADD THIS LINE
	authController := &controllers.AuthController{
		DB:      db,
		Config:  cfg,
		JWTUtil: jwtUtil,
	}

	// API路由组
	api := r.Group("/api/v1")
	{

		// =====================================================================
		// =================== PUBLIC ROUTES (NO AUTH REQUIRED) =================
		// =====================================================================
		api.GET("/store-settings", settingController.GetSettings)
		api.GET("/menu", menuController.GetFullMenu)
		api.GET("/categories", categoryController.ListCategories)
		api.GET("/dishes", dishController.ListDishes)

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
				orders.GET("/export", orderController.ExportOrders) // 新增导出路由
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

			// 员工管理
			employees := admin.Group("/employees")
			{
				employees.GET("", employeeController.ListEmployees)
				employees.POST("", employeeController.CreateEmployee)
				employees.GET("/:id", employeeController.GetEmployeeByID)
				employees.PUT("/:id", employeeController.UpdateEmployee)
				employees.DELETE("/:id", employeeController.DeleteEmployee)
			}

			// 用户管理
			users := admin.Group("/users")
			{
				users.GET("", userController.ListUsers)
				users.GET("/:id", userController.GetUserByID)
				users.PUT("/:id", userController.UpdateUser)
			}

			// 店铺设置
			settings := admin.Group("/settings")
			{
				settings.GET("", settingController.GetSettings)
				settings.PUT("", settingController.UpdateSettings)
			}

			// 数据导出
			export := admin.Group("/export")
			{
				statsExport := export.Group("/stats")
				{
					statsExport.GET("/sales", statsController.ExportSalesData)
					statsExport.GET("/dishes", statsController.ExportDishRanking)
					statsExport.GET("/categories", statsController.GetCategoryStats)
				}
			}

			// 数据导出
			admin.POST("/export/data", statsController.ExportData)
		}

		// 员工路由（普通员工权限）
		employee := api.Group("/employee")
		employee.Use(middleware.AuthRequired(jwtUtil))
		employee.Use(middleware.EmployeeRequired())
		{
			// 员工个人信息
			employee.GET("/me", authController.GetCurrentUser)
			
			// 订单管理（员工可查看和更新订单状态）
			employeeOrders := employee.Group("/orders")
			{
				employeeOrders.GET("", orderController.ListOrders)
				employeeOrders.GET("/:id", orderController.GetOrderByID)
				employeeOrders.PUT("/:id/status", orderController.UpdateOrderStatus)
			}

			// 菜品查看（只读）
			employeeDishes := employee.Group("/dishes")
			{
				employeeDishes.GET("", dishController.ListDishes)
				employeeDishes.GET("/:id", dishController.GetDishByID)
			}

			// 分类查看（只读）
			employeeCategories := employee.Group("/categories")
			{
				employeeCategories.GET("", categoryController.ListCategories)
			}

			// 套餐查看（只读）
			employeeSetmeals := employee.Group("/setmeals")
			{
				employeeSetmeals.GET("", setmealController.ListSetmeals)
				employeeSetmeals.GET("/:id", setmealController.GetSetmealByID)
			}

			// 基础统计查看
			employeeStats := employee.Group("/stats")
			{
				employeeStats.GET("/orders/today", statsController.GetTodayOrderStats)
			}
		}

		// 用户端路由
		user := api.Group("/user")
		user.Use(middleware.AuthRequired(jwtUtil)) // ADD THIS LINE
		{
            user.GET("/me", authController.GetCurrentUserForUser) // ADD THIS LINE
			// Shopping Cart Routes
			user.POST("/shoppingCart", shoppingCartController.AddShoppingCart)
			user.GET("/shoppingCart", shoppingCartController.GetShoppingCart)
			user.PUT("/shoppingCart", shoppingCartController.UpdateShoppingCart)
			user.DELETE("/shoppingCart/:id", shoppingCartController.RemoveShoppingCart)
			user.DELETE("/shoppingCart/clear", shoppingCartController.ClearShoppingCart)
            user.POST("/orders", orderController.SubmitOrder) // ADD THIS LINE
			user.GET("/orders", orderController.ListUserOrders)
			user.GET("/orders/:id", orderController.GetUserOrderByID)      // 获取订单详情
			user.POST("/orders/:id/cancel", orderController.CancelOrder)    // 取消订单
			user.POST("/orders/:id/confirm", orderController.ConfirmOrder) // 确认收货

            // Address Book Routes
            user.POST("/addressBook", addressBookController.AddAddressBook)
            user.GET("/addressBook", addressBookController.ListAddressBooks)
            user.GET("/addressBook/:id", addressBookController.GetAddressBookByID)
            user.PUT("/addressBook/:id", addressBookController.UpdateAddressBook)
            user.DELETE("/addressBook/:id", addressBookController.DeleteAddressBook)
            user.PUT("/addressBook/default/:id", addressBookController.SetDefaultAddressBook)
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