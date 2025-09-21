# 🍜 JD外卖系统

一个基于现代技术栈开发的完整外卖平台系统，包含用户端、管理端前端应用和后端API服务。

## 📋 项目简介

本项目是一个完整的外卖配送平台解决方案，提供了用户点餐、商家管理、订单处理等全流程功能。系统采用前后端分离架构，用户体验友好，管理功能完善。

## 🏗️ 项目架构

```
JD-take-out/
├── frontend-user/          # 用户端前端应用 (React + Vite)
├── frontend-admin/         # 管理端前端应用 (React + Vite)
├── backend/                # 后端API服务 (Golang + Gin + PostgreSQL)
└── 项目指导/               # 项目文档和指导资料
```

## ✨ 主要功能

### 👥 用户端功能
- 🔐 用户注册与登录
- 🛒 浏览菜品和套餐
- 🛍️ 购物车管理
- 📝 订单下单与支付
- 📍 地址管理 (集成高德地图)
- 📱 订单状态跟踪

### 🏪 管理端功能
- 👨‍💼 员工管理
- 🍴 菜品分类管理
- 🥘 菜品信息管理
- 🍱 套餐管理
- 📋 订单管理
- 📊 数据统计与分析 (ECharts图表)

## 🛠️ 技术栈

### 前端技术
- **框架**: React 19.1.1
- **构建工具**: Vite 7.1.2
- **开发语言**: JavaScript/JSX
- **代码规范**: ESLint
- **图表库**: ECharts (用于数据可视化)
- **UI组件**: Ant Design

### 后端技术
- **框架**: Golang + Gin
- **数据库**: PostgreSQL
- **ORM**: GORM v2
- **认证**: JWT + Casbin RBAC
- **API文档**: Swagger (规划中)

### 数据库设计
- **数据库**: PostgreSQL
- **主要数据表** (11个核心业务表):
  - `users` - 用户信息
  - `employees` - 员工信息
  - `categories` - 菜品分类
  - `dishes` - 菜品信息
  - `dish_flavors` - 菜品口味
  - `setmeals` - 套餐信息
  - `setmeal_dishes` - 套餐菜品关联
  - `orders` - 订单信息
  - `order_details` - 订单详情
  - `shopping_carts` - 购物车
  - `address_books` - 地址簿 (支持经纬度)

## 🚀 快速开始

### 环境要求
- Node.js >= 16.0.0
- npm >= 8.0.0
- Go >= 1.21
- PostgreSQL >= 13

### 安装与运行

1. **克隆项目**
```bash
git clone https://github.com/LJH-snow/JD-TAKE-OUT.git
cd JD-take-out
```

2. **启动后端服务**
```bash
cd backend
# 配置环境变量 (参考.env.example)
# 启动PostgreSQL数据库
go run cmd/main.go
# 或使用热重载
air
```
后端服务将在 http://localhost:8090 启动

3. **启动用户端**
```bash
cd frontend-user
npm install
npm run dev
```
用户端将在 http://localhost:5173 启动

4. **启动管理端**
```bash
cd frontend-admin
npm install
npm run dev
```
管理端将在 http://localhost:5174 启动

5. **数据库初始化**
```sql
-- 创建数据库
CREATE DATABASE jd_take_out;

-- 执行 项目指导/postgresql_database_script.sql 建表语句
-- 或启动后端服务，GORM会自动创建表结构
```

## 🎯 开发规划

### ✅ 已完成功能 (Completed Features)
- ✅ **后端架构**: 基于 Golang + Gin + GORM 的稳定后端服务
- ✅ **前后端分离**: 用户端、管理端、API服务完全分离
- ✅ **数据库设计**: 11+ 核心业务表结构
- ✅ **认证系统**: 基于 JWT 的用户、员工、管理员三角色认证和授权
- ✅ **核心业务流**: 完整的菜品、套餐、购物车、地址、下单、订单管理功能
- ✅ **真实数据统计**: 提供工作台、销售趋势、菜品排行等多个真实数据统计API
- ✅ **前端应用**: 基于 React + Ant Design 的用户端和管理端主要页面
- ✅ **图表展示**: 基于 ECharts 的数据可视化图表
- ✅ **地图集成**: 用户端地址管理集成高德地图定位
- ✅ **实时通知**: 基于 WebSocket 的新订单实时推送到管理端
- ✅ **API文档**: 集成 Swagger，自动生成接口文档
- ✅ **开发工具**: 提供热重载、数据生成、API测试等多种辅助工具

### 🚧 进行中 / 待优化 (In Progress / To Be Optimized)
- 🚧 **支付流程**: 目前为模拟支付，待集成本项目已有的支付宝沙箱支付功能
- 🚧 **数据库性能**: 进一步的索引和查询优化
- 🚧 **用户评价系统**: 待开发
- 🚧 **系统监控与日志**: 待集成更完善的监控和日志系统

## 📖 相关文档

项目包含以下指导文档：
- 数据库设计文档 (PostgreSQL脚本)
- ECharts图表设计方案
- 高德地图API集成指南
- 完整统计系统设计文档
- 开发环境搭建指南

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

⭐ 项目已具备生产就绪的基础能力，欢迎Star支持！�力，欢迎Star支持！─ pkg/utils/              # 工具类
└── configs/                # 配置文件
```

### 前端结构
```
frontend-*/
├── src/
│   ├── App.jsx              # 主应用组件
│   ├── main.jsx            # 应用入口
│   └── *.css               # 样式文件
└── package.json           # 项目配置
```

## 📚 开发指南

### 后端开发
```bash
# 启动热重载开发
cd backend && air

# 运行测试
go test ./...

# 生成测试数据
go run cmd/generate-orders/main.go

# API接口测试
go run cmd/test-stats/main.go
```

### 前端开发
```bash
# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 代码检查
npm run lint
```

### 端口配置
- 后端API: `http://localhost:8090`
- 用户端: `http://localhost:5173`
- 管理端: `http://localhost:5174`

## 🎯 开发规划

### ✅ 已完成里程碑
- ✅ 完整的后端架构搭建
- ✅ JWT认证系统实现
- ✅ 统计API真实数据替换
- ✅ 数据库表结构完善
- ✅ 丰富测试数据生成

### 🚧 进行中
- 🚧 数据库性能优化
- 🚧 Swagger API文档
- 🚧 前端React + ECharts开发

### 📋 待开发
- [ ] 菜品管理CRUD API
- [ ] 订单处理完整流程
- [ ] 高德地图集成
- [ ] 支付宝沙箱集成
- [ ] 实时订单推送
- [ ] 用户评价系统
- [ ] 系统监控和日志

## 📖 相关文档

项目包含以下指导文档：
- 数据库设计文档 (PostgreSQL脚本)
- ECharts图表设计方案
- 高德地图API集成指南
- 完整统计系统设计文档
- 开发环境搭建指南

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

⭐ 项目已具备生产就绪的基础能力，欢迎Star支持！�力，欢迎Star支持！
