-- PostgreSQL 数据库脚本
-- 请先创建 jd_take_out 数据库，然后执行以下 SQL 创建表

-- 创建数据库（如果需要的话）
-- CREATE DATABASE jd_take_out WITH ENCODING 'UTF8' LC_COLLATE='zh_CN.UTF-8' LC_CTYPE='zh_CN.UTF-8';

-- 使用数据库
-- \c jd_take_out;

-- 地址簿表（增强版）
CREATE TABLE address_book (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    consignee VARCHAR(50),
    sex VARCHAR(2),
    phone VARCHAR(11) NOT NULL,
    province_code VARCHAR(12),
    province_name VARCHAR(32),
    city_code VARCHAR(12),
    city_name VARCHAR(32),
    district_code VARCHAR(12),
    district_name VARCHAR(32),
    detail VARCHAR(200),
    label VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE NOT NULL,
    -- 高德地图相关字段
    longitude DECIMAL(10, 6),
    latitude DECIMAL(10, 6),
    amap_location_id VARCHAR(100),
    formatted_address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

COMMENT ON TABLE address_book IS '地址簿';
COMMENT ON COLUMN address_book.id IS '主键';
COMMENT ON COLUMN address_book.user_id IS '用户id';
COMMENT ON COLUMN address_book.consignee IS '收货人';
COMMENT ON COLUMN address_book.sex IS '性别';
COMMENT ON COLUMN address_book.phone IS '手机号';
COMMENT ON COLUMN address_book.province_code IS '省级区划编号';
COMMENT ON COLUMN address_book.province_name IS '省级名称';
COMMENT ON COLUMN address_book.city_code IS '市级区划编号';
COMMENT ON COLUMN address_book.city_name IS '市级名称';
COMMENT ON COLUMN address_book.district_code IS '区级区划编号';
COMMENT ON COLUMN address_book.district_name IS '区级名称';
COMMENT ON COLUMN address_book.detail IS '详细地址';
COMMENT ON COLUMN address_book.label IS '标签';
COMMENT ON COLUMN address_book.is_default IS '默认地址 false:否 true:是';
COMMENT ON COLUMN address_book.longitude IS '经度';
COMMENT ON COLUMN address_book.latitude IS '纬度';
COMMENT ON COLUMN address_book.amap_location_id IS '高德地图位置ID';
COMMENT ON COLUMN address_book.formatted_address IS '格式化详细地址';

-- 口味基础数据表
CREATE TABLE base_flavor (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    value VARCHAR(200)
);

COMMENT ON TABLE base_flavor IS '口味基础数据';
COMMENT ON COLUMN base_flavor.name IS '口味名称，例如：忌口；辣度；甜度；酸度';
COMMENT ON COLUMN base_flavor.value IS '口味值，使用字符数组，便于前端读取展示到标签组件';

-- 菜品及套餐分类表
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    type INTEGER,
    name VARCHAR(32) NOT NULL UNIQUE,
    sort INTEGER DEFAULT 0 NOT NULL,
    status INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_user BIGINT,
    update_user BIGINT
);

COMMENT ON TABLE categories IS '菜品及套餐分类';
COMMENT ON COLUMN categories.id IS '主键';
COMMENT ON COLUMN categories.type IS '类型 1:菜品分类 2:套餐分类';
COMMENT ON COLUMN categories.name IS '分类名称';
COMMENT ON COLUMN categories.sort IS '顺序';
COMMENT ON COLUMN categories.status IS '分类状态 0:禁用，1:启用';
COMMENT ON COLUMN categories.created_at IS '创建时间';
COMMENT ON COLUMN categories.updated_at IS '更新时间';
COMMENT ON COLUMN categories.create_user IS '创建人';
COMMENT ON COLUMN categories.update_user IS '修改人';

-- 菜品表
CREATE TABLE dishes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE,
    category_id BIGINT NOT NULL,
    price DECIMAL(10, 2) DEFAULT 0.00,
    image VARCHAR(255),
    description VARCHAR(255),
    status INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_user BIGINT,
    update_user BIGINT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

