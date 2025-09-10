// Package main JD外卖系统后端API服务
//
//	@title			JD外卖系统API
//	@version		1.0
//	@description	基于Golang + Gin + PostgreSQL的完整外卖平台API接口文档
//	@description	提供用户认证、统计分析、订单管理等核心功能
//
//	@contact.name	JD外卖开发团队
//	@contact.email	support@jd-takeout.com
//
//	@host		localhost:8090
//
//	@securityDefinitions.apikey	BearerAuth
//	@in							header
//	@name						Authorization
//	@description				JWT Token (格式: Bearer {token})
//
//	@tag.name		认证
//	@tag.description	用户认证和授权相关接口
//
//	@tag.name		统计
//	@tag.description	数据统计和分析相关接口
//
//	@tag.name		健康检查
//	@tag.description	系统状态检查接口
package main

import (
	"jd-take-out-backend/internal/config"
	"jd-take-out-backend/internal/database"
	"jd-take-out-backend/internal/router"
	"log"

	"github.com/gin-gonic/gin"

	_ "jd-take-out-backend/docs" // 导入swagger文档
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 连接数据库
	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// 执行数据库迁移
	err = database.Migrate(db)
	if err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	// 初始化基础测试数据
	err = database.SeedData(db)
	if err != nil {
		log.Fatalf("Failed to seed database: %v", err)
	}

	// 设置Gin模式
	gin.SetMode(cfg.Server.Mode)

	// 初始化路由
	r := router.SetupRouter(db, cfg)

	// 启动服务器
	log.Printf("Server starting on port %s", cfg.Server.Port)
	if err := r.Run(":" + cfg.Server.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
