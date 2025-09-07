- **数据库**: PGSQL
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
- **主要数据表**:
  - `user` - 用户信息
  - `employee` - 员工信息
  - `category` - 菜品分类
  - `dish` - 菜品信息
  - `setmeal` - 套餐信息
  - `orders` - 订单信息
  - `shopping_cart` - 购物车
  - `address_book` - 地址簿

## 🚀 快速开始

### 环境要求
- Node.js >= 16.0.0
- npm >= 8.0.0
- MySQL >= 8.0

### 安装与运行

1. **克隆项目**
```bash
<<<<<<< HEAD
git clone https://github.com/yourusername/JD-take-out.git
git clone https://github.com/LJH-snow/JD-TAKE-OUT.git
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
cd JD-take-out
```

2. **启动用户端**
```bash
cd frontend-user
npm install
npm run dev
```
用户端将在 http://localhost:5173 启动

3. **启动管理端**
```bash
cd frontend-admin
npm install
npm run dev
```
管理端将在 http://localhost:5174 启动

4. **数据库初始化**
```sql
-- 创建数据库
CREATE DATABASE sky_take_out;

-- 执行项目指导/数据库脚本.txt 中的建表语句
```
# 🍜 JD外卖系统

一个基于现代技术栈开发的外卖平台系统，包含用户端、管理端前端应用和后端API服务。

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
- **UI组件**: Ant Design (规划中)

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

## 📊 当前功能状态

### ✅ 已完成功能
- ✅ **后端核心架构** - Golang + Gin + PostgreSQL完整搭建
- ✅ **数据库设计** - 11个核心业务表，符合GORM复数约定
- ✅ **JWT认证系统** - 用户登录/注册，权限管理
- ✅ **统计API真实化** - 工作台、销售趋势、菜品排行、分类统计
- ✅ **丰富测试数据** - 326个订单，¥54,693营业额支持完整测试
- ✅ **开发工具完善** - 热重载、数据生成、API测试工具

### 📊 真实业务数据展示
- **总订单数**: 326个 (过去31天)
- **今日数据**: ¥2,392营业额 (12单，100%完成率)
- **热销菜品**: 剁椒鱼头(85份) > 糖醋里脊(77份) > 麻婆豆腐(75份)
- **分类占比**: 湘菜36.7% > 川菜24% > 鲁菜20% > 粤菜19%

### 🚧 开发中功能
- 🚧 **数据库性能优化** - 索引和视图优化
- 🚧 **Swagger API文档** - 接口文档生成
- 🚧 **前端开发** - React + ECharts图表展示

## 🌐 API接口

### 认证接口
- `POST /api/v1/auth/login` - 管理员登录
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/refresh` - 刷新Token

### 统计分析接口 (需要管理员权限)
- `GET /api/v1/admin/dashboard/overview` - 工作台概览 **🔥使用真实数据**
- `GET /api/v1/admin/stats/sales` - 销售趋势 **🔥使用真实数据**
- `GET /api/v1/admin/stats/dishes` - 菜品排行 **🔥使用真实数据**
- `GET /api/v1/admin/stats/categories` - 分类统计 **🔥使用真实数据**

### 健康检查
- `GET /health` - 服务状态检查

## 📁 项目结构

### 后端结构 (backend/)
```
backend/
├── cmd/
│   ├── main.go              # 程序入口
│   └── */                   # 开发工具脚本
├── internal/
│   ├── controllers/         # HTTP控制器
│   ├── services/           # 业务逻辑层
│   ├── models/             # 数据模型
│   ├── middleware/         # 中间件
│   ├── router/             # 路由配置
│   ├── database/           # 数据库连接
│   └── config/             # 配置管理
├── pkg/utils/              # 工具类
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
=======
- **数据库**: PGSQL
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
- **主要数据表**:
  - `user` - 用户信息
  - `employee` - 员工信息
  - `category` - 菜品分类
  - `dish` - 菜品信息
  - `setmeal` - 套餐信息
  - `orders` - 订单信息
  - `shopping_cart` - 购物车
  - `address_book` - 地址簿

## 🚀 快速开始

### 环境要求
- Node.js >= 16.0.0
- npm >= 8.0.0
- MySQL >= 8.0

### 安装与运行

1. **克隆项目**
```bash
<<<<<<< HEAD
git clone https://github.com/yourusername/JD-take-out.git
=======
git clone https://github.com/LJH-snow/JD-TAKE-OUT.git
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
cd JD-take-out
```

2. **启动用户端**
```bash
cd frontend-user
npm install
npm run dev
```
用户端将在 http://localhost:5173 启动

3. **启动管理端**
```bash
cd frontend-admin
npm install
npm run dev
```
管理端将在 http://localhost:5174 启动

4. **数据库初始化**
```sql
-- 创建数据库
CREATE DATABASE sky_take_out;

-- 执行项目指导/数据库脚本.txt 中的建表语句
```

## 📁 项目结构

### 用户端 (frontend-user)
```
frontend-user/
├── src/
│   ├── App.jsx              # 主应用组件
│   ├── App.css             # 应用样式
│   ├── main.jsx            # 应用入口
│   └── index.css           # 全局样式
├── public/                 # 静态资源
└── package.json           # 项目配置
```

### 管理端 (frontend-admin)
```
frontend-admin/
├── src/
│   ├── App.jsx              # 主应用组件
│   ├── App.css             # 应用样式
│   ├── main.jsx            # 应用入口
│   └── index.css           # 全局样式
├── public/                 # 静态资源
└── package.json           # 项目配置
```

## 📚 开发指南

### 可用脚本

在各个前端项目目录下：

```bash
# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 代码检查
npm run lint

# 预览构建结果
npm run preview
```

### 端口配置
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
- 数据库设计文档
- 支付宝沙箱与Cpolar入门指南
- 高德地图API集成指南
- 课程设计报告模板

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

```
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

⭐ 项目已具备生产就绪的基础能力，欢迎Star支持！
=======
- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！
>>>>>>> ccb75e00082dace1cc0926543096dbd42ed84cd6