COMMENT ON TABLE dishes IS '菜品';
COMMENT ON COLUMN dishes.id IS '主键';
COMMENT ON COLUMN dishes.name IS '菜品名称';
COMMENT ON COLUMN dishes.category_id IS '菜品分类id';
COMMENT ON COLUMN dishes.price IS '菜品价格';
COMMENT ON COLUMN dishes.image IS '图片';
COMMENT ON COLUMN dishes.description IS '描述信息';
COMMENT ON COLUMN dishes.status IS '0:停售 1:起售';
COMMENT ON COLUMN dishes.created_at IS '创建时间';
COMMENT ON COLUMN dishes.updated_at IS '更新时间';
COMMENT ON COLUMN dishes.create_user IS '创建人';
COMMENT ON COLUMN dishes.update_user IS '修改人';

-- 菜品口味关系表
CREATE TABLE dish_flavors (
    id BIGSERIAL PRIMARY KEY,
    dish_id BIGINT NOT NULL,
    name VARCHAR(32),
    value VARCHAR(255),
    FOREIGN KEY (dish_id) REFERENCES dishes(id) ON DELETE CASCADE
);

COMMENT ON TABLE dish_flavors IS '菜品口味关系表';
COMMENT ON COLUMN dish_flavors.id IS '主键';
COMMENT ON COLUMN dish_flavors.dish_id IS '菜品id';
COMMENT ON COLUMN dish_flavors.name IS '口味名称';
COMMENT ON COLUMN dish_flavors.value IS '口味数据list';

-- 员工信息表
CREATE TABLE employees (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    username VARCHAR(32) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    phone VARCHAR(11) NOT NULL,
    sex VARCHAR(2) NOT NULL,
    id_number VARCHAR(18) NOT NULL,
    status INTEGER DEFAULT 1 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_user BIGINT,
    update_user BIGINT
);

COMMENT ON TABLE employees IS '员工信息';
COMMENT ON COLUMN employees.id IS '主键';
COMMENT ON COLUMN employees.name IS '姓名';
COMMENT ON COLUMN employees.username IS '用户名';
COMMENT ON COLUMN employees.password IS '密码';
COMMENT ON COLUMN employees.phone IS '手机号';
COMMENT ON COLUMN employees.sex IS '性别';
COMMENT ON COLUMN employees.id_number IS '身份证号';
COMMENT ON COLUMN employees.status IS '状态 0:禁用，1:启用';
COMMENT ON COLUMN employees.created_at IS '创建时间';
COMMENT ON COLUMN employees.updated_at IS '更新时间';
COMMENT ON COLUMN employees.create_user IS '创建人';
COMMENT ON COLUMN employees.update_user IS '修改人';

