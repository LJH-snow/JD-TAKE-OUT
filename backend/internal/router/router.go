package router

import (
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/controllers"
	"jd-take-out-backend/internal/middleware"
	"jd-take-out-backend/pkg/utils"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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
			admin.GET("/dashboard/overview", statsController.GetDashboardOverview)

			// 数据统计
			stats := admin.Group("/stats")
			{
				stats.GET("/sales", statsController.GetSalesTrend)
				stats.GET("/dishes", statsController.GetDishRanking)
				stats.GET("/categories", statsController.GetCategoryStats)
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
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "JD外卖后端服务运行正常",
		})
	})

	return r
}
