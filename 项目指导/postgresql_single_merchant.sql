-- PostgreSQL 数据库脚本（单商家模式 - 2周实训版）
-- 请先创建 jd_take_out 数据库，然后执行以下 SQL 创建表

-- 用户信息表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32),
    phone VARCHAR(11) UNIQUE,
    email VARCHAR(100),
    password VARCHAR(64) NOT NULL,
    sex VARCHAR(2),
    avatar VARCHAR(500),
    login_type INTEGER DEFAULT 1,
    last_login_time TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS '用户信息';
COMMENT ON COLUMN users.login_type IS '登录方式 1:手机号 2:邮箱';

-- 地址簿表
CREATE TABLE address_book (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    consignee VARCHAR(50),
    phone VARCHAR(11) NOT NULL,
    province_name VARCHAR(32),
    city_name VARCHAR(32),
    district_name VARCHAR(32),
    detail VARCHAR(200),
    label VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE NOT NULL,
    -- 地图相关字段
    longitude DECIMAL(10, 6),
    latitude DECIMAL(10, 6),
    formatted_address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

COMMENT ON TABLE address_book IS '地址簿';

-- 菜品分类表
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    type INTEGER DEFAULT 1,
    name VARCHAR(32) NOT NULL UNIQUE,
    sort INTEGER DEFAULT 0 NOT NULL,
    status INTEGER DEFAULT 1,
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE categories IS '菜品分类';
COMMENT ON COLUMN categories.type IS '类型 1:菜品分类 2:套餐分类';

-- 菜品表
CREATE TABLE dishes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE,
    category_id BIGINT NOT NULL,
    price DECIMAL(10, 2) DEFAULT 0.00,
    image VARCHAR(255),
    description VARCHAR(255),
    status INTEGER DEFAULT 1,
    sales_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

COMMENT ON TABLE dishes IS '菜品';
COMMENT ON COLUMN dishes.sales_count IS '销量统计';

-- 菜品口味表
CREATE TABLE dish_flavors (
    id BIGSERIAL PRIMARY KEY,
    dish_id BIGINT NOT NULL,
    name VARCHAR(32),
    value VARCHAR(255),
    FOREIGN KEY (dish_id) REFERENCES dishes(id) ON DELETE CASCADE
);

COMMENT ON TABLE dish_flavors IS '菜品口味';

-- 套餐表
CREATE TABLE setmeals (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(32) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    status INTEGER DEFAULT 1,
    description VARCHAR(255),
    image VARCHAR(255),
    sales_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

COMMENT ON TABLE setmeals IS '套餐';

-- 套餐菜品关系表
CREATE TABLE setmeal_dishes (
    id BIGSERIAL PRIMARY KEY,
    setmeal_id BIGINT,
    dish_id BIGINT,
    name VARCHAR(32),
    price DECIMAL(10, 2),
    copies INTEGER,
    FOREIGN KEY (setmeal_id) REFERENCES setmeals(id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(id)
);

COMMENT ON TABLE setmeal_dishes IS '套餐菜品关系';

-- 购物车表
CREATE TABLE shopping_carts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32),
    image VARCHAR(255),
    user_id BIGINT NOT NULL,
    dish_id BIGINT,
    setmeal_id BIGINT,
    dish_flavor VARCHAR(50),
    number INTEGER DEFAULT 1 NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (dish_id) REFERENCES dishes(id),
    FOREIGN KEY (setmeal_id) REFERENCES setmeals(id)
);

COMMENT ON TABLE shopping_carts IS '购物车';

-- 订单表
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    number VARCHAR(50) UNIQUE,
    status INTEGER DEFAULT 1 NOT NULL,
    user_id BIGINT NOT NULL,
    address_book_id BIGINT NOT NULL,
    order_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checkout_time TIMESTAMP,
    pay_method INTEGER DEFAULT 2 NOT NULL,
    pay_status SMALLINT DEFAULT 0 NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    remark VARCHAR(100),
    phone VARCHAR(11),
    address VARCHAR(255),
    user_name VARCHAR(32),
    consignee VARCHAR(32),
    delivery_time TIMESTAMP,
    estimated_delivery_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (address_book_id) REFERENCES address_book(id)
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.status IS '订单状态 1:待付款 2:待接单 3:制作中 4:派送中 5:已完成 6:已取消';
COMMENT ON COLUMN orders.pay_method IS '支付方式 1:微信 2:支付宝';

-- 订单明细表
CREATE TABLE order_details (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32),
    image VARCHAR(255),
    order_id BIGINT NOT NULL,
    dish_id BIGINT,
    setmeal_id BIGINT,
    dish_flavor VARCHAR(50),
    number INTEGER DEFAULT 1 NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(id),
    FOREIGN KEY (setmeal_id) REFERENCES setmeals(id)
);