-- 套餐表
CREATE TABLE setmeals (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(32) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    status INTEGER DEFAULT 1,
    description VARCHAR(255),
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_user BIGINT,
    update_user BIGINT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

COMMENT ON TABLE setmeals IS '套餐';
COMMENT ON COLUMN setmeals.id IS '主键';
COMMENT ON COLUMN setmeals.category_id IS '菜品分类id';
COMMENT ON COLUMN setmeals.name IS '套餐名称';
COMMENT ON COLUMN setmeals.price IS '套餐价格';
COMMENT ON COLUMN setmeals.status IS '售卖状态 0:停售 1:起售';
COMMENT ON COLUMN setmeals.description IS '描述信息';
COMMENT ON COLUMN setmeals.image IS '图片';
COMMENT ON COLUMN setmeals.created_at IS '创建时间';
COMMENT ON COLUMN setmeals.updated_at IS '更新时间';
COMMENT ON COLUMN setmeals.create_user IS '创建人';
COMMENT ON COLUMN setmeals.update_user IS '修改人';

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
COMMENT ON COLUMN setmeal_dishes.id IS '主键';
COMMENT ON COLUMN setmeal_dishes.setmeal_id IS '套餐id';
COMMENT ON COLUMN setmeal_dishes.dish_id IS '菜品id';
COMMENT ON COLUMN setmeal_dishes.name IS '菜品名称（冗余字段）';
COMMENT ON COLUMN setmeal_dishes.price IS '菜品单价（冗余字段）';
COMMENT ON COLUMN setmeal_dishes.copies IS '菜品份数';

-- 用户信息表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    openid VARCHAR(45),
    name VARCHAR(32),
    phone VARCHAR(11) UNIQUE,
    email VARCHAR(100),
    sex VARCHAR(2),
    id_number VARCHAR(18),
    avatar VARCHAR(500),
    password VARCHAR(64),
    login_type INTEGER DEFAULT 1,
    last_login_time TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS '用户信息';
COMMENT ON COLUMN users.id IS '主键';
COMMENT ON COLUMN users.openid IS '微信用户唯一标识（可选）';
COMMENT ON COLUMN users.name IS '姓名';
COMMENT ON COLUMN users.phone IS '手机号';
COMMENT ON COLUMN users.email IS '邮箱地址';
COMMENT ON COLUMN users.sex IS '性别';
COMMENT ON COLUMN users.id_number IS '身份证号';
COMMENT ON COLUMN users.avatar IS '头像';
COMMENT ON COLUMN users.password IS '密码（手机号注册用户）';
COMMENT ON COLUMN users.login_type IS '登录方式 1:手机号 2:微信 3:邮箱';
COMMENT ON COLUMN users.last_login_time IS '最后登录时间';
COMMENT ON COLUMN users.is_active IS '账户是否激活';
COMMENT ON COLUMN users.created_at IS '创建时间';
COMMENT ON COLUMN users.updated_at IS '更新时间';

-- 订单表
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    number VARCHAR(50) UNIQUE,
    status INTEGER DEFAULT 1 NOT NULL,
    user_id BIGINT NOT NULL,
    address_book_id BIGINT NOT NULL,
    order_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checkout_time TIMESTAMP,
    pay_method INTEGER DEFAULT 1 NOT NULL,
    pay_status SMALLINT DEFAULT 0 NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    remark VARCHAR(100),
    phone VARCHAR(11),
    address VARCHAR(255),
    user_name VARCHAR(32),
    consignee VARCHAR(32),
    cancel_reason VARCHAR(255),
    rejection_reason VARCHAR(255),
    cancel_time TIMESTAMP,
    estimated_delivery_time TIMESTAMP,
    delivery_status BOOLEAN DEFAULT TRUE NOT NULL,
    delivery_time TIMESTAMP,
    pack_amount INTEGER,
    tableware_number INTEGER,
    tableware_status BOOLEAN DEFAULT TRUE NOT NULL,
    -- 配送地理信息
    delivery_longitude DECIMAL(10, 6),
    delivery_latitude DECIMAL(10, 6),
    delivery_distance INTEGER,
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (address_book_id) REFERENCES address_book(id)
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.id IS '主键';
COMMENT ON COLUMN orders.number IS '订单号';
COMMENT ON COLUMN orders.status IS '订单状态 1:待付款 2:待接单 3:已接单 4:派送中 5:已完成 6:已取消 7:退款';
COMMENT ON COLUMN orders.user_id IS '下单用户';
COMMENT ON COLUMN orders.address_book_id IS '地址id';
COMMENT ON COLUMN orders.order_time IS '下单时间';
COMMENT ON COLUMN orders.checkout_time IS '结账时间';
COMMENT ON COLUMN orders.pay_method IS '支付方式 1:微信 2:支付宝';
COMMENT ON COLUMN orders.pay_status IS '支付状态 0:未支付 1:已支付 2:退款';
COMMENT ON COLUMN orders.amount IS '实收金额';
COMMENT ON COLUMN orders.remark IS '备注';
COMMENT ON COLUMN orders.phone IS '手机号';
COMMENT ON COLUMN orders.address IS '地址';
COMMENT ON COLUMN orders.user_name IS '用户名称';
COMMENT ON COLUMN orders.consignee IS '收货人';
COMMENT ON COLUMN orders.cancel_reason IS '订单取消原因';
COMMENT ON COLUMN orders.rejection_reason IS '订单拒绝原因';
COMMENT ON COLUMN orders.cancel_time IS '订单取消时间';
COMMENT ON COLUMN orders.estimated_delivery_time IS '预计送达时间';
COMMENT ON COLUMN orders.delivery_status IS '配送状态 true:立即送出 false:选择具体时间';
COMMENT ON COLUMN orders.delivery_time IS '送达时间';
COMMENT ON COLUMN orders.pack_amount IS '打包费';
COMMENT ON COLUMN orders.tableware_number IS '餐具数量';
COMMENT ON COLUMN orders.delivery_longitude IS '配送地址经度';
COMMENT ON COLUMN orders.delivery_latitude IS '配送地址纬度';
COMMENT ON COLUMN orders.delivery_distance IS '配送距离（米）';
COMMENT ON COLUMN orders.delivery_fee IS '配送费用';

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
COMMENT ON COLUMN order_details.id IS '主键';
COMMENT ON COLUMN order_details.name IS '名字';
COMMENT ON COLUMN order_details.image IS '图片';
COMMENT ON COLUMN order_details.order_id IS '订单id';
COMMENT ON COLUMN order_details.dish_id IS '菜品id';
COMMENT ON COLUMN order_details.setmeal_id IS '套餐id';
COMMENT ON COLUMN order_details.dish_flavor IS '口味';
COMMENT ON COLUMN order_details.number IS '数量';
COMMENT ON COLUMN order_details.amount IS '金额';

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
COMMENT ON COLUMN shopping_carts.id IS '主键';
COMMENT ON COLUMN shopping_carts.name IS '商品名称';
COMMENT ON COLUMN shopping_carts.image IS '图片';
COMMENT ON COLUMN shopping_carts.user_id IS '用户id';
COMMENT ON COLUMN shopping_carts.dish_id IS '菜品id';
COMMENT ON COLUMN shopping_carts.setmeal_id IS '套餐id';
COMMENT ON COLUMN shopping_carts.dish_flavor IS '口味';
COMMENT ON COLUMN shopping_carts.number IS '数量';
COMMENT ON COLUMN shopping_carts.amount IS '金额';
COMMENT ON COLUMN shopping_carts.created_at IS '创建时间';

-- 商家信息表（支持多商家模式）
CREATE TABLE merchants (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    phone VARCHAR(11),
    address VARCHAR(255) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    amap_location_id VARCHAR(100),
    business_hours VARCHAR(100),
    delivery_radius INTEGER DEFAULT 3000,
    min_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    status INTEGER DEFAULT 1,
    rating DECIMAL(2, 1) DEFAULT 5.0,
    logo VARCHAR(255),
    banner_images TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE merchants IS '商家信息';
COMMENT ON COLUMN merchants.id IS '主键';
COMMENT ON COLUMN merchants.name IS '商家名称';
COMMENT ON COLUMN merchants.description IS '商家描述';
COMMENT ON COLUMN merchants.phone IS '联系电话';
COMMENT ON COLUMN merchants.address IS '商家地址';
COMMENT ON COLUMN merchants.longitude IS '经度';
COMMENT ON COLUMN merchants.latitude IS '纬度';
COMMENT ON COLUMN merchants.amap_location_id IS '高德地图位置ID';
COMMENT ON COLUMN merchants.business_hours IS '营业时间';
COMMENT ON COLUMN merchants.delivery_radius IS '配送范围(米)';
COMMENT ON COLUMN merchants.min_order_amount IS '起送金额';
COMMENT ON COLUMN merchants.delivery_fee IS '配送费';
COMMENT ON COLUMN merchants.status IS '状态 0:停业 1:营业';
COMMENT ON COLUMN merchants.rating IS '评分';
COMMENT ON COLUMN merchants.logo IS '商家标志';
COMMENT ON COLUMN merchants.banner_images IS '轮播图片JSON数组';

-- 配送员信息表
CREATE TABLE delivery_staff (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    phone VARCHAR(11) NOT NULL UNIQUE,
    id_number VARCHAR(18),
    vehicle_type INTEGER DEFAULT 1,
    vehicle_number VARCHAR(20),
    current_longitude DECIMAL(10, 6),
    current_latitude DECIMAL(10, 6),
    status INTEGER DEFAULT 1,
    online_status BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE delivery_staff IS '配送员信息';
COMMENT ON COLUMN delivery_staff.id IS '主键';
COMMENT ON COLUMN delivery_staff.name IS '姓名';
COMMENT ON COLUMN delivery_staff.phone IS '手机号';
COMMENT ON COLUMN delivery_staff.id_number IS '身份证号';
COMMENT ON COLUMN delivery_staff.vehicle_type IS '车辆类型 1:电动车 2:摩托车 3:汽车';
COMMENT ON COLUMN delivery_staff.vehicle_number IS '车牌号';
COMMENT ON COLUMN delivery_staff.current_longitude IS '当前经度';
COMMENT ON COLUMN delivery_staff.current_latitude IS '当前纬度';
COMMENT ON COLUMN delivery_staff.status IS '状态 0:禁用 1:启用';
COMMENT ON COLUMN delivery_staff.online_status IS '在线状态';

-- 配送路线表
CREATE TABLE delivery_routes (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    delivery_staff_id BIGINT,
    start_longitude DECIMAL(10, 6),
    start_latitude DECIMAL(10, 6),
    end_longitude DECIMAL(10, 6),
    end_latitude DECIMAL(10, 6),
    route_points TEXT,
    distance INTEGER,
    estimated_time INTEGER,
    actual_time INTEGER,
    status INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (delivery_staff_id) REFERENCES delivery_staff(id)
);

COMMENT ON TABLE delivery_routes IS '配送路线';
COMMENT ON COLUMN delivery_routes.id IS '主键';
COMMENT ON COLUMN delivery_routes.order_id IS '订单ID';
COMMENT ON COLUMN delivery_routes.delivery_staff_id IS '配送员ID';
COMMENT ON COLUMN delivery_routes.start_longitude IS '起点经度';
COMMENT ON COLUMN delivery_routes.start_latitude IS '起点纬度';
COMMENT ON COLUMN delivery_routes.end_longitude IS '终点经度';
COMMENT ON COLUMN delivery_routes.end_latitude IS '终点纬度';
COMMENT ON COLUMN delivery_routes.route_points IS '路线节点JSON数组';
COMMENT ON COLUMN delivery_routes.distance IS '距离(米)';
COMMENT ON COLUMN delivery_routes.estimated_time IS '预计时间(分钟)';
COMMENT ON COLUMN delivery_routes.actual_time IS '实际时间(分钟)';
COMMENT ON COLUMN delivery_routes.status IS '状态 1:计划中 2:配送中 3:已完成';

-- 创建索引以提高查询性能
CREATE INDEX idx_address_book_user_id ON address_book(user_id);
CREATE INDEX idx_address_book_location ON address_book(longitude, latitude);
CREATE INDEX idx_dishes_category_id ON dishes(category_id);
CREATE INDEX idx_dishes_status ON dishes(status);
CREATE INDEX idx_dish_flavors_dish_id ON dish_flavors(dish_id);
CREATE INDEX idx_employees_username ON employees(username);
CREATE INDEX idx_setmeals_category_id ON setmeals(category_id);
CREATE INDEX idx_setmeals_status ON setmeals(status);
CREATE INDEX idx_setmeal_dishes_setmeal_id ON setmeal_dishes(setmeal_id);
CREATE INDEX idx_setmeal_dishes_dish_id ON setmeal_dishes(dish_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_time ON orders(order_time);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_shopping_carts_user_id ON shopping_carts(user_id);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_login_type ON users(login_type);
CREATE INDEX idx_merchants_location ON merchants(longitude, latitude);
CREATE INDEX idx_merchants_status ON merchants(status);
CREATE INDEX idx_delivery_staff_location ON delivery_staff(current_longitude, current_latitude);
CREATE INDEX idx_delivery_staff_online ON delivery_staff(online_status);
CREATE INDEX idx_delivery_routes_order_id ON delivery_routes(order_id);
CREATE INDEX idx_delivery_routes_staff_id ON delivery_routes(delivery_staff_id);

-- 创建触发器函数用于自动更新 updated_at 字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表创建触发器
CREATE TRIGGER update_address_book_updated_at BEFORE UPDATE ON address_book
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dishes_updated_at BEFORE UPDATE ON dishes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_setmeals_updated_at BEFORE UPDATE ON setmeals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_delivery_staff_updated_at BEFORE UPDATE ON delivery_staff
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_delivery_routes_updated_at BEFORE UPDATE ON delivery_routes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入一些基础数据示例（可选）
/*
-- 员工初始数据
INSERT INTO employees (name, username, password, phone, sex, id_number, create_user) 
VALUES ('管理员', 'admin', '$2a$10$7JB720yubVSHvyGN/84aau.hZelDR2nVNVM4cL2QKr8z8aU3pVqJ6', '13812345678', '1', '110101199001011234', 1);

-- 菜品分类初始数据
INSERT INTO categories (type, name, sort, status, create_user) VALUES 
(1, '热菜', 1, 1, 1),
(1, '凉菜', 2, 1, 1),
(1, '汤品', 3, 1, 1),
(2, '套餐', 4, 1, 1);

-- 口味基础数据
INSERT INTO base_flavor (name, value) VALUES 
('辣度', '["不辣","微辣","中辣","重辣"]'),
('甜度', '["无糖","少糖","半糖","全糖"]'),
('忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
*/