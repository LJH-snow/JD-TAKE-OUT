# 🍜 JD外卖系统

一个基于现代前端技术栈开发的外卖平台系统，包含用户端和管理端双端应用。

## 📋 项目简介

本项目是一个完整的外卖配送平台解决方案，提供了用户点餐、商家管理、订单处理等全流程功能。系统采用前后端分离架构，用户体验友好，管理功能完善。

## 🏗️ 项目架构

```
JD-take-out/
├── frontend-user/          # 用户端前端应用
├── frontend-admin/         # 管理端前端应用
├── backend/                # 后端服务（待开发）
└── 项目指导/               # 项目文档和指导资料
```

## ✨ 主要功能

### 👥 用户端功能
- 🔐 用户注册与登录
- 🛒 浏览菜品和套餐
- 🛍️ 购物车管理
- 📝 订单下单与支付
- 📍 地址管理
- 📱 订单状态跟踪

### 🏪 管理端功能
- 👨‍💼 员工管理
- 🍴 菜品分类管理
- 🥘 菜品信息管理
- 🍱 套餐管理
- 📋 订单管理
- 📊 数据统计与分析

## 🛠️ 技术栈

### 前端技术
- **框架**: React 19.1.1
- **构建工具**: Vite 7.1.2
- **开发语言**: JavaScript/JSX
- **代码规范**: ESLint

### 数据库设计
- **数据库**: PGSQL
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
git clone https://github.com/LJH-snow/JD-TAKE-OUT.git
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

- [ ] 完善前端页面设计
- [ ] 开发后端API服务
- [ ] 集成微信/支付宝支付
- [ ] 实现实时订单推送
- [ ] 添加地图定位功能
- [ ] 完善用户评价系统
- [ ] 实现数据可视化

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

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 项目地址: [GitHub Repository](https://github.com/LJH-snow/JD-TAKE-OUT)
- 问题反馈: [Issues](https://github.com/LJH-snow/JD-TAKE-OUT/issues)

---

⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！