COMMENT ON TABLE order_details IS '订单明细表';

-- 管理员表（简化版）
CREATE TABLE admins (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    name VARCHAR(32) NOT NULL,
    phone VARCHAR(11),
    status INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE admins IS '管理员信息';

-- 创建索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_address_book_user_id ON address_book(user_id);
CREATE INDEX idx_dishes_category_id ON dishes(category_id);
CREATE INDEX idx_dishes_status ON dishes(status);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_shopping_carts_user_id ON shopping_carts(user_id);

-- 创建触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_address_book_updated_at BEFORE UPDATE ON address_book
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dishes_updated_at BEFORE UPDATE ON dishes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_setmeals_updated_at BEFORE UPDATE ON setmeals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 初始化数据
INSERT INTO admins (username, password, name, phone) 
VALUES ('admin', '$2a$10$7JB720yubVSHvyGN/84aau.hZelDR2nVNVM4cL2QKr8z8aU3pVqJ6', '系统管理员', '13800138000');

INSERT INTO categories (type, name, sort, status) VALUES 
(1, '热菜', 1, 1),
(1, '凉菜', 2, 1),
(1, '汤品', 3, 1),
(1, '主食', 4, 1),
(2, '套餐', 5, 1);

-- 示例菜品数据
INSERT INTO dishes (name, category_id, price, image, description, status) VALUES 
('宫保鸡丁', 1, 28.00, '/images/dishes/gongbao.jpg', '经典川菜，鸡丁配花生米', 1),
('麻婆豆腐', 1, 18.00, '/images/dishes/mapo.jpg', '麻辣鲜香的经典豆腐', 1),
('凉拌黄瓜', 2, 8.00, '/images/dishes/cucumber.jpg', '清爽开胃的凉菜', 1),
('西红柿鸡蛋汤', 3, 12.00, '/images/dishes/soup.jpg', '家常营养汤品', 1),
('米饭', 4, 3.00, '/images/dishes/rice.jpg', '优质大米', 1);

-- 销售统计视图（便于图表数据查询）
CREATE VIEW daily_sales_stats AS
SELECT 
    DATE(created_at) as sale_date,
    COUNT(*) as order_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM orders 
WHERE status = 5  -- 已完成订单
GROUP BY DATE(created_at)
ORDER BY sale_date DESC;

-- 菜品销量统计视图
CREATE VIEW dish_sales_stats AS
SELECT 
    d.id,
    d.name,
    d.price,
    c.name as category_name,
    SUM(od.number) as total_sales,
    SUM(od.amount) as total_revenue
FROM dishes d
JOIN order_details od ON d.id = od.dish_id
JOIN orders o ON od.order_id = o.id
JOIN categories c ON d.category_id = c.id
WHERE o.status = 5  -- 已完成订单
GROUP BY d.id, d.name, d.price, c.name
ORDER BY total_sales DESC;

-- 用户消费统计视图
CREATE VIEW user_consumption_stats AS
SELECT 
    u.id,
    u.name,
    u.phone,
    COUNT(o.id) as order_count,
    SUM(o.amount) as total_consumption,
    AVG(o.amount) as avg_order_amount,
    MAX(o.created_at) as last_order_time
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 5  -- 已完成订单
GROUP BY u.id, u.name, u.phone
ORDER BY total_consumption DESC;

-- 分类销售统计视图
CREATE VIEW category_sales_stats AS
SELECT 
    c.id,
    c.name as category_name,
    COUNT(od.id) as dish_count,
    SUM(od.number) as total_quantity,
    SUM(od.amount) as total_revenue
FROM categories c
JOIN dishes d ON c.id = d.category_id
JOIN order_details od ON d.id = od.dish_id
JOIN orders o ON od.order_id = o.id
WHERE o.status = 5  -- 已完成订单
GROUP BY c.id, c.name
ORDER BY total_revenue DESC;