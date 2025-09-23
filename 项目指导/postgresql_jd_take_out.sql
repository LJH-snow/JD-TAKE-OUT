--
-- PostgreSQL database dump
--

\restrict hRzgNccctUEpioz3TxdgyOlWf6lrfzNX59qFvzhl91pHckJ2IVIegSjZtNpBTFe

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-09-23 14:47:50

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 250 (class 1255 OID 16823)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 242 (class 1259 OID 16878)
-- Name: address_books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address_books (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    consignee character varying(50),
    sex character varying(2),
    phone character varying(11) NOT NULL,
    province_code character varying(12),
    province_name character varying(32),
    city_code character varying(12),
    city_name character varying(32),
    district_code character varying(12),
    district_name character varying(32),
    detail character varying(200),
    label character varying(100),
    is_default integer DEFAULT 0,
    longitude numeric(10,7),
    latitude numeric(10,7),
    formatted_address character varying(500),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.address_books OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16877)
-- Name: address_books_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.address_books_id_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 241
-- Name: address_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_books_id_seq OWNED BY public.address_books.id;


--
-- TOC entry 220 (class 1259 OID 16645)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    type bigint,
    name character varying(32) NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1,
    image character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    create_user bigint,
    update_user bigint,
    deleted_at timestamp without time zone
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE categories; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.categories IS '菜品分类';


--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN categories.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.categories.type IS '类型 1:菜品分类 2:套餐分类';


--
-- TOC entry 219 (class 1259 OID 16644)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 219
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 222 (class 1259 OID 16659)
-- Name: dishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishes (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    category_id bigint NOT NULL,
    price numeric(10,2) DEFAULT 0.00,
    image character varying(255),
    description character varying(255),
    status integer DEFAULT 1,
    sales_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    code character varying(32),
    create_user bigint,
    update_user bigint
);


ALTER TABLE public.dishes OWNER TO postgres;

--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE dishes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dishes IS '菜品';


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN dishes.sales_count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dishes.sales_count IS '销量统计';


--
-- TOC entry 234 (class 1259 OID 16780)
-- Name: order_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_details (
    id bigint NOT NULL,
    name character varying(32),
    image character varying(255),
    order_id bigint NOT NULL,
    dish_id bigint,
    setmeal_id bigint,
    dish_flavor character varying(50),
    number integer DEFAULT 1 NOT NULL,
    amount numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.order_details OWNER TO postgres;

--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE order_details; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.order_details IS '订单明细表';


--
-- TOC entry 232 (class 1259 OID 16753)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    number character varying(50),
    status integer DEFAULT 1 NOT NULL,
    user_id bigint NOT NULL,
    address_book_id bigint NOT NULL,
    order_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    checkout_time timestamp without time zone,
    pay_method integer DEFAULT 2 NOT NULL,
    pay_status smallint DEFAULT 0 NOT NULL,
    amount numeric(10,2) NOT NULL,
    remark character varying(100),
    phone character varying(11),
    address character varying(255),
    user_name character varying(32),
    consignee character varying(32),
    delivery_time timestamp without time zone,
    estimated_delivery_time timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    cancel_reason character varying(255),
    rejection_reason character varying(255),
    cancel_time timestamp without time zone,
    delivery_status integer DEFAULT 1 NOT NULL,
    pack_amount integer,
    tableware_number integer,
    tableware_status integer DEFAULT 1 NOT NULL,
    deleted_at timestamp without time zone,
    alipay_order_no character varying(64),
    pay_time timestamp without time zone
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.orders IS '订单表';


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN orders.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.status IS '订单状态 1:待付款 2:待接单 3:制作中 4:派送中 5:已完成 6:已取消';


--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN orders.pay_method; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.pay_method IS '支付方式 1:微信 2:支付宝';


--
-- TOC entry 238 (class 1259 OID 16845)
-- Name: category_sales_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.category_sales_stats AS
 SELECT c.id,
    c.name AS category_name,
    count(od.id) AS dish_count,
    sum(od.number) AS total_quantity,
    sum(od.amount) AS total_revenue
   FROM (((public.categories c
     JOIN public.dishes d ON ((c.id = d.category_id)))
     JOIN public.order_details od ON ((d.id = od.dish_id)))
     JOIN public.orders o ON ((od.order_id = o.id)))
  WHERE (o.status = 5)
  GROUP BY c.id, c.name
  ORDER BY (sum(od.amount)) DESC;


ALTER VIEW public.category_sales_stats OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16831)
-- Name: daily_sales_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.daily_sales_stats AS
 SELECT date(created_at) AS sale_date,
    count(*) AS order_count,
    sum(amount) AS total_amount,
    avg(amount) AS avg_amount
   FROM public.orders
  WHERE (status = 5)
  GROUP BY (date(created_at))
  ORDER BY (date(created_at)) DESC;


ALTER VIEW public.daily_sales_stats OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16680)
-- Name: dish_flavors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish_flavors (
    id bigint NOT NULL,
    dish_id bigint NOT NULL,
    name character varying(32),
    value character varying(255)
);


ALTER TABLE public.dish_flavors OWNER TO postgres;

--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE dish_flavors; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dish_flavors IS '菜品口味';


--
-- TOC entry 223 (class 1259 OID 16679)
-- Name: dish_flavors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dish_flavors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dish_flavors_id_seq OWNER TO postgres;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 223
-- Name: dish_flavors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dish_flavors_id_seq OWNED BY public.dish_flavors.id;


--
-- TOC entry 236 (class 1259 OID 16835)
-- Name: dish_sales_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dish_sales_stats AS
 SELECT d.id,
    d.name,
    d.price,
    c.name AS category_name,
    sum(od.number) AS total_sales,
    sum(od.amount) AS total_revenue
   FROM (((public.dishes d
     JOIN public.order_details od ON ((d.id = od.dish_id)))
     JOIN public.orders o ON ((od.order_id = o.id)))
     JOIN public.categories c ON ((d.category_id = c.id)))
  WHERE (o.status = 5)
  GROUP BY d.id, d.name, d.price, c.name
  ORDER BY (sum(od.number)) DESC;


ALTER VIEW public.dish_sales_stats OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16658)
-- Name: dishes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishes_id_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 221
-- Name: dishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishes_id_seq OWNED BY public.dishes.id;


--
-- TOC entry 240 (class 1259 OID 16868)
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    username character varying(32) NOT NULL,
    password character varying(64) NOT NULL,
    phone character varying(11) NOT NULL,
    sex character varying(2) NOT NULL,
    id_number character varying(18) NOT NULL,
    status bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    create_user bigint,
    update_user bigint,
    deleted_at timestamp with time zone
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16867)
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 239
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- TOC entry 233 (class 1259 OID 16779)
-- Name: order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_details_id_seq OWNER TO postgres;

--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_details_id_seq OWNED BY public.order_details.id;


--
-- TOC entry 231 (class 1259 OID 16752)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 228 (class 1259 OID 16712)
-- Name: setmeal_dishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.setmeal_dishes (
    id bigint NOT NULL,
    setmeal_id bigint,
    dish_id bigint,
    name character varying(32),
    price numeric(10,2),
    copies integer
);


ALTER TABLE public.setmeal_dishes OWNER TO postgres;

--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE setmeal_dishes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.setmeal_dishes IS '套餐菜品关系';


--
-- TOC entry 227 (class 1259 OID 16711)
-- Name: setmeal_dishes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.setmeal_dishes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.setmeal_dishes_id_seq OWNER TO postgres;

--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 227
-- Name: setmeal_dishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.setmeal_dishes_id_seq OWNED BY public.setmeal_dishes.id;


--
-- TOC entry 226 (class 1259 OID 16692)
-- Name: setmeals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.setmeals (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    name character varying(32) NOT NULL,
    price numeric(10,2) NOT NULL,
    status integer DEFAULT 1,
    description character varying(255),
    image character varying(255),
    sales_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    create_user bigint,
    update_user bigint
);


ALTER TABLE public.setmeals OWNER TO postgres;

--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE setmeals; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.setmeals IS '套餐';


--
-- TOC entry 225 (class 1259 OID 16691)
-- Name: setmeals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.setmeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.setmeals_id_seq OWNER TO postgres;

--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 225
-- Name: setmeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.setmeals_id_seq OWNED BY public.setmeals.id;


--
-- TOC entry 230 (class 1259 OID 16729)
-- Name: shopping_carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopping_carts (
    id bigint NOT NULL,
    name character varying(32),
    image character varying(255),
    user_id bigint NOT NULL,
    dish_id bigint,
    setmeal_id bigint,
    dish_flavor character varying(50),
    number integer DEFAULT 1 NOT NULL,
    amount numeric(10,2) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shopping_carts OWNER TO postgres;

--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE shopping_carts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.shopping_carts IS '购物车';


--
-- TOC entry 229 (class 1259 OID 16728)
-- Name: shopping_carts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shopping_carts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shopping_carts_id_seq OWNER TO postgres;

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 229
-- Name: shopping_carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shopping_carts_id_seq OWNED BY public.shopping_carts.id;


--
-- TOC entry 249 (class 1259 OID 16949)
-- Name: store_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store_settings (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(255),
    phone character varying(20),
    description character varying(500),
    logo character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    create_user bigint,
    update_user bigint,
    deleted_at timestamp with time zone,
    is_open boolean DEFAULT true
);


ALTER TABLE public.store_settings OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 16948)
-- Name: store_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.store_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.store_settings_id_seq OWNER TO postgres;

--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 248
-- Name: store_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.store_settings_id_seq OWNED BY public.store_settings.id;


--
-- TOC entry 218 (class 1259 OID 16613)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(32),
    phone character varying(11),
    email character varying(100),
    password character varying(64),
    sex character varying(2),
    avatar character varying(500),
    login_type bigint DEFAULT 1,
    last_login_time timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    openid character varying(45),
    deleted_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS '用户信息';


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN users.login_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.login_type IS '登录方式 1:手机号 2:邮箱';


--
-- TOC entry 237 (class 1259 OID 16840)
-- Name: user_consumption_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_consumption_stats AS
 SELECT u.id,
    u.name,
    u.phone,
    count(o.id) AS order_count,
    sum(o.amount) AS total_consumption,
    avg(o.amount) AS avg_order_amount,
    max(o.created_at) AS last_order_time
   FROM (public.users u
     JOIN public.orders o ON ((u.id = o.user_id)))
  WHERE (o.status = 5)
  GROUP BY u.id, u.name, u.phone
  ORDER BY (sum(o.amount)) DESC;


ALTER VIEW public.user_consumption_stats OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16612)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 245 (class 1259 OID 16927)
-- Name: v_category_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_category_stats AS
 SELECT c.id AS category_id,
    c.name AS category_name,
    c.type AS category_type,
    COALESCE(sum(od.amount), (0)::numeric) AS total_revenue,
    COALESCE(sum(od.number), (0)::bigint) AS total_quantity,
    count(DISTINCT od.dish_id) AS dish_count,
    count(DISTINCT o.id) AS order_count
   FROM (((public.categories c
     LEFT JOIN public.dishes d ON (((c.id = d.category_id) AND (d.deleted_at IS NULL))))
     LEFT JOIN public.order_details od ON ((d.id = od.dish_id)))
     LEFT JOIN public.orders o ON (((od.order_id = o.id) AND (o.status = 5) AND (o.deleted_at IS NULL))))
  WHERE (c.deleted_at IS NULL)
  GROUP BY c.id, c.name, c.type
  ORDER BY COALESCE(sum(od.amount), (0)::numeric) DESC;


ALTER VIEW public.v_category_stats OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16917)
-- Name: v_daily_sales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_daily_sales AS
 SELECT date(order_time) AS date,
    COALESCE(sum(amount), (0)::numeric) AS revenue,
    count(*) AS orders,
    count(DISTINCT user_id) AS customers,
    round(avg(amount), 2) AS avg_amount
   FROM public.orders
  WHERE ((status = 5) AND (deleted_at IS NULL))
  GROUP BY (date(order_time))
  ORDER BY (date(order_time)) DESC;


ALTER VIEW public.v_daily_sales OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16922)
-- Name: v_dish_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_dish_ranking AS
 SELECT d.id AS dish_id,
    d.name AS dish_name,
    c.name AS category_name,
    d.price AS dish_price,
    COALESCE(sum(od.number), (0)::bigint) AS total_quantity,
    COALESCE(sum(od.amount), (0)::numeric) AS total_revenue,
    count(DISTINCT o.id) AS order_count,
    round(avg(od.amount), 2) AS avg_revenue
   FROM (((public.dishes d
     LEFT JOIN public.categories c ON ((d.category_id = c.id)))
     LEFT JOIN public.order_details od ON ((d.id = od.dish_id)))
     LEFT JOIN public.orders o ON (((od.order_id = o.id) AND (o.status = 5) AND (o.deleted_at IS NULL))))
  WHERE (d.deleted_at IS NULL)
  GROUP BY d.id, d.name, c.name, d.price
  ORDER BY COALESCE(sum(od.number), (0)::bigint) DESC, COALESCE(sum(od.amount), (0)::numeric) DESC;


ALTER VIEW public.v_dish_ranking OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16937)
-- Name: v_monthly_revenue; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_monthly_revenue AS
 SELECT EXTRACT(year FROM order_time) AS year,
    EXTRACT(month FROM order_time) AS month,
    to_char(order_time, 'YYYY-MM'::text) AS year_month,
    count(*) AS total_orders,
    COALESCE(sum(amount), (0)::numeric) AS total_revenue,
    round(avg(amount), 2) AS avg_order_amount,
    count(DISTINCT user_id) AS unique_customers
   FROM public.orders
  WHERE ((status = 5) AND (deleted_at IS NULL))
  GROUP BY (EXTRACT(year FROM order_time)), (EXTRACT(month FROM order_time)), (to_char(order_time, 'YYYY-MM'::text))
  ORDER BY (EXTRACT(year FROM order_time)) DESC, (EXTRACT(month FROM order_time)) DESC;


ALTER VIEW public.v_monthly_revenue OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 16932)
-- Name: v_user_activity; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_user_activity AS
 SELECT u.id AS user_id,
    u.name AS user_name,
    u.phone AS user_phone,
    date(u.created_at) AS register_date,
    COALESCE(count(o.id), (0)::bigint) AS total_orders,
    COALESCE(sum(o.amount), (0)::numeric) AS total_spent,
    COALESCE(max(o.order_time), u.created_at) AS last_order_time,
        CASE
            WHEN (max(o.order_time) >= (CURRENT_DATE - '7 days'::interval)) THEN 'active'::text
            WHEN (max(o.order_time) >= (CURRENT_DATE - '30 days'::interval)) THEN 'inactive'::text
            ELSE 'dormant'::text
        END AS activity_status
   FROM (public.users u
     LEFT JOIN public.orders o ON (((u.id = o.user_id) AND (o.status = 5) AND (o.deleted_at IS NULL))))
  WHERE (u.deleted_at IS NULL)
  GROUP BY u.id, u.name, u.phone, u.created_at
  ORDER BY COALESCE(sum(o.amount), (0)::numeric) DESC;


ALTER VIEW public.v_user_activity OWNER TO postgres;

--
-- TOC entry 4825 (class 2604 OID 16881)
-- Name: address_books id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address_books ALTER COLUMN id SET DEFAULT nextval('public.address_books_id_seq'::regclass);


--
-- TOC entry 4790 (class 2604 OID 16648)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4801 (class 2604 OID 16683)
-- Name: dish_flavors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_flavors ALTER COLUMN id SET DEFAULT nextval('public.dish_flavors_id_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 16662)
-- Name: dishes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes ALTER COLUMN id SET DEFAULT nextval('public.dishes_id_seq'::regclass);


--
-- TOC entry 4823 (class 2604 OID 16871)
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- TOC entry 4819 (class 2604 OID 16783)
-- Name: order_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details ALTER COLUMN id SET DEFAULT nextval('public.order_details_id_seq'::regclass);


--
-- TOC entry 4810 (class 2604 OID 16756)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 16715)
-- Name: setmeal_dishes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeal_dishes ALTER COLUMN id SET DEFAULT nextval('public.setmeal_dishes_id_seq'::regclass);


--
-- TOC entry 4802 (class 2604 OID 16695)
-- Name: setmeals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeals ALTER COLUMN id SET DEFAULT nextval('public.setmeals_id_seq'::regclass);


--
-- TOC entry 4808 (class 2604 OID 16732)
-- Name: shopping_carts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_carts ALTER COLUMN id SET DEFAULT nextval('public.shopping_carts_id_seq'::regclass);


--
-- TOC entry 4827 (class 2604 OID 16952)
-- Name: store_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_settings ALTER COLUMN id SET DEFAULT nextval('public.store_settings_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 16616)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5085 (class 0 OID 16878)
-- Dependencies: 242
-- Data for Name: address_books; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address_books (id, user_id, consignee, sex, phone, province_code, province_name, city_code, city_name, district_code, district_name, detail, label, is_default, longitude, latitude, formatted_address, created_at, updated_at, deleted_at) FROM stdin;
3	1	张三	1	13912345678	110000	北京市	110100	北京市	110101	东城区	王府井大街1号	家	1	0.0000000	0.0000000		2025-09-07 12:46:49.247021+08	2025-09-07 12:46:49.247021+08	\N
4	1	张三	1	13912345678	110000	北京市	110100	北京市	110105	朝阳区	建国门外大街2号	公司	0	0.0000000	0.0000000		2025-09-07 12:46:49.248642+08	2025-09-07 12:46:49.248642+08	\N
5	11	李白	1	18012345678		广东省		广州市		黄埔区	3楼		1	113.4774440	23.1008430	广东省广州市黄埔区红山街道广州航海学院黄埔校区南区图书馆	2025-09-12 20:20:38.40835+08	2025-09-13 14:31:40.807457+08	2025-09-13 14:31:44.958703+08
6	11	李白	1	18012345678		广东省		广州市		黄埔区	图书馆4楼	学校	0	113.4774220	23.1009670	广东省广州市黄埔区红山街道广州航海学院黄埔校区南区图书馆	2025-09-15 17:19:07.678758+08	2025-09-16 20:05:53.715291+08	\N
7	11	李世民同学	1	13512345678		广东省		广州市		番禺区	东饭堂1楼	学校	1	113.3821090	23.0510720	广东省广州市番禺区小谷围街道华南师范大学大学城校区华南师范大学(广州校区大学城校园)	2025-09-16 20:05:53.720072+08	2025-09-16 20:05:53.720072+08	\N
8	14	杜杜鹃	0	13312345678		广东省		广州市		黄埔区	信息楼217号	学校	1	113.4782250	23.0999140	广东省广州市黄埔区红山街道红山三路97号广州航海学院黄埔校区南区	2025-09-22 11:42:09.36021+08	2025-09-22 11:42:09.36021+08	\N
\.


--
-- TOC entry 5067 (class 0 OID 16645)
-- Dependencies: 220
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, type, name, sort, status, image, created_at, updated_at, create_user, update_user, deleted_at) FROM stdin;
50	1	热菜	0	0	\N	2025-09-10 12:42:36.228152	2025-09-10 15:36:16.273913	18	18	2025-09-10 15:36:16.274194
51	2	国宾套餐	0	1	\N	2025-09-10 20:55:47.014033	2025-09-10 20:55:47.014033	18	18	\N
42	1	川菜	1	1	\N	2025-09-07 12:46:49.219171	2025-09-07 12:46:49.219171	1	1	\N
43	1	粤菜	2	1	\N	2025-09-07 12:46:49.221819	2025-09-07 12:46:49.221819	1	1	\N
44	1	湘菜	3	1	\N	2025-09-07 12:46:49.223454	2025-09-07 12:46:49.223454	1	1	\N
45	1	鲁菜	4	1	\N	2025-09-07 12:46:49.22449	2025-09-07 12:46:49.22449	1	1	\N
46	2	商务套餐	1	1	\N	2025-09-07 12:46:49.226315	2025-09-07 12:46:49.226315	1	1	\N
47	2	儿童套餐	2	1	\N	2025-09-07 12:46:49.226962	2025-09-07 12:46:49.226962	1	1	\N
49	2	热菜111	1	1	\N	2025-09-10 12:41:16.501531	2025-09-10 12:42:26.400404	18	18	2025-09-10 12:42:26.400127
\.


--
-- TOC entry 5071 (class 0 OID 16680)
-- Dependencies: 224
-- Data for Name: dish_flavors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dish_flavors (id, dish_id, name, value) FROM stdin;
10	22	辣度	["不辣","微辣","中辣","重辣"]
11	22	口味	["甜味","咸味","酸甜","麻辣"]
12	23	辣度	["微辣","中辣","重辣"]
13	25	辣度	["中辣","重辣","特辣"]
\.


--
-- TOC entry 5069 (class 0 OID 16659)
-- Dependencies: 222
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishes (id, name, category_id, price, image, description, status, sales_count, created_at, updated_at, deleted_at, code, create_user, update_user) FROM stdin;
27	海绵堡堡11	42	18.00		美味蟹堡好吃	1	0	2025-09-09 19:12:24.813616	2025-09-10 09:09:06.200578	2025-09-10 09:09:06.20072		18	18
22	宫保鸡丁	42	28.00	/uploads/dishes/1757834433778227400.jpg	经典川菜，麻辣鲜香	1	0	2025-09-07 12:46:49.229115	2025-09-14 15:20:38.340823	\N	DISH001	1	18
23	麻婆豆腐	42	18.00	/uploads/dishes/1757834528208064400.jpg	川菜名菜，麻辣鲜嫩	1	0	2025-09-07 12:46:49.231899	2025-09-14 15:22:11.184342	\N	DISH002	1	18
24	白切鸡	43	38.00	/uploads/dishes/1757834539920259700.jpg	粤式经典，清淡鲜美	1	0	2025-09-07 12:46:49.23296	2025-09-14 15:22:21.827653	\N	DISH003	1	18
25	剁椒鱼头	44	58.00	/uploads/dishes/1757834553101742200.jpg	湘菜招牌，鲜辣开胃	1	0	2025-09-07 12:46:49.23453	2025-09-14 15:22:35.261196	\N	DISH004	1	18
26	糖醋里脊	45	35.00	/uploads/dishes/1757834564370474400.jpg	酸甜可口，老少皆宜	1	0	2025-09-07 12:46:49.235865	2025-09-14 15:22:46.073061	\N	DISH005	1	18
\.


--
-- TOC entry 5083 (class 0 OID 16868)
-- Dependencies: 240
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, name, username, password, phone, sex, id_number, status, created_at, updated_at, create_user, update_user, deleted_at) FROM stdin;
18	系统管理员	admin	$2a$10$DbfSURygrWsaspiACsXI1eThLt6z9p0M7Jk5XeSwjXZ9kIHspa6gO	13800138000	1	110101199001011234	1	2025-09-07 12:44:49.056373+08	2025-09-07 12:44:49.056373+08	0	0	\N
19	店长	manager	$2a$10$DbfSURygrWsaspiACsXI1eThLt6z9p0M7Jk5XeSwjXZ9kIHspa6gO	13800138001	0	110101199002021234	1	2025-09-07 12:44:49.059374+08	2025-09-07 12:44:49.059374+08	0	0	\N
21	噜噜噜11	lll	$2a$10$HKOS1bZ7irGT0IY0tikTneEcRKKfNyXF8arSWFqRm8kEi8pe/Nyaa	13312345678	0	111222333456789088	0	2025-09-10 17:18:00.808112+08	2025-09-10 17:18:25.532461+08	18	18	2025-09-10 17:18:37.773112+08
22	张三	zhangsan	$2a$10$g20m/ceY7vrsO2dG.VgBaeLxLFD7CohtgNJF9t2qSIc.DwCTrkpbm	13800138001	1	110101199001011234	1	2025-09-11 17:40:21.456723+08	2025-09-11 17:40:21.456723+08	1	1	\N
23	李四	lisi	$2a$10$G9p9lQjDeq9TvL0RiixjWu0QM11Rvdgs0FaHP7BE5iYA8is/rQNCe	13800138002	1	110101199002021234	1	2025-09-11 17:40:21.518697+08	2025-09-11 17:40:21.518697+08	1	1	\N
24	王五	wangwu	$2a$10$tn.w82Fe7P92EO.A8eipb.o0RGZAgAbpyyw8XMmxVJ/sk9jcSrr4K	13800138003	0	110101199003031234	1	2025-09-11 17:40:21.576168+08	2025-09-11 17:40:21.576168+08	1	1	\N
\.


--
-- TOC entry 5081 (class 0 OID 16780)
-- Dependencies: 234
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_details (id, name, image, order_id, dish_id, setmeal_id, dish_flavor, number, amount, created_at, updated_at, deleted_at) FROM stdin;
1	麻婆豆腐	/images/dishes/mapo_doufu.jpg	4	23	\N		2	36.00	2025-09-07 12:51:45.9993	2025-09-07 12:51:45.99942	\N
2	白切鸡	/images/dishes/baiqie_ji.jpg	4	24	\N		2	76.00	2025-09-07 12:51:46.009996	2025-09-07 12:51:46.009824	\N
3	白切鸡	/images/dishes/baiqie_ji.jpg	5	24	\N		2	76.00	2025-09-07 12:51:46.02785	2025-09-07 12:51:46.027844	\N
4	麻婆豆腐	/images/dishes/mapo_doufu.jpg	5	23	\N		1	18.00	2025-09-07 12:51:46.029988	2025-09-07 12:51:46.029875	\N
5	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	5	22	\N		2	56.00	2025-09-07 12:51:46.031209	2025-09-07 12:51:46.031547	\N
6	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	6	25	\N		1	58.00	2025-09-07 12:51:46.039592	2025-09-07 12:51:46.038862	\N
7	糖醋里脊	/images/dishes/tangcu_liji.jpg	6	26	\N		1	35.00	2025-09-07 12:51:46.04135	2025-09-07 12:51:46.041567	\N
8	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	6	25	\N		3	174.00	2025-09-07 12:51:46.043152	2025-09-07 12:51:46.043163	\N
9	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	6	22	\N		1	28.00	2025-09-07 12:51:46.044887	2025-09-07 12:51:46.04517	\N
10	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	7	22	\N		3	84.00	2025-09-07 12:51:46.050535	2025-09-07 12:51:46.050442	\N
11	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	7	25	\N		3	174.00	2025-09-07 12:51:46.052262	2025-09-07 12:51:46.052062	\N
12	白切鸡	/images/dishes/baiqie_ji.jpg	7	24	\N		3	114.00	2025-09-07 12:51:46.05412	2025-09-07 12:51:46.054254	\N
13	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	7	25	\N		1	58.00	2025-09-07 12:51:46.055833	2025-09-07 12:51:46.055696	\N
14	白切鸡	/images/dishes/baiqie_ji.jpg	8	24	\N		3	114.00	2025-09-07 12:51:46.060533	2025-09-07 12:51:46.06056	\N
15	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	8	22	\N		1	28.00	2025-09-07 12:51:46.06157	2025-09-07 12:51:46.061811	\N
16	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	8	25	\N		1	58.00	2025-09-07 12:51:46.063715	2025-09-07 12:51:46.063549	\N
17	白切鸡	/images/dishes/baiqie_ji.jpg	8	24	\N		2	76.00	2025-09-07 12:51:46.06545	2025-09-07 12:51:46.065309	\N
18	麻婆豆腐	/images/dishes/mapo_doufu.jpg	9	23	\N		1	18.00	2025-09-07 12:51:46.07131	2025-09-07 12:51:46.071401	\N
19	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	9	22	\N		1	28.00	2025-09-07 12:51:46.073732	2025-09-07 12:51:46.073543	\N
20	白切鸡	/images/dishes/baiqie_ji.jpg	9	24	\N		1	38.00	2025-09-07 12:51:46.075593	2025-09-07 12:51:46.075779	\N
21	麻婆豆腐	/images/dishes/mapo_doufu.jpg	9	23	\N		1	18.00	2025-09-07 12:51:46.077537	2025-09-07 12:51:46.077415	\N
22	白切鸡	/images/dishes/baiqie_ji.jpg	10	24	\N		3	114.00	2025-09-07 12:51:46.085746	2025-09-07 12:51:46.085544	\N
23	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	11	25	\N		3	174.00	2025-09-07 12:51:46.090776	2025-09-07 12:51:46.091034	\N
24	白切鸡	/images/dishes/baiqie_ji.jpg	12	24	\N		1	38.00	2025-09-07 12:51:46.097801	2025-09-07 12:51:46.097946	\N
25	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	12	22	\N		2	56.00	2025-09-07 12:51:46.100004	2025-09-07 12:51:46.099948	\N
26	糖醋里脊	/images/dishes/tangcu_liji.jpg	12	26	\N		1	35.00	2025-09-07 12:51:46.101867	2025-09-07 12:51:46.101772	\N
27	糖醋里脊	/images/dishes/tangcu_liji.jpg	13	26	\N		2	70.00	2025-09-07 12:51:46.108889	2025-09-07 12:51:46.109037	\N
28	白切鸡	/images/dishes/baiqie_ji.jpg	13	24	\N		1	38.00	2025-09-07 12:51:46.111906	2025-09-07 12:51:46.111494	\N
29	麻婆豆腐	/images/dishes/mapo_doufu.jpg	13	23	\N		3	54.00	2025-09-07 12:51:46.116357	2025-09-07 12:51:46.115927	\N
30	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	13	22	\N		1	28.00	2025-09-07 12:51:46.118572	2025-09-07 12:51:46.118438	\N
31	糖醋里脊	/images/dishes/tangcu_liji.jpg	14	26	\N		2	70.00	2025-09-07 12:51:46.124804	2025-09-07 12:51:46.124789	\N
32	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	14	25	\N		3	174.00	2025-09-07 12:51:46.126785	2025-09-07 12:51:46.12663	\N
33	麻婆豆腐	/images/dishes/mapo_doufu.jpg	14	23	\N		2	36.00	2025-09-07 12:51:46.128477	2025-09-07 12:51:46.128724	\N
34	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	15	22	\N		3	84.00	2025-09-07 12:51:46.135276	2025-09-07 12:51:46.135295	\N
35	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	15	22	\N		2	56.00	2025-09-07 12:51:46.137347	2025-09-07 12:51:46.137178	\N
36	麻婆豆腐	/images/dishes/mapo_doufu.jpg	15	23	\N		1	18.00	2025-09-07 12:51:46.139044	2025-09-07 12:51:46.139023	\N
37	糖醋里脊	/images/dishes/tangcu_liji.jpg	16	26	\N		3	105.00	2025-09-07 12:51:46.145785	2025-09-07 12:51:46.145977	\N
38	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	16	22	\N		2	56.00	2025-09-07 12:51:46.147837	2025-09-07 12:51:46.147707	\N
39	糖醋里脊	/images/dishes/tangcu_liji.jpg	16	26	\N		2	70.00	2025-09-07 12:51:46.149629	2025-09-07 12:51:46.149681	\N
40	糖醋里脊	/images/dishes/tangcu_liji.jpg	17	26	\N		2	70.00	2025-09-07 12:51:46.155749	2025-09-07 12:51:46.155702	\N
41	白切鸡	/images/dishes/baiqie_ji.jpg	17	24	\N		3	114.00	2025-09-07 12:51:46.157411	2025-09-07 12:51:46.157342	\N
42	糖醋里脊	/images/dishes/tangcu_liji.jpg	17	26	\N		3	105.00	2025-09-07 12:51:46.160268	2025-09-07 12:51:46.160459	\N
43	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	18	22	\N		1	28.00	2025-09-07 12:51:46.166978	2025-09-07 12:51:46.167	\N
44	白切鸡	/images/dishes/baiqie_ji.jpg	18	24	\N		2	76.00	2025-09-07 12:51:46.169142	2025-09-07 12:51:46.169074	\N
45	白切鸡	/images/dishes/baiqie_ji.jpg	18	24	\N		1	38.00	2025-09-07 12:51:46.170879	2025-09-07 12:51:46.171019	\N
46	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	19	25	\N		1	58.00	2025-09-07 12:51:46.178637	2025-09-07 12:51:46.179033	\N
47	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	19	25	\N		2	116.00	2025-09-07 12:51:46.180978	2025-09-07 12:51:46.181031	\N
48	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	19	22	\N		2	56.00	2025-09-07 12:51:46.183048	2025-09-07 12:51:46.182856	\N
49	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	19	25	\N		2	116.00	2025-09-07 12:51:46.184667	2025-09-07 12:51:46.184849	\N
50	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	20	25	\N		2	116.00	2025-09-07 12:51:46.191441	2025-09-07 12:51:46.191236	\N
51	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	20	22	\N		2	56.00	2025-09-07 12:51:46.193657	2025-09-07 12:51:46.193718	\N
52	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	21	25	\N		3	174.00	2025-09-07 12:51:46.199695	2025-09-07 12:51:46.199531	\N
53	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	22	22	\N		1	28.00	2025-09-07 12:51:46.208311	2025-09-07 12:51:46.208223	\N
54	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	22	22	\N		2	56.00	2025-09-07 12:51:46.21004	2025-09-07 12:51:46.209936	\N
55	麻婆豆腐	/images/dishes/mapo_doufu.jpg	22	23	\N		1	18.00	2025-09-07 12:51:46.212268	2025-09-07 12:51:46.212099	\N
56	麻婆豆腐	/images/dishes/mapo_doufu.jpg	22	23	\N		1	18.00	2025-09-07 12:51:46.214385	2025-09-07 12:51:46.214307	\N
57	麻婆豆腐	/images/dishes/mapo_doufu.jpg	23	23	\N		1	18.00	2025-09-07 12:51:46.220455	2025-09-07 12:51:46.220355	\N
58	白切鸡	/images/dishes/baiqie_ji.jpg	24	24	\N		1	38.00	2025-09-07 12:51:46.227469	2025-09-07 12:51:46.227483	\N
59	麻婆豆腐	/images/dishes/mapo_doufu.jpg	24	23	\N		2	36.00	2025-09-07 12:51:46.229303	2025-09-07 12:51:46.229307	\N
60	麻婆豆腐	/images/dishes/mapo_doufu.jpg	25	23	\N		1	18.00	2025-09-07 12:51:46.236546	2025-09-07 12:51:46.236644	\N
61	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	25	25	\N		3	174.00	2025-09-07 12:51:46.24037	2025-09-07 12:51:46.240486	\N
62	糖醋里脊	/images/dishes/tangcu_liji.jpg	26	26	\N		3	105.00	2025-09-07 12:51:46.245752	2025-09-07 12:51:46.24613	\N
63	白切鸡	/images/dishes/baiqie_ji.jpg	26	24	\N		1	38.00	2025-09-07 12:51:46.24738	2025-09-07 12:51:46.247731	\N
64	麻婆豆腐	/images/dishes/mapo_doufu.jpg	26	23	\N		1	18.00	2025-09-07 12:51:46.249052	2025-09-07 12:51:46.249295	\N
65	麻婆豆腐	/images/dishes/mapo_doufu.jpg	27	23	\N		2	36.00	2025-09-07 12:51:46.254999	2025-09-07 12:51:46.254916	\N
66	白切鸡	/images/dishes/baiqie_ji.jpg	27	24	\N		2	76.00	2025-09-07 12:51:46.256166	2025-09-07 12:51:46.256464	\N
67	白切鸡	/images/dishes/baiqie_ji.jpg	27	24	\N		1	38.00	2025-09-07 12:51:46.257535	2025-09-07 12:51:46.257816	\N
68	糖醋里脊	/images/dishes/tangcu_liji.jpg	28	26	\N		3	105.00	2025-09-07 12:51:46.2637	2025-09-07 12:51:46.26353	\N
69	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	29	22	\N		2	56.00	2025-09-07 12:51:46.269498	2025-09-07 12:51:46.269373	\N
70	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	30	25	\N		3	174.00	2025-09-07 12:51:46.274317	2025-09-07 12:51:46.27446	\N
71	糖醋里脊	/images/dishes/tangcu_liji.jpg	30	26	\N		3	105.00	2025-09-07 12:51:46.275199	2025-09-07 12:51:46.275911	\N
72	糖醋里脊	/images/dishes/tangcu_liji.jpg	30	26	\N		2	70.00	2025-09-07 12:51:46.277591	2025-09-07 12:51:46.277547	\N
73	糖醋里脊	/images/dishes/tangcu_liji.jpg	30	26	\N		2	70.00	2025-09-07 12:51:46.279474	2025-09-07 12:51:46.279347	\N
74	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	31	25	\N		1	58.00	2025-09-07 12:51:46.28591	2025-09-07 12:51:46.286121	\N
75	白切鸡	/images/dishes/baiqie_ji.jpg	31	24	\N		1	38.00	2025-09-07 12:51:46.287609	2025-09-07 12:51:46.287544	\N
76	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	32	22	\N		3	84.00	2025-09-07 12:51:46.293136	2025-09-07 12:51:46.293136	\N
77	麻婆豆腐	/images/dishes/mapo_doufu.jpg	33	23	\N		3	54.00	2025-09-07 12:51:46.300287	2025-09-07 12:51:46.300622	\N
78	麻婆豆腐	/images/dishes/mapo_doufu.jpg	33	23	\N		2	36.00	2025-09-07 12:51:46.302695	2025-09-07 12:51:46.302539	\N
79	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	33	22	\N		2	56.00	2025-09-07 12:51:46.30436	2025-09-07 12:51:46.30444	\N
80	糖醋里脊	/images/dishes/tangcu_liji.jpg	33	26	\N		1	35.00	2025-09-07 12:51:46.306325	2025-09-07 12:51:46.306416	\N
81	麻婆豆腐	/images/dishes/mapo_doufu.jpg	34	23	\N		2	36.00	2025-09-07 12:51:46.309801	2025-09-07 12:51:46.310036	\N
82	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	34	22	\N		2	56.00	2025-09-07 12:51:46.311934	2025-09-07 12:51:46.312062	\N
83	麻婆豆腐	/images/dishes/mapo_doufu.jpg	34	23	\N		2	36.00	2025-09-07 12:51:46.314507	2025-09-07 12:51:46.314405	\N
84	糖醋里脊	/images/dishes/tangcu_liji.jpg	34	26	\N		2	70.00	2025-09-07 12:51:46.316555	2025-09-07 12:51:46.316367	\N
85	白切鸡	/images/dishes/baiqie_ji.jpg	35	24	\N		3	114.00	2025-09-07 12:51:46.32119	2025-09-07 12:51:46.321125	\N
86	糖醋里脊	/images/dishes/tangcu_liji.jpg	36	26	\N		3	105.00	2025-09-07 12:51:46.328204	2025-09-07 12:51:46.328236	\N
87	糖醋里脊	/images/dishes/tangcu_liji.jpg	36	26	\N		3	105.00	2025-09-07 12:51:46.329289	2025-09-07 12:51:46.329668	\N
88	麻婆豆腐	/images/dishes/mapo_doufu.jpg	37	23	\N		2	36.00	2025-09-07 12:51:46.334486	2025-09-07 12:51:46.334565	\N
89	糖醋里脊	/images/dishes/tangcu_liji.jpg	38	26	\N		2	70.00	2025-09-07 12:51:46.339135	2025-09-07 12:51:46.339239	\N
90	糖醋里脊	/images/dishes/tangcu_liji.jpg	38	26	\N		1	35.00	2025-09-07 12:51:46.340753	2025-09-07 12:51:46.340815	\N
91	白切鸡	/images/dishes/baiqie_ji.jpg	38	24	\N		1	38.00	2025-09-07 12:51:46.341853	2025-09-07 12:51:46.342092	\N
92	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	38	22	\N		3	84.00	2025-09-07 12:51:46.344101	2025-09-07 12:51:46.344308	\N
93	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	39	25	\N		2	116.00	2025-09-07 12:51:46.349699	2025-09-07 12:51:46.349568	\N
94	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	39	25	\N		1	58.00	2025-09-07 12:51:46.351201	2025-09-07 12:51:46.351041	\N
95	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	40	22	\N		2	56.00	2025-09-07 12:51:46.357685	2025-09-07 12:51:46.357466	\N
96	白切鸡	/images/dishes/baiqie_ji.jpg	41	24	\N		3	114.00	2025-09-07 12:51:46.36479	2025-09-07 12:51:46.364668	\N
97	糖醋里脊	/images/dishes/tangcu_liji.jpg	42	26	\N		2	70.00	2025-09-07 12:51:46.369748	2025-09-07 12:51:46.369782	\N
98	糖醋里脊	/images/dishes/tangcu_liji.jpg	42	26	\N		1	35.00	2025-09-07 12:51:46.370811	2025-09-07 12:51:46.371042	\N
99	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	43	22	\N		3	84.00	2025-09-07 12:51:46.377353	2025-09-07 12:51:46.377392	\N
100	糖醋里脊	/images/dishes/tangcu_liji.jpg	43	26	\N		2	70.00	2025-09-07 12:51:46.379169	2025-09-07 12:51:46.37926	\N
101	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	43	22	\N		3	84.00	2025-09-07 12:51:46.3813	2025-09-07 12:51:46.381165	\N
102	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	43	25	\N		2	116.00	2025-09-07 12:51:46.383049	2025-09-07 12:51:46.383052	\N
103	白切鸡	/images/dishes/baiqie_ji.jpg	44	24	\N		3	114.00	2025-09-07 12:51:46.388141	2025-09-07 12:51:46.387996	\N
104	白切鸡	/images/dishes/baiqie_ji.jpg	44	24	\N		3	114.00	2025-09-07 12:51:46.389884	2025-09-07 12:51:46.389921	\N
105	糖醋里脊	/images/dishes/tangcu_liji.jpg	44	26	\N		1	35.00	2025-09-07 12:51:46.391535	2025-09-07 12:51:46.391508	\N
106	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	44	22	\N		3	84.00	2025-09-07 12:51:46.393815	2025-09-07 12:51:46.39393	\N
107	白切鸡	/images/dishes/baiqie_ji.jpg	45	24	\N		1	38.00	2025-09-07 12:51:46.399162	2025-09-07 12:51:46.399362	\N
108	糖醋里脊	/images/dishes/tangcu_liji.jpg	45	26	\N		3	105.00	2025-09-07 12:51:46.401327	2025-09-07 12:51:46.401237	\N
109	麻婆豆腐	/images/dishes/mapo_doufu.jpg	45	23	\N		2	36.00	2025-09-07 12:51:46.403135	2025-09-07 12:51:46.403281	\N
110	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	45	25	\N		3	174.00	2025-09-07 12:51:46.405355	2025-09-07 12:51:46.405594	\N
111	糖醋里脊	/images/dishes/tangcu_liji.jpg	46	26	\N		3	105.00	2025-09-07 12:51:46.410652	2025-09-07 12:51:46.410697	\N
112	白切鸡	/images/dishes/baiqie_ji.jpg	46	24	\N		1	38.00	2025-09-07 12:51:46.412489	2025-09-07 12:51:46.412339	\N
113	白切鸡	/images/dishes/baiqie_ji.jpg	46	24	\N		3	114.00	2025-09-07 12:51:46.41414	2025-09-07 12:51:46.414187	\N
114	糖醋里脊	/images/dishes/tangcu_liji.jpg	47	26	\N		3	105.00	2025-09-07 12:51:46.419794	2025-09-07 12:51:46.420081	\N
115	麻婆豆腐	/images/dishes/mapo_doufu.jpg	47	23	\N		3	54.00	2025-09-07 12:51:46.420862	2025-09-07 12:51:46.421596	\N
116	白切鸡	/images/dishes/baiqie_ji.jpg	48	24	\N		3	114.00	2025-09-07 12:51:46.427881	2025-09-07 12:51:46.427909	\N
117	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	48	25	\N		3	174.00	2025-09-07 12:51:46.429032	2025-09-07 12:51:46.429361	\N
118	糖醋里脊	/images/dishes/tangcu_liji.jpg	48	26	\N		3	105.00	2025-09-07 12:51:46.430513	2025-09-07 12:51:46.43086	\N
119	白切鸡	/images/dishes/baiqie_ji.jpg	49	24	\N		2	76.00	2025-09-07 12:51:46.4371	2025-09-07 12:51:46.437166	\N
120	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	50	25	\N		2	116.00	2025-09-07 12:51:46.443109	2025-09-07 12:51:46.443007	\N
121	糖醋里脊	/images/dishes/tangcu_liji.jpg	50	26	\N		2	70.00	2025-09-07 12:51:46.444588	2025-09-07 12:51:46.444895	\N
122	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	50	25	\N		3	174.00	2025-09-07 12:51:46.446852	2025-09-07 12:51:46.446805	\N
123	麻婆豆腐	/images/dishes/mapo_doufu.jpg	51	23	\N		2	36.00	2025-09-07 12:51:46.452334	2025-09-07 12:51:46.452663	\N
124	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	51	25	\N		1	58.00	2025-09-07 12:51:46.454737	2025-09-07 12:51:46.454552	\N
125	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	52	25	\N		2	116.00	2025-09-07 12:51:46.459248	2025-09-07 12:51:46.45921	\N
126	白切鸡	/images/dishes/baiqie_ji.jpg	52	24	\N		3	114.00	2025-09-07 12:51:46.46041	2025-09-07 12:51:46.460669	\N
127	麻婆豆腐	/images/dishes/mapo_doufu.jpg	53	23	\N		1	18.00	2025-09-07 12:51:46.467043	2025-09-07 12:51:46.467221	\N
128	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	53	25	\N		1	58.00	2025-09-07 12:51:46.468815	2025-09-07 12:51:46.469027	\N
129	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	53	22	\N		2	56.00	2025-09-07 12:51:46.470588	2025-09-07 12:51:46.470619	\N
130	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	53	25	\N		3	174.00	2025-09-07 12:51:46.472314	2025-09-07 12:51:46.472084	\N
131	白切鸡	/images/dishes/baiqie_ji.jpg	54	24	\N		1	38.00	2025-09-07 12:51:46.479339	2025-09-07 12:51:46.479528	\N
132	糖醋里脊	/images/dishes/tangcu_liji.jpg	54	26	\N		2	70.00	2025-09-07 12:51:46.483909	2025-09-07 12:51:46.483486	\N
133	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	55	22	\N		2	56.00	2025-09-07 12:51:46.489194	2025-09-07 12:51:46.489252	\N
134	白切鸡	/images/dishes/baiqie_ji.jpg	55	24	\N		1	38.00	2025-09-07 12:51:46.491052	2025-09-07 12:51:46.49096	\N
135	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	55	22	\N		3	84.00	2025-09-07 12:51:46.492303	2025-09-07 12:51:46.492182	\N
136	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	55	25	\N		2	116.00	2025-09-07 12:51:46.494938	2025-09-07 12:51:46.494866	\N
137	麻婆豆腐	/images/dishes/mapo_doufu.jpg	56	23	\N		3	54.00	2025-09-07 12:51:46.500205	2025-09-07 12:51:46.500304	\N
138	白切鸡	/images/dishes/baiqie_ji.jpg	56	24	\N		1	38.00	2025-09-07 12:51:46.502253	2025-09-07 12:51:46.502096	\N
139	白切鸡	/images/dishes/baiqie_ji.jpg	57	24	\N		3	114.00	2025-09-07 12:51:46.508507	2025-09-07 12:51:46.508318	\N
140	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	57	25	\N		3	174.00	2025-09-07 12:51:46.510283	2025-09-07 12:51:46.510115	\N
141	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	57	22	\N		2	56.00	2025-09-07 12:51:46.513622	2025-09-07 12:51:46.513679	\N
142	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	57	25	\N		1	58.00	2025-09-07 12:51:46.515568	2025-09-07 12:51:46.515886	\N
143	麻婆豆腐	/images/dishes/mapo_doufu.jpg	58	23	\N		3	54.00	2025-09-07 12:51:46.521101	2025-09-07 12:51:46.521336	\N
144	白切鸡	/images/dishes/baiqie_ji.jpg	58	24	\N		3	114.00	2025-09-07 12:51:46.524015	2025-09-07 12:51:46.524375	\N
145	糖醋里脊	/images/dishes/tangcu_liji.jpg	58	26	\N		1	35.00	2025-09-07 12:51:46.52668	2025-09-07 12:51:46.526406	\N
146	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	59	25	\N		1	58.00	2025-09-07 12:51:46.531543	2025-09-07 12:51:46.531529	\N
147	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	59	22	\N		3	84.00	2025-09-07 12:51:46.53328	2025-09-07 12:51:46.533247	\N
148	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	59	22	\N		1	28.00	2025-09-07 12:51:46.534534	2025-09-07 12:51:46.534912	\N
149	糖醋里脊	/images/dishes/tangcu_liji.jpg	59	26	\N		2	70.00	2025-09-07 12:51:46.536137	2025-09-07 12:51:46.536264	\N
150	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	60	25	\N		3	174.00	2025-09-07 12:51:46.540139	2025-09-07 12:51:46.539996	\N
151	糖醋里脊	/images/dishes/tangcu_liji.jpg	60	26	\N		2	70.00	2025-09-07 12:51:46.540856	2025-09-07 12:51:46.541187	\N
152	麻婆豆腐	/images/dishes/mapo_doufu.jpg	60	23	\N		3	54.00	2025-09-07 12:51:46.543373	2025-09-07 12:51:46.54323	\N
153	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	60	25	\N		1	58.00	2025-09-07 12:51:46.544842	2025-09-07 12:51:46.544779	\N
154	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	61	25	\N		2	116.00	2025-09-07 12:51:46.549212	2025-09-07 12:51:46.549172	\N
155	白切鸡	/images/dishes/baiqie_ji.jpg	61	24	\N		3	114.00	2025-09-07 12:51:46.550461	2025-09-07 12:51:46.550357	\N
156	麻婆豆腐	/images/dishes/mapo_doufu.jpg	61	23	\N		3	54.00	2025-09-07 12:51:46.551542	2025-09-07 12:51:46.551779	\N
157	白切鸡	/images/dishes/baiqie_ji.jpg	62	24	\N		1	38.00	2025-09-07 12:51:46.558073	2025-09-07 12:51:46.557951	\N
158	白切鸡	/images/dishes/baiqie_ji.jpg	63	24	\N		1	38.00	2025-09-07 12:51:46.561463	2025-09-07 12:51:46.561719	\N
159	白切鸡	/images/dishes/baiqie_ji.jpg	64	24	\N		3	114.00	2025-09-07 12:51:46.566971	2025-09-07 12:51:46.566866	\N
160	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	64	25	\N		1	58.00	2025-09-07 12:51:46.568052	2025-09-07 12:51:46.568269	\N
161	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	65	22	\N		1	28.00	2025-09-07 12:51:46.571245	2025-09-07 12:51:46.571609	\N
162	糖醋里脊	/images/dishes/tangcu_liji.jpg	65	26	\N		1	35.00	2025-09-07 12:51:46.574149	2025-09-07 12:51:46.573984	\N
163	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	65	25	\N		2	116.00	2025-09-07 12:51:46.57562	2025-09-07 12:51:46.575649	\N
164	糖醋里脊	/images/dishes/tangcu_liji.jpg	65	26	\N		1	35.00	2025-09-07 12:51:46.577271	2025-09-07 12:51:46.577645	\N
165	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	66	22	\N		3	84.00	2025-09-07 12:51:46.580746	2025-09-07 12:51:46.5811	\N
166	糖醋里脊	/images/dishes/tangcu_liji.jpg	67	26	\N		2	70.00	2025-09-07 12:51:46.586186	2025-09-07 12:51:46.586041	\N
167	糖醋里脊	/images/dishes/tangcu_liji.jpg	68	26	\N		1	35.00	2025-09-07 12:51:46.590463	2025-09-07 12:51:46.590793	\N
168	糖醋里脊	/images/dishes/tangcu_liji.jpg	69	26	\N		3	105.00	2025-09-07 12:51:46.595534	2025-09-07 12:51:46.595585	\N
169	白切鸡	/images/dishes/baiqie_ji.jpg	70	24	\N		3	114.00	2025-09-07 12:51:46.599499	2025-09-07 12:51:46.599789	\N
170	白切鸡	/images/dishes/baiqie_ji.jpg	70	24	\N		3	114.00	2025-09-07 12:51:46.600714	2025-09-07 12:51:46.600967	\N
171	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	70	22	\N		2	56.00	2025-09-07 12:51:46.602045	2025-09-07 12:51:46.602237	\N
172	麻婆豆腐	/images/dishes/mapo_doufu.jpg	71	23	\N		3	54.00	2025-09-07 12:51:46.608655	2025-09-07 12:51:46.608497	\N
173	白切鸡	/images/dishes/baiqie_ji.jpg	72	24	\N		1	38.00	2025-09-07 12:51:46.61218	2025-09-07 12:51:46.612486	\N
174	麻婆豆腐	/images/dishes/mapo_doufu.jpg	73	23	\N		2	36.00	2025-09-07 12:51:46.617263	2025-09-07 12:51:46.617145	\N
175	麻婆豆腐	/images/dishes/mapo_doufu.jpg	73	23	\N		1	18.00	2025-09-07 12:51:46.618938	2025-09-07 12:51:46.618786	\N
176	白切鸡	/images/dishes/baiqie_ji.jpg	73	24	\N		2	76.00	2025-09-07 12:51:46.620567	2025-09-07 12:51:46.620576	\N
177	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	73	25	\N		2	116.00	2025-09-07 12:51:46.621631	2025-09-07 12:51:46.621705	\N
178	麻婆豆腐	/images/dishes/mapo_doufu.jpg	74	23	\N		3	54.00	2025-09-07 12:51:46.625868	2025-09-07 12:51:46.626198	\N
179	糖醋里脊	/images/dishes/tangcu_liji.jpg	74	26	\N		3	105.00	2025-09-07 12:51:46.627779	2025-09-07 12:51:46.627628	\N
180	白切鸡	/images/dishes/baiqie_ji.jpg	74	24	\N		3	114.00	2025-09-07 12:51:46.62854	2025-09-07 12:51:46.62886	\N
181	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	74	25	\N		3	174.00	2025-09-07 12:51:46.629821	2025-09-07 12:51:46.630128	\N
182	糖醋里脊	/images/dishes/tangcu_liji.jpg	75	26	\N		1	35.00	2025-09-07 12:51:46.635219	2025-09-07 12:51:46.635172	\N
183	白切鸡	/images/dishes/baiqie_ji.jpg	75	24	\N		3	114.00	2025-09-07 12:51:46.637602	2025-09-07 12:51:46.637502	\N
184	白切鸡	/images/dishes/baiqie_ji.jpg	76	24	\N		1	38.00	2025-09-07 12:51:46.641352	2025-09-07 12:51:46.641426	\N
185	麻婆豆腐	/images/dishes/mapo_doufu.jpg	76	23	\N		1	18.00	2025-09-07 12:51:46.642404	2025-09-07 12:51:46.642765	\N
186	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	76	25	\N		2	116.00	2025-09-07 12:51:46.644659	2025-09-07 12:51:46.644784	\N
187	糖醋里脊	/images/dishes/tangcu_liji.jpg	76	26	\N		3	105.00	2025-09-07 12:51:46.645911	2025-09-07 12:51:46.646246	\N
188	糖醋里脊	/images/dishes/tangcu_liji.jpg	77	26	\N		1	35.00	2025-09-07 12:51:46.650721	2025-09-07 12:51:46.651073	\N
189	麻婆豆腐	/images/dishes/mapo_doufu.jpg	77	23	\N		3	54.00	2025-09-07 12:51:46.652393	2025-09-07 12:51:46.65244	\N
190	糖醋里脊	/images/dishes/tangcu_liji.jpg	77	26	\N		3	105.00	2025-09-07 12:51:46.654785	2025-09-07 12:51:46.654801	\N
191	糖醋里脊	/images/dishes/tangcu_liji.jpg	78	26	\N		2	70.00	2025-09-07 12:51:46.659216	2025-09-07 12:51:46.659361	\N
192	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	78	22	\N		2	56.00	2025-09-07 12:51:46.660306	2025-09-07 12:51:46.660649	\N
193	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	78	22	\N		3	84.00	2025-09-07 12:51:46.6614	2025-09-07 12:51:46.661705	\N
194	麻婆豆腐	/images/dishes/mapo_doufu.jpg	78	23	\N		1	18.00	2025-09-07 12:51:46.663612	2025-09-07 12:51:46.663115	\N
195	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	79	25	\N		3	174.00	2025-09-07 12:51:46.668887	2025-09-07 12:51:46.668663	\N
196	白切鸡	/images/dishes/baiqie_ji.jpg	79	24	\N		1	38.00	2025-09-07 12:51:46.670462	2025-09-07 12:51:46.670286	\N
197	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	79	22	\N		2	56.00	2025-09-07 12:51:46.671178	2025-09-07 12:51:46.67149	\N
198	白切鸡	/images/dishes/baiqie_ji.jpg	80	24	\N		3	114.00	2025-09-07 12:51:46.677021	2025-09-07 12:51:46.677362	\N
199	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	80	25	\N		3	174.00	2025-09-07 12:51:46.679072	2025-09-07 12:51:46.679293	\N
200	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	80	25	\N		2	116.00	2025-09-07 12:51:46.681269	2025-09-07 12:51:46.681126	\N
201	白切鸡	/images/dishes/baiqie_ji.jpg	80	24	\N		1	38.00	2025-09-07 12:51:46.682674	2025-09-07 12:51:46.682523	\N
202	麻婆豆腐	/images/dishes/mapo_doufu.jpg	81	23	\N		2	36.00	2025-09-07 12:51:46.687737	2025-09-07 12:51:46.687591	\N
203	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	82	22	\N		1	28.00	2025-09-07 12:51:46.691571	2025-09-07 12:51:46.691981	\N
204	糖醋里脊	/images/dishes/tangcu_liji.jpg	83	26	\N		2	70.00	2025-09-07 12:51:46.698091	2025-09-07 12:51:46.698081	\N
205	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	83	22	\N		1	28.00	2025-09-07 12:51:46.699896	2025-09-07 12:51:46.699736	\N
206	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	84	25	\N		3	174.00	2025-09-07 12:51:46.705886	2025-09-07 12:51:46.705822	\N
207	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	84	25	\N		2	116.00	2025-09-07 12:51:46.706985	2025-09-07 12:51:46.707152	\N
208	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	84	25	\N		2	116.00	2025-09-07 12:51:46.708369	2025-09-07 12:51:46.708708	\N
209	糖醋里脊	/images/dishes/tangcu_liji.jpg	84	26	\N		1	35.00	2025-09-07 12:51:46.710604	2025-09-07 12:51:46.71086	\N
210	白切鸡	/images/dishes/baiqie_ji.jpg	85	24	\N		1	38.00	2025-09-07 12:51:46.716188	2025-09-07 12:51:46.716372	\N
211	麻婆豆腐	/images/dishes/mapo_doufu.jpg	86	23	\N		2	36.00	2025-09-07 12:51:46.722151	2025-09-07 12:51:46.722143	\N
212	麻婆豆腐	/images/dishes/mapo_doufu.jpg	86	23	\N		2	36.00	2025-09-07 12:51:46.724299	2025-09-07 12:51:46.724458	\N
213	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	86	22	\N		2	56.00	2025-09-07 12:51:46.726914	2025-09-07 12:51:46.727041	\N
214	糖醋里脊	/images/dishes/tangcu_liji.jpg	87	26	\N		1	35.00	2025-09-07 12:51:46.732147	2025-09-07 12:51:46.731991	\N
215	糖醋里脊	/images/dishes/tangcu_liji.jpg	87	26	\N		2	70.00	2025-09-07 12:51:46.734068	2025-09-07 12:51:46.734022	\N
216	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	87	25	\N		1	58.00	2025-09-07 12:51:46.735941	2025-09-07 12:51:46.735939	\N
217	糖醋里脊	/images/dishes/tangcu_liji.jpg	87	26	\N		3	105.00	2025-09-07 12:51:46.737221	2025-09-07 12:51:46.737509	\N
218	白切鸡	/images/dishes/baiqie_ji.jpg	88	24	\N		2	76.00	2025-09-07 12:51:46.743237	2025-09-07 12:51:46.743509	\N
219	糖醋里脊	/images/dishes/tangcu_liji.jpg	89	26	\N		3	105.00	2025-09-07 12:51:46.748569	2025-09-07 12:51:46.748503	\N
220	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	90	22	\N		2	56.00	2025-09-07 12:51:46.752709	2025-09-07 12:51:46.7528	\N
221	糖醋里脊	/images/dishes/tangcu_liji.jpg	91	26	\N		3	105.00	2025-09-07 12:51:46.759333	2025-09-07 12:51:46.759508	\N
222	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	91	22	\N		3	84.00	2025-09-07 12:51:46.761278	2025-09-07 12:51:46.761186	\N
223	白切鸡	/images/dishes/baiqie_ji.jpg	92	24	\N		2	76.00	2025-09-07 12:51:46.767838	2025-09-07 12:51:46.767712	\N
224	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	92	25	\N		2	116.00	2025-09-07 12:51:46.769442	2025-09-07 12:51:46.769267	\N
225	白切鸡	/images/dishes/baiqie_ji.jpg	92	24	\N		3	114.00	2025-09-07 12:51:46.771084	2025-09-07 12:51:46.771113	\N
226	糖醋里脊	/images/dishes/tangcu_liji.jpg	92	26	\N		1	35.00	2025-09-07 12:51:46.773335	2025-09-07 12:51:46.773478	\N
227	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	93	22	\N		2	56.00	2025-09-07 12:51:46.778702	2025-09-07 12:51:46.778683	\N
228	麻婆豆腐	/images/dishes/mapo_doufu.jpg	93	23	\N		1	18.00	2025-09-07 12:51:46.780375	2025-09-07 12:51:46.780565	\N
229	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	93	22	\N		2	56.00	2025-09-07 12:51:46.782582	2025-09-07 12:51:46.782427	\N
230	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	93	25	\N		2	116.00	2025-09-07 12:51:46.784481	2025-09-07 12:51:46.784483	\N
231	糖醋里脊	/images/dishes/tangcu_liji.jpg	94	26	\N		2	70.00	2025-09-07 12:51:46.789685	2025-09-07 12:51:46.789813	\N
232	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	95	25	\N		3	174.00	2025-09-07 12:51:46.795111	2025-09-07 12:51:46.794996	\N
233	糖醋里脊	/images/dishes/tangcu_liji.jpg	95	26	\N		1	35.00	2025-09-07 12:51:46.796942	2025-09-07 12:51:46.796811	\N
234	白切鸡	/images/dishes/baiqie_ji.jpg	96	24	\N		1	38.00	2025-09-07 12:51:46.80274	2025-09-07 12:51:46.802904	\N
235	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	97	22	\N		2	56.00	2025-09-07 12:51:46.808355	2025-09-07 12:51:46.80854	\N
236	白切鸡	/images/dishes/baiqie_ji.jpg	97	24	\N		2	76.00	2025-09-07 12:51:46.809989	2025-09-07 12:51:46.810087	\N
237	麻婆豆腐	/images/dishes/mapo_doufu.jpg	98	23	\N		2	36.00	2025-09-07 12:51:46.815245	2025-09-07 12:51:46.815526	\N
238	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	98	25	\N		2	116.00	2025-09-07 12:51:46.817887	2025-09-07 12:51:46.818125	\N
239	糖醋里脊	/images/dishes/tangcu_liji.jpg	99	26	\N		2	70.00	2025-09-07 12:51:46.824085	2025-09-07 12:51:46.824252	\N
240	麻婆豆腐	/images/dishes/mapo_doufu.jpg	99	23	\N		2	36.00	2025-09-07 12:51:46.826058	2025-09-07 12:51:46.82594	\N
241	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	100	25	\N		2	116.00	2025-09-07 12:51:46.83109	2025-09-07 12:51:46.83097	\N
242	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	101	25	\N		1	58.00	2025-09-07 12:51:46.837289	2025-09-07 12:51:46.837147	\N
243	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	102	25	\N		2	116.00	2025-09-07 12:51:46.842274	2025-09-07 12:51:46.842093	\N
244	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	102	22	\N		1	28.00	2025-09-07 12:51:46.844983	2025-09-07 12:51:46.844799	\N
245	白切鸡	/images/dishes/baiqie_ji.jpg	102	24	\N		3	114.00	2025-09-07 12:51:46.846704	2025-09-07 12:51:46.84663	\N
246	白切鸡	/images/dishes/baiqie_ji.jpg	102	24	\N		2	76.00	2025-09-07 12:51:46.848921	2025-09-07 12:51:46.848736	\N
247	糖醋里脊	/images/dishes/tangcu_liji.jpg	103	26	\N		3	105.00	2025-09-07 12:51:46.85459	2025-09-07 12:51:46.854515	\N
248	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	103	22	\N		2	56.00	2025-09-07 12:51:46.856429	2025-09-07 12:51:46.856272	\N
249	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	103	25	\N		3	174.00	2025-09-07 12:51:46.857482	2025-09-07 12:51:46.8578	\N
250	麻婆豆腐	/images/dishes/mapo_doufu.jpg	103	23	\N		3	54.00	2025-09-07 12:51:46.859816	2025-09-07 12:51:46.860082	\N
251	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	104	25	\N		1	58.00	2025-09-07 12:51:46.866877	2025-09-07 12:51:46.866656	\N
252	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	104	22	\N		3	84.00	2025-09-07 12:51:46.868714	2025-09-07 12:51:46.868755	\N
253	白切鸡	/images/dishes/baiqie_ji.jpg	104	24	\N		2	76.00	2025-09-07 12:51:46.870332	2025-09-07 12:51:46.870676	\N
254	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	104	25	\N		1	58.00	2025-09-07 12:51:46.873929	2025-09-07 12:51:46.87373	\N
255	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	105	22	\N		2	56.00	2025-09-07 12:51:46.87984	2025-09-07 12:51:46.879788	\N
256	麻婆豆腐	/images/dishes/mapo_doufu.jpg	105	23	\N		3	54.00	2025-09-07 12:51:46.881856	2025-09-07 12:51:46.881718	\N
257	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	105	25	\N		3	174.00	2025-09-07 12:51:46.883858	2025-09-07 12:51:46.883866	\N
258	麻婆豆腐	/images/dishes/mapo_doufu.jpg	106	23	\N		3	54.00	2025-09-07 12:51:46.888768	2025-09-07 12:51:46.88866	\N
259	白切鸡	/images/dishes/baiqie_ji.jpg	106	24	\N		3	114.00	2025-09-07 12:51:46.890066	2025-09-07 12:51:46.889914	\N
260	麻婆豆腐	/images/dishes/mapo_doufu.jpg	106	23	\N		1	18.00	2025-09-07 12:51:46.891128	2025-09-07 12:51:46.891158	\N
261	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	107	22	\N		2	56.00	2025-09-07 12:51:46.896921	2025-09-07 12:51:46.896927	\N
262	麻婆豆腐	/images/dishes/mapo_doufu.jpg	108	23	\N		3	54.00	2025-09-07 12:51:46.902081	2025-09-07 12:51:46.9021	\N
263	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	108	22	\N		1	28.00	2025-09-07 12:51:46.904632	2025-09-07 12:51:46.904459	\N
264	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	108	25	\N		2	116.00	2025-09-07 12:51:46.906823	2025-09-07 12:51:46.906675	\N
265	麻婆豆腐	/images/dishes/mapo_doufu.jpg	109	23	\N		1	18.00	2025-09-07 12:51:46.911802	2025-09-07 12:51:46.91206	\N
266	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	109	25	\N		2	116.00	2025-09-07 12:51:46.913893	2025-09-07 12:51:46.913924	\N
267	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	109	22	\N		1	28.00	2025-09-07 12:51:46.915683	2025-09-07 12:51:46.915685	\N
268	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	109	22	\N		3	84.00	2025-09-07 12:51:46.917172	2025-09-07 12:51:46.917601	\N
269	麻婆豆腐	/images/dishes/mapo_doufu.jpg	110	23	\N		1	18.00	2025-09-07 12:51:46.921433	2025-09-07 12:51:46.921879	\N
270	白切鸡	/images/dishes/baiqie_ji.jpg	110	24	\N		1	38.00	2025-09-07 12:51:46.923264	2025-09-07 12:51:46.923312	\N
271	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	111	22	\N		3	84.00	2025-09-07 12:51:46.928604	2025-09-07 12:51:46.928963	\N
272	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	111	25	\N		2	116.00	2025-09-07 12:51:46.929768	2025-09-07 12:51:46.93011	\N
273	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	111	25	\N		1	58.00	2025-09-07 12:51:46.932056	2025-09-07 12:51:46.931828	\N
274	白切鸡	/images/dishes/baiqie_ji.jpg	112	24	\N		2	76.00	2025-09-07 12:51:46.937741	2025-09-07 12:51:46.937578	\N
275	糖醋里脊	/images/dishes/tangcu_liji.jpg	113	26	\N		1	35.00	2025-09-07 12:51:46.942444	2025-09-07 12:51:46.942767	\N
276	白切鸡	/images/dishes/baiqie_ji.jpg	113	24	\N		2	76.00	2025-09-07 12:51:46.944583	2025-09-07 12:51:46.944474	\N
277	麻婆豆腐	/images/dishes/mapo_doufu.jpg	113	23	\N		1	18.00	2025-09-07 12:51:46.94568	2025-09-07 12:51:46.945995	\N
278	白切鸡	/images/dishes/baiqie_ji.jpg	113	24	\N		2	76.00	2025-09-07 12:51:46.947291	2025-09-07 12:51:46.947488	\N
279	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	114	22	\N		1	28.00	2025-09-07 12:51:46.952499	2025-09-07 12:51:46.952811	\N
280	白切鸡	/images/dishes/baiqie_ji.jpg	114	24	\N		3	114.00	2025-09-07 12:51:46.955049	2025-09-07 12:51:46.954969	\N
281	白切鸡	/images/dishes/baiqie_ji.jpg	114	24	\N		1	38.00	2025-09-07 12:51:46.956937	2025-09-07 12:51:46.95678	\N
282	糖醋里脊	/images/dishes/tangcu_liji.jpg	115	26	\N		1	35.00	2025-09-07 12:51:46.962215	2025-09-07 12:51:46.96214	\N
283	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	116	25	\N		1	58.00	2025-09-07 12:51:46.967951	2025-09-07 12:51:46.96785	\N
284	麻婆豆腐	/images/dishes/mapo_doufu.jpg	116	23	\N		3	54.00	2025-09-07 12:51:46.969526	2025-09-07 12:51:46.969548	\N
285	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	117	22	\N		2	56.00	2025-09-07 12:51:46.975551	2025-09-07 12:51:46.975407	\N
286	麻婆豆腐	/images/dishes/mapo_doufu.jpg	118	23	\N		3	54.00	2025-09-07 12:51:46.980784	2025-09-07 12:51:46.980666	\N
287	糖醋里脊	/images/dishes/tangcu_liji.jpg	119	26	\N		1	35.00	2025-09-07 12:51:46.987033	2025-09-07 12:51:46.987066	\N
288	白切鸡	/images/dishes/baiqie_ji.jpg	119	24	\N		2	76.00	2025-09-07 12:51:46.988823	2025-09-07 12:51:46.988811	\N
289	白切鸡	/images/dishes/baiqie_ji.jpg	119	24	\N		2	76.00	2025-09-07 12:51:46.990688	2025-09-07 12:51:46.990546	\N
290	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	119	22	\N		2	56.00	2025-09-07 12:51:46.993281	2025-09-07 12:51:46.993283	\N
291	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	120	22	\N		2	56.00	2025-09-07 12:51:46.999534	2025-09-07 12:51:46.99974	\N
292	麻婆豆腐	/images/dishes/mapo_doufu.jpg	120	23	\N		1	18.00	2025-09-07 12:51:47.002115	2025-09-07 12:51:47.001939	\N
293	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	121	22	\N		2	56.00	2025-09-07 12:51:47.008393	2025-09-07 12:51:47.008308	\N
294	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	122	22	\N		3	84.00	2025-09-07 12:51:47.015603	2025-09-07 12:51:47.015365	\N
295	白切鸡	/images/dishes/baiqie_ji.jpg	122	24	\N		3	114.00	2025-09-07 12:51:47.017429	2025-09-07 12:51:47.017657	\N
296	白切鸡	/images/dishes/baiqie_ji.jpg	123	24	\N		1	38.00	2025-09-07 12:51:47.024643	2025-09-07 12:51:47.024783	\N
297	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	123	22	\N		2	56.00	2025-09-07 12:51:47.026908	2025-09-07 12:51:47.02709	\N
298	麻婆豆腐	/images/dishes/mapo_doufu.jpg	123	23	\N		1	18.00	2025-09-07 12:51:47.028567	2025-09-07 12:51:47.028788	\N
299	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	123	25	\N		2	116.00	2025-09-07 12:51:47.030301	2025-09-07 12:51:47.03065	\N
300	麻婆豆腐	/images/dishes/mapo_doufu.jpg	124	23	\N		2	36.00	2025-09-07 12:51:47.035918	2025-09-07 12:51:47.036195	\N
301	糖醋里脊	/images/dishes/tangcu_liji.jpg	124	26	\N		3	105.00	2025-09-07 12:51:47.037816	2025-09-07 12:51:47.037675	\N
302	白切鸡	/images/dishes/baiqie_ji.jpg	124	24	\N		3	114.00	2025-09-07 12:51:47.039153	2025-09-07 12:51:47.039024	\N
303	糖醋里脊	/images/dishes/tangcu_liji.jpg	125	26	\N		1	35.00	2025-09-07 12:51:47.044002	2025-09-07 12:51:47.043829	\N
304	麻婆豆腐	/images/dishes/mapo_doufu.jpg	125	23	\N		2	36.00	2025-09-07 12:51:47.046367	2025-09-07 12:51:47.046302	\N
305	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	125	22	\N		3	84.00	2025-09-07 12:51:47.04886	2025-09-07 12:51:47.048687	\N
306	白切鸡	/images/dishes/baiqie_ji.jpg	126	24	\N		1	38.00	2025-09-07 12:51:47.054809	2025-09-07 12:51:47.054747	\N
307	麻婆豆腐	/images/dishes/mapo_doufu.jpg	126	23	\N		3	54.00	2025-09-07 12:51:47.05659	2025-09-07 12:51:47.05659	\N
308	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	126	25	\N		1	58.00	2025-09-07 12:51:47.05876	2025-09-07 12:51:47.058629	\N
309	白切鸡	/images/dishes/baiqie_ji.jpg	126	24	\N		2	76.00	2025-09-07 12:51:47.060793	2025-09-07 12:51:47.061063	\N
310	白切鸡	/images/dishes/baiqie_ji.jpg	127	24	\N		1	38.00	2025-09-07 12:51:47.067538	2025-09-07 12:51:47.067408	\N
311	白切鸡	/images/dishes/baiqie_ji.jpg	127	24	\N		3	114.00	2025-09-07 12:51:47.069314	2025-09-07 12:51:47.069326	\N
312	白切鸡	/images/dishes/baiqie_ji.jpg	127	24	\N		1	38.00	2025-09-07 12:51:47.071016	2025-09-07 12:51:47.071159	\N
313	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	127	22	\N		2	56.00	2025-09-07 12:51:47.073284	2025-09-07 12:51:47.073191	\N
314	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	128	25	\N		2	116.00	2025-09-07 12:51:47.080605	2025-09-07 12:51:47.080753	\N
315	白切鸡	/images/dishes/baiqie_ji.jpg	128	24	\N		1	38.00	2025-09-07 12:51:47.083585	2025-09-07 12:51:47.083108	\N
316	麻婆豆腐	/images/dishes/mapo_doufu.jpg	129	23	\N		3	54.00	2025-09-07 12:51:47.091675	2025-09-07 12:51:47.09148	\N
317	糖醋里脊	/images/dishes/tangcu_liji.jpg	129	26	\N		1	35.00	2025-09-07 12:51:47.095208	2025-09-07 12:51:47.09498	\N
318	糖醋里脊	/images/dishes/tangcu_liji.jpg	130	26	\N		1	35.00	2025-09-07 12:51:47.108902	2025-09-07 12:51:47.107661	\N
319	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	130	25	\N		3	174.00	2025-09-07 12:51:47.110697	2025-09-07 12:51:47.110988	\N
320	白切鸡	/images/dishes/baiqie_ji.jpg	130	24	\N		3	114.00	2025-09-07 12:51:47.11425	2025-09-07 12:51:47.113786	\N
321	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	130	25	\N		2	116.00	2025-09-07 12:51:47.116472	2025-09-07 12:51:47.116517	\N
322	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	131	25	\N		3	174.00	2025-09-07 12:51:47.12324	2025-09-07 12:51:47.123106	\N
323	白切鸡	/images/dishes/baiqie_ji.jpg	131	24	\N		3	114.00	2025-09-07 12:51:47.125287	2025-09-07 12:51:47.125104	\N
324	白切鸡	/images/dishes/baiqie_ji.jpg	132	24	\N		2	76.00	2025-09-07 12:51:47.130759	2025-09-07 12:51:47.130642	\N
325	白切鸡	/images/dishes/baiqie_ji.jpg	133	24	\N		1	38.00	2025-09-07 12:51:47.13745	2025-09-07 12:51:47.137437	\N
326	麻婆豆腐	/images/dishes/mapo_doufu.jpg	133	23	\N		2	36.00	2025-09-07 12:51:47.139518	2025-09-07 12:51:47.13936	\N
327	白切鸡	/images/dishes/baiqie_ji.jpg	134	24	\N		3	114.00	2025-09-07 12:51:47.14582	2025-09-07 12:51:47.145651	\N
328	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	134	25	\N		3	174.00	2025-09-07 12:51:47.147475	2025-09-07 12:51:47.147295	\N
329	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	135	22	\N		1	28.00	2025-09-07 12:51:47.15476	2025-09-07 12:51:47.154485	\N
330	麻婆豆腐	/images/dishes/mapo_doufu.jpg	136	23	\N		3	54.00	2025-09-07 12:51:47.160956	2025-09-07 12:51:47.160733	\N
331	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	136	22	\N		1	28.00	2025-09-07 12:51:47.162735	2025-09-07 12:51:47.162716	\N
332	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	136	25	\N		1	58.00	2025-09-07 12:51:47.165574	2025-09-07 12:51:47.165507	\N
333	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	136	25	\N		3	174.00	2025-09-07 12:51:47.167713	2025-09-07 12:51:47.167752	\N
334	白切鸡	/images/dishes/baiqie_ji.jpg	137	24	\N		3	114.00	2025-09-07 12:51:47.173554	2025-09-07 12:51:47.173666	\N
335	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	137	22	\N		3	84.00	2025-09-07 12:51:47.176025	2025-09-07 12:51:47.175972	\N
336	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	137	25	\N		3	174.00	2025-09-07 12:51:47.177668	2025-09-07 12:51:47.177928	\N
337	糖醋里脊	/images/dishes/tangcu_liji.jpg	137	26	\N		1	35.00	2025-09-07 12:51:47.179846	2025-09-07 12:51:47.179881	\N
338	糖醋里脊	/images/dishes/tangcu_liji.jpg	138	26	\N		1	35.00	2025-09-07 12:51:47.18738	2025-09-07 12:51:47.187328	\N
339	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	138	25	\N		1	58.00	2025-09-07 12:51:47.189543	2025-09-07 12:51:47.189383	\N
340	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	138	25	\N		3	174.00	2025-09-07 12:51:47.19128	2025-09-07 12:51:47.191225	\N
341	白切鸡	/images/dishes/baiqie_ji.jpg	139	24	\N		1	38.00	2025-09-07 12:51:47.198208	2025-09-07 12:51:47.197657	\N
342	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	139	25	\N		3	174.00	2025-09-07 12:51:47.200718	2025-09-07 12:51:47.200561	\N
343	糖醋里脊	/images/dishes/tangcu_liji.jpg	139	26	\N		3	105.00	2025-09-07 12:51:47.203134	2025-09-07 12:51:47.203181	\N
344	白切鸡	/images/dishes/baiqie_ji.jpg	140	24	\N		1	38.00	2025-09-07 12:51:47.211189	2025-09-07 12:51:47.211099	\N
345	白切鸡	/images/dishes/baiqie_ji.jpg	141	24	\N		3	114.00	2025-09-07 12:51:47.219065	2025-09-07 12:51:47.218855	\N
346	糖醋里脊	/images/dishes/tangcu_liji.jpg	141	26	\N		3	105.00	2025-09-07 12:51:47.220715	2025-09-07 12:51:47.220639	\N
347	麻婆豆腐	/images/dishes/mapo_doufu.jpg	141	23	\N		2	36.00	2025-09-07 12:51:47.222382	2025-09-07 12:51:47.222117	\N
348	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	141	22	\N		3	84.00	2025-09-07 12:51:47.224379	2025-09-07 12:51:47.224421	\N
349	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	142	25	\N		1	58.00	2025-09-07 12:51:47.233145	2025-09-07 12:51:47.233649	\N
350	麻婆豆腐	/images/dishes/mapo_doufu.jpg	142	23	\N		2	36.00	2025-09-07 12:51:47.236848	2025-09-07 12:51:47.236845	\N
351	麻婆豆腐	/images/dishes/mapo_doufu.jpg	142	23	\N		2	36.00	2025-09-07 12:51:47.238457	2025-09-07 12:51:47.238342	\N
352	白切鸡	/images/dishes/baiqie_ji.jpg	143	24	\N		2	76.00	2025-09-07 12:51:47.245232	2025-09-07 12:51:47.245445	\N
353	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	143	25	\N		3	174.00	2025-09-07 12:51:47.247253	2025-09-07 12:51:47.247158	\N
354	麻婆豆腐	/images/dishes/mapo_doufu.jpg	144	23	\N		3	54.00	2025-09-07 12:51:47.251628	2025-09-07 12:51:47.251743	\N
355	糖醋里脊	/images/dishes/tangcu_liji.jpg	144	26	\N		2	70.00	2025-09-07 12:51:47.252732	2025-09-07 12:51:47.25333	\N
356	白切鸡	/images/dishes/baiqie_ji.jpg	145	24	\N		1	38.00	2025-09-07 12:51:47.258763	2025-09-07 12:51:47.258644	\N
357	麻婆豆腐	/images/dishes/mapo_doufu.jpg	145	23	\N		2	36.00	2025-09-07 12:51:47.260772	2025-09-07 12:51:47.260745	\N
358	糖醋里脊	/images/dishes/tangcu_liji.jpg	145	26	\N		3	105.00	2025-09-07 12:51:47.262714	2025-09-07 12:51:47.262544	\N
359	糖醋里脊	/images/dishes/tangcu_liji.jpg	146	26	\N		2	70.00	2025-09-07 12:51:47.267903	2025-09-07 12:51:47.26778	\N
360	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	146	25	\N		2	116.00	2025-09-07 12:51:47.269581	2025-09-07 12:51:47.269637	\N
361	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	147	25	\N		3	174.00	2025-09-07 12:51:47.276323	2025-09-07 12:51:47.276186	\N
362	麻婆豆腐	/images/dishes/mapo_doufu.jpg	148	23	\N		2	36.00	2025-09-07 12:51:47.281005	2025-09-07 12:51:47.281085	\N
363	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	148	22	\N		1	28.00	2025-09-07 12:51:47.282173	2025-09-07 12:51:47.282492	\N
364	糖醋里脊	/images/dishes/tangcu_liji.jpg	148	26	\N		1	35.00	2025-09-07 12:51:47.284705	2025-09-07 12:51:47.284582	\N
365	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	149	25	\N		3	174.00	2025-09-07 12:51:47.289495	2025-09-07 12:51:47.289375	\N
366	糖醋里脊	/images/dishes/tangcu_liji.jpg	149	26	\N		3	105.00	2025-09-07 12:51:47.291627	2025-09-07 12:51:47.291448	\N
367	麻婆豆腐	/images/dishes/mapo_doufu.jpg	149	23	\N		2	36.00	2025-09-07 12:51:47.29353	2025-09-07 12:51:47.293256	\N
368	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	150	25	\N		3	174.00	2025-09-07 12:51:47.299309	2025-09-07 12:51:47.299177	\N
369	麻婆豆腐	/images/dishes/mapo_doufu.jpg	150	23	\N		2	36.00	2025-09-07 12:51:47.300393	2025-09-07 12:51:47.300695	\N
370	糖醋里脊	/images/dishes/tangcu_liji.jpg	151	26	\N		3	105.00	2025-09-07 12:51:47.305594	2025-09-07 12:51:47.305666	\N
371	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	151	25	\N		2	116.00	2025-09-07 12:51:47.307167	2025-09-07 12:51:47.307396	\N
372	麻婆豆腐	/images/dishes/mapo_doufu.jpg	152	23	\N		3	54.00	2025-09-07 12:51:47.311997	2025-09-07 12:51:47.311841	\N
373	麻婆豆腐	/images/dishes/mapo_doufu.jpg	152	23	\N		2	36.00	2025-09-07 12:51:47.313698	2025-09-07 12:51:47.313581	\N
374	糖醋里脊	/images/dishes/tangcu_liji.jpg	152	26	\N		1	35.00	2025-09-07 12:51:47.314756	2025-09-07 12:51:47.315072	\N
375	麻婆豆腐	/images/dishes/mapo_doufu.jpg	153	23	\N		3	54.00	2025-09-07 12:51:47.319982	2025-09-07 12:51:47.320389	\N
376	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	153	25	\N		1	58.00	2025-09-07 12:51:47.322551	2025-09-07 12:51:47.322264	\N
377	麻婆豆腐	/images/dishes/mapo_doufu.jpg	154	23	\N		1	18.00	2025-09-07 12:51:47.328364	2025-09-07 12:51:47.328604	\N
378	麻婆豆腐	/images/dishes/mapo_doufu.jpg	155	23	\N		2	36.00	2025-09-07 12:51:47.33502	2025-09-07 12:51:47.334917	\N
379	糖醋里脊	/images/dishes/tangcu_liji.jpg	155	26	\N		3	105.00	2025-09-07 12:51:47.337501	2025-09-07 12:51:47.33738	\N
380	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	155	22	\N		2	56.00	2025-09-07 12:51:47.338599	2025-09-07 12:51:47.338802	\N
381	白切鸡	/images/dishes/baiqie_ji.jpg	156	24	\N		1	38.00	2025-09-07 12:51:47.344917	2025-09-07 12:51:47.3448	\N
382	白切鸡	/images/dishes/baiqie_ji.jpg	157	24	\N		3	114.00	2025-09-07 12:51:47.350323	2025-09-07 12:51:47.350108	\N
383	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	157	25	\N		3	174.00	2025-09-07 12:51:47.352645	2025-09-07 12:51:47.352714	\N
384	糖醋里脊	/images/dishes/tangcu_liji.jpg	158	26	\N		3	105.00	2025-09-07 12:51:47.359073	2025-09-07 12:51:47.359155	\N
385	糖醋里脊	/images/dishes/tangcu_liji.jpg	159	26	\N		1	35.00	2025-09-07 12:51:47.366277	2025-09-07 12:51:47.36646	\N
386	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	159	25	\N		1	58.00	2025-09-07 12:51:47.368197	2025-09-07 12:51:47.368107	\N
387	糖醋里脊	/images/dishes/tangcu_liji.jpg	159	26	\N		2	70.00	2025-09-07 12:51:47.370279	2025-09-07 12:51:47.370256	\N
388	麻婆豆腐	/images/dishes/mapo_doufu.jpg	159	23	\N		2	36.00	2025-09-07 12:51:47.372584	2025-09-07 12:51:47.372795	\N
389	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	160	25	\N		1	58.00	2025-09-07 12:51:47.37747	2025-09-07 12:51:47.377867	\N
390	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	160	22	\N		2	56.00	2025-09-07 12:51:47.379083	2025-09-07 12:51:47.378998	\N
391	麻婆豆腐	/images/dishes/mapo_doufu.jpg	160	23	\N		3	54.00	2025-09-07 12:51:47.380388	2025-09-07 12:51:47.380298	\N
392	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	161	25	\N		1	58.00	2025-09-07 12:51:47.387669	2025-09-07 12:51:47.38756	\N
393	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	161	22	\N		2	56.00	2025-09-07 12:51:47.389075	2025-09-07 12:51:47.388994	\N
394	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	162	25	\N		1	58.00	2025-09-07 12:51:47.393838	2025-09-07 12:51:47.393697	\N
395	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	162	22	\N		1	28.00	2025-09-07 12:51:47.395839	2025-09-07 12:51:47.395786	\N
396	麻婆豆腐	/images/dishes/mapo_doufu.jpg	162	23	\N		3	54.00	2025-09-07 12:51:47.398189	2025-09-07 12:51:47.398121	\N
397	麻婆豆腐	/images/dishes/mapo_doufu.jpg	163	23	\N		1	18.00	2025-09-07 12:51:47.403235	2025-09-07 12:51:47.40344	\N
398	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	163	25	\N		1	58.00	2025-09-07 12:51:47.405616	2025-09-07 12:51:47.405506	\N
399	麻婆豆腐	/images/dishes/mapo_doufu.jpg	163	23	\N		1	18.00	2025-09-07 12:51:47.406699	2025-09-07 12:51:47.406922	\N
400	糖醋里脊	/images/dishes/tangcu_liji.jpg	164	26	\N		3	105.00	2025-09-07 12:51:47.413291	2025-09-07 12:51:47.413037	\N
401	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	164	22	\N		1	28.00	2025-09-07 12:51:47.415252	2025-09-07 12:51:47.415366	\N
402	白切鸡	/images/dishes/baiqie_ji.jpg	164	24	\N		2	76.00	2025-09-07 12:51:47.416451	2025-09-07 12:51:47.416676	\N
403	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	165	22	\N		1	28.00	2025-09-07 12:51:47.420658	2025-09-07 12:51:47.420539	\N
404	麻婆豆腐	/images/dishes/mapo_doufu.jpg	165	23	\N		3	54.00	2025-09-07 12:51:47.422356	2025-09-07 12:51:47.422207	\N
405	糖醋里脊	/images/dishes/tangcu_liji.jpg	165	26	\N		2	70.00	2025-09-07 12:51:47.424769	2025-09-07 12:51:47.424766	\N
406	糖醋里脊	/images/dishes/tangcu_liji.jpg	166	26	\N		3	105.00	2025-09-07 12:51:47.430878	2025-09-07 12:51:47.430925	\N
407	白切鸡	/images/dishes/baiqie_ji.jpg	166	24	\N		3	114.00	2025-09-07 12:51:47.433306	2025-09-07 12:51:47.433138	\N
408	白切鸡	/images/dishes/baiqie_ji.jpg	167	24	\N		2	76.00	2025-09-07 12:51:47.438343	2025-09-07 12:51:47.438277	\N
409	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	167	22	\N		1	28.00	2025-09-07 12:51:47.440881	2025-09-07 12:51:47.440994	\N
410	糖醋里脊	/images/dishes/tangcu_liji.jpg	168	26	\N		1	35.00	2025-09-07 12:51:47.448096	2025-09-07 12:51:47.448176	\N
411	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	168	22	\N		2	56.00	2025-09-07 12:51:47.449179	2025-09-07 12:51:47.449483	\N
412	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	168	22	\N		3	84.00	2025-09-07 12:51:47.45026	2025-09-07 12:51:47.450584	\N
413	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	168	25	\N		3	174.00	2025-09-07 12:51:47.451889	2025-09-07 12:51:47.452086	\N
414	麻婆豆腐	/images/dishes/mapo_doufu.jpg	169	23	\N		3	54.00	2025-09-07 12:51:47.458073	2025-09-07 12:51:47.457974	\N
415	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	170	25	\N		3	174.00	2025-09-07 12:51:47.461911	2025-09-07 12:51:47.461938	\N
416	麻婆豆腐	/images/dishes/mapo_doufu.jpg	171	23	\N		3	54.00	2025-09-07 12:51:47.467047	2025-09-07 12:51:47.467227	\N
417	糖醋里脊	/images/dishes/tangcu_liji.jpg	171	26	\N		2	70.00	2025-09-07 12:51:47.468944	2025-09-07 12:51:47.468893	\N
418	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	171	25	\N		2	116.00	2025-09-07 12:51:47.470023	2025-09-07 12:51:47.470425	\N
419	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	171	25	\N		3	174.00	2025-09-07 12:51:47.471299	2025-09-07 12:51:47.471629	\N
420	麻婆豆腐	/images/dishes/mapo_doufu.jpg	172	23	\N		1	18.00	2025-09-07 12:51:47.478528	2025-09-07 12:51:47.478349	\N
421	白切鸡	/images/dishes/baiqie_ji.jpg	172	24	\N		2	76.00	2025-09-07 12:51:47.48014	2025-09-07 12:51:47.479981	\N
422	糖醋里脊	/images/dishes/tangcu_liji.jpg	172	26	\N		2	70.00	2025-09-07 12:51:47.481021	2025-09-07 12:51:47.481414	\N
423	白切鸡	/images/dishes/baiqie_ji.jpg	173	24	\N		3	114.00	2025-09-07 12:51:47.486628	2025-09-07 12:51:47.486512	\N
424	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	173	22	\N		3	84.00	2025-09-07 12:51:47.488076	2025-09-07 12:51:47.488256	\N
425	白切鸡	/images/dishes/baiqie_ji.jpg	173	24	\N		1	38.00	2025-09-07 12:51:47.489275	2025-09-07 12:51:47.489619	\N
426	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	174	22	\N		1	28.00	2025-09-07 12:51:47.495199	2025-09-07 12:51:47.495257	\N
427	糖醋里脊	/images/dishes/tangcu_liji.jpg	174	26	\N		2	70.00	2025-09-07 12:51:47.497044	2025-09-07 12:51:47.496925	\N
428	麻婆豆腐	/images/dishes/mapo_doufu.jpg	175	23	\N		3	54.00	2025-09-07 12:51:47.501643	2025-09-07 12:51:47.50153	\N
429	糖醋里脊	/images/dishes/tangcu_liji.jpg	176	26	\N		2	70.00	2025-09-07 12:51:47.508243	2025-09-07 12:51:47.50825	\N
430	白切鸡	/images/dishes/baiqie_ji.jpg	176	24	\N		1	38.00	2025-09-07 12:51:47.509473	2025-09-07 12:51:47.509883	\N
431	糖醋里脊	/images/dishes/tangcu_liji.jpg	176	26	\N		1	35.00	2025-09-07 12:51:47.511156	2025-09-07 12:51:47.511518	\N
432	麻婆豆腐	/images/dishes/mapo_doufu.jpg	176	23	\N		3	54.00	2025-09-07 12:51:47.513806	2025-09-07 12:51:47.513777	\N
433	麻婆豆腐	/images/dishes/mapo_doufu.jpg	177	23	\N		2	36.00	2025-09-07 12:51:47.520872	2025-09-07 12:51:47.52066	\N
434	白切鸡	/images/dishes/baiqie_ji.jpg	177	24	\N		2	76.00	2025-09-07 12:51:47.523712	2025-09-07 12:51:47.523964	\N
435	糖醋里脊	/images/dishes/tangcu_liji.jpg	177	26	\N		2	70.00	2025-09-07 12:51:47.52538	2025-09-07 12:51:47.525529	\N
436	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	178	25	\N		3	174.00	2025-09-07 12:51:47.530981	2025-09-07 12:51:47.531179	\N
437	糖醋里脊	/images/dishes/tangcu_liji.jpg	178	26	\N		3	105.00	2025-09-07 12:51:47.534988	2025-09-07 12:51:47.534579	\N
438	麻婆豆腐	/images/dishes/mapo_doufu.jpg	178	23	\N		1	18.00	2025-09-07 12:51:47.536603	2025-09-07 12:51:47.536714	\N
439	白切鸡	/images/dishes/baiqie_ji.jpg	178	24	\N		2	76.00	2025-09-07 12:51:47.538233	2025-09-07 12:51:47.538492	\N
440	糖醋里脊	/images/dishes/tangcu_liji.jpg	179	26	\N		2	70.00	2025-09-07 12:51:47.54557	2025-09-07 12:51:47.545841	\N
441	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	180	22	\N		2	56.00	2025-09-07 12:51:47.551226	2025-09-07 12:51:47.551064	\N
442	麻婆豆腐	/images/dishes/mapo_doufu.jpg	181	23	\N		2	36.00	2025-09-07 12:51:47.558358	2025-09-07 12:51:47.558558	\N
443	白切鸡	/images/dishes/baiqie_ji.jpg	181	24	\N		2	76.00	2025-09-07 12:51:47.560465	2025-09-07 12:51:47.560399	\N
444	白切鸡	/images/dishes/baiqie_ji.jpg	182	24	\N		3	114.00	2025-09-07 12:51:47.566892	2025-09-07 12:51:47.566943	\N
445	糖醋里脊	/images/dishes/tangcu_liji.jpg	182	26	\N		3	105.00	2025-09-07 12:51:47.568315	2025-09-07 12:51:47.568662	\N
446	白切鸡	/images/dishes/baiqie_ji.jpg	182	24	\N		1	38.00	2025-09-07 12:51:47.57	2025-09-07 12:51:47.570317	\N
447	白切鸡	/images/dishes/baiqie_ji.jpg	183	24	\N		2	76.00	2025-09-07 12:51:47.576983	2025-09-07 12:51:47.576799	\N
448	麻婆豆腐	/images/dishes/mapo_doufu.jpg	183	23	\N		3	54.00	2025-09-07 12:51:47.578663	2025-09-07 12:51:47.578495	\N
449	白切鸡	/images/dishes/baiqie_ji.jpg	184	24	\N		2	76.00	2025-09-07 12:51:47.585359	2025-09-07 12:51:47.58535	\N
450	白切鸡	/images/dishes/baiqie_ji.jpg	184	24	\N		3	114.00	2025-09-07 12:51:47.586722	2025-09-07 12:51:47.58704	\N
451	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	184	25	\N		2	116.00	2025-09-07 12:51:47.588049	2025-09-07 12:51:47.588361	\N
452	糖醋里脊	/images/dishes/tangcu_liji.jpg	184	26	\N		3	105.00	2025-09-07 12:51:47.589359	2025-09-07 12:51:47.589714	\N
453	糖醋里脊	/images/dishes/tangcu_liji.jpg	185	26	\N		2	70.00	2025-09-07 12:51:47.597178	2025-09-07 12:51:47.597055	\N
454	白切鸡	/images/dishes/baiqie_ji.jpg	185	24	\N		1	38.00	2025-09-07 12:51:47.598757	2025-09-07 12:51:47.598654	\N
455	白切鸡	/images/dishes/baiqie_ji.jpg	185	24	\N		1	38.00	2025-09-07 12:51:47.600189	2025-09-07 12:51:47.600243	\N
456	麻婆豆腐	/images/dishes/mapo_doufu.jpg	185	23	\N		3	54.00	2025-09-07 12:51:47.601821	2025-09-07 12:51:47.601668	\N
457	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	186	22	\N		2	56.00	2025-09-07 12:51:47.606979	2025-09-07 12:51:47.606854	\N
458	麻婆豆腐	/images/dishes/mapo_doufu.jpg	187	23	\N		2	36.00	2025-09-07 12:51:47.611536	2025-09-07 12:51:47.611466	\N
459	白切鸡	/images/dishes/baiqie_ji.jpg	187	24	\N		3	114.00	2025-09-07 12:51:47.613258	2025-09-07 12:51:47.613223	\N
460	白切鸡	/images/dishes/baiqie_ji.jpg	188	24	\N		2	76.00	2025-09-07 12:51:47.619085	2025-09-07 12:51:47.618941	\N
461	糖醋里脊	/images/dishes/tangcu_liji.jpg	189	26	\N		3	105.00	2025-09-07 12:51:47.624016	2025-09-07 12:51:47.623879	\N
462	糖醋里脊	/images/dishes/tangcu_liji.jpg	189	26	\N		3	105.00	2025-09-07 12:51:47.626219	2025-09-07 12:51:47.626465	\N
463	麻婆豆腐	/images/dishes/mapo_doufu.jpg	190	23	\N		3	54.00	2025-09-07 12:51:47.632106	2025-09-07 12:51:47.631974	\N
464	白切鸡	/images/dishes/baiqie_ji.jpg	191	24	\N		3	114.00	2025-09-07 12:51:47.636941	2025-09-07 12:51:47.636905	\N
465	麻婆豆腐	/images/dishes/mapo_doufu.jpg	191	23	\N		3	54.00	2025-09-07 12:51:47.639341	2025-09-07 12:51:47.639115	\N
466	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	191	22	\N		2	56.00	2025-09-07 12:51:47.641535	2025-09-07 12:51:47.641402	\N
467	白切鸡	/images/dishes/baiqie_ji.jpg	192	24	\N		2	76.00	2025-09-07 12:51:47.646942	2025-09-07 12:51:47.646824	\N
468	白切鸡	/images/dishes/baiqie_ji.jpg	192	24	\N		3	114.00	2025-09-07 12:51:47.647617	2025-09-07 12:51:47.647917	\N
469	糖醋里脊	/images/dishes/tangcu_liji.jpg	192	26	\N		3	105.00	2025-09-07 12:51:47.648719	2025-09-07 12:51:47.64904	\N
470	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	193	25	\N		1	58.00	2025-09-07 12:51:47.65357	2025-09-07 12:51:47.653416	\N
471	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	193	25	\N		3	174.00	2025-09-07 12:51:47.655026	2025-09-07 12:51:47.654938	\N
472	白切鸡	/images/dishes/baiqie_ji.jpg	193	24	\N		2	76.00	2025-09-07 12:51:47.656516	2025-09-07 12:51:47.656511	\N
473	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	194	22	\N		2	56.00	2025-09-07 12:51:47.661874	2025-09-07 12:51:47.66177	\N
474	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	195	22	\N		3	84.00	2025-09-07 12:51:47.666986	2025-09-07 12:51:47.666858	\N
475	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	195	22	\N		1	28.00	2025-09-07 12:51:47.668104	2025-09-07 12:51:47.668299	\N
476	白切鸡	/images/dishes/baiqie_ji.jpg	196	24	\N		3	114.00	2025-09-07 12:51:47.672705	2025-09-07 12:51:47.672085	\N
477	糖醋里脊	/images/dishes/tangcu_liji.jpg	196	26	\N		3	105.00	2025-09-07 12:51:47.675133	2025-09-07 12:51:47.674953	\N
478	糖醋里脊	/images/dishes/tangcu_liji.jpg	197	26	\N		2	70.00	2025-09-07 12:51:47.679519	2025-09-07 12:51:47.679522	\N
479	白切鸡	/images/dishes/baiqie_ji.jpg	197	24	\N		3	114.00	2025-09-07 12:51:47.680562	2025-09-07 12:51:47.680931	\N
480	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	197	25	\N		1	58.00	2025-09-07 12:51:47.682428	2025-09-07 12:51:47.682409	\N
481	麻婆豆腐	/images/dishes/mapo_doufu.jpg	198	23	\N		2	36.00	2025-09-07 12:51:47.687089	2025-09-07 12:51:47.687285	\N
482	麻婆豆腐	/images/dishes/mapo_doufu.jpg	199	23	\N		2	36.00	2025-09-07 12:51:47.691545	2025-09-07 12:51:47.691744	\N
483	麻婆豆腐	/images/dishes/mapo_doufu.jpg	199	23	\N		2	36.00	2025-09-07 12:51:47.693785	2025-09-07 12:51:47.693618	\N
484	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	200	25	\N		3	174.00	2025-09-07 12:51:47.697844	2025-09-07 12:51:47.698078	\N
485	白切鸡	/images/dishes/baiqie_ji.jpg	201	24	\N		1	38.00	2025-09-07 12:51:47.702116	2025-09-07 12:51:47.70209	\N
486	麻婆豆腐	/images/dishes/mapo_doufu.jpg	201	23	\N		2	36.00	2025-09-07 12:51:47.705694	2025-09-07 12:51:47.705587	\N
487	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	201	25	\N		1	58.00	2025-09-07 12:51:47.706815	2025-09-07 12:51:47.707172	\N
488	白切鸡	/images/dishes/baiqie_ji.jpg	202	24	\N		2	76.00	2025-09-07 12:51:47.710875	2025-09-07 12:51:47.711142	\N
489	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	202	22	\N		1	28.00	2025-09-07 12:51:47.711938	2025-09-07 12:51:47.712254	\N
490	白切鸡	/images/dishes/baiqie_ji.jpg	202	24	\N		2	76.00	2025-09-07 12:51:47.714397	2025-09-07 12:51:47.71441	\N
491	糖醋里脊	/images/dishes/tangcu_liji.jpg	203	26	\N		1	35.00	2025-09-07 12:51:47.720102	2025-09-07 12:51:47.720083	\N
492	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	203	25	\N		3	174.00	2025-09-07 12:51:47.721199	2025-09-07 12:51:47.721339	\N
493	麻婆豆腐	/images/dishes/mapo_doufu.jpg	203	23	\N		3	54.00	2025-09-07 12:51:47.72287	2025-09-07 12:51:47.722905	\N
494	麻婆豆腐	/images/dishes/mapo_doufu.jpg	204	23	\N		3	54.00	2025-09-07 12:51:47.727007	2025-09-07 12:51:47.727368	\N
495	麻婆豆腐	/images/dishes/mapo_doufu.jpg	204	23	\N		1	18.00	2025-09-07 12:51:47.728218	2025-09-07 12:51:47.728584	\N
496	白切鸡	/images/dishes/baiqie_ji.jpg	204	24	\N		1	38.00	2025-09-07 12:51:47.72997	2025-09-07 12:51:47.729808	\N
497	白切鸡	/images/dishes/baiqie_ji.jpg	205	24	\N		3	114.00	2025-09-07 12:51:47.73558	2025-09-07 12:51:47.735681	\N
498	糖醋里脊	/images/dishes/tangcu_liji.jpg	205	26	\N		1	35.00	2025-09-07 12:51:47.737228	2025-09-07 12:51:47.737077	\N
499	糖醋里脊	/images/dishes/tangcu_liji.jpg	205	26	\N		2	70.00	2025-09-07 12:51:47.738783	2025-09-07 12:51:47.738612	\N
500	白切鸡	/images/dishes/baiqie_ji.jpg	205	24	\N		3	114.00	2025-09-07 12:51:47.739861	2025-09-07 12:51:47.739786	\N
501	白切鸡	/images/dishes/baiqie_ji.jpg	206	24	\N		2	76.00	2025-09-07 12:51:47.744121	2025-09-07 12:51:47.744184	\N
502	糖醋里脊	/images/dishes/tangcu_liji.jpg	206	26	\N		3	105.00	2025-09-07 12:51:47.745753	2025-09-07 12:51:47.745935	\N
503	白切鸡	/images/dishes/baiqie_ji.jpg	206	24	\N		1	38.00	2025-09-07 12:51:47.746884	2025-09-07 12:51:47.747109	\N
504	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	207	22	\N		3	84.00	2025-09-07 12:51:47.750444	2025-09-07 12:51:47.750794	\N
505	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	207	25	\N		3	174.00	2025-09-07 12:51:47.751508	2025-09-07 12:51:47.751733	\N
506	白切鸡	/images/dishes/baiqie_ji.jpg	208	24	\N		3	114.00	2025-09-07 12:51:47.756389	2025-09-07 12:51:47.756415	\N
507	麻婆豆腐	/images/dishes/mapo_doufu.jpg	208	23	\N		3	54.00	2025-09-07 12:51:47.75771	2025-09-07 12:51:47.757752	\N
508	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	208	25	\N		3	174.00	2025-09-07 12:51:47.758711	2025-09-07 12:51:47.759011	\N
509	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	208	22	\N		1	28.00	2025-09-07 12:51:47.759778	2025-09-07 12:51:47.760058	\N
510	糖醋里脊	/images/dishes/tangcu_liji.jpg	209	26	\N		2	70.00	2025-09-07 12:51:47.763949	2025-09-07 12:51:47.764038	\N
511	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	209	22	\N		3	84.00	2025-09-07 12:51:47.765875	2025-09-07 12:51:47.765842	\N
512	麻婆豆腐	/images/dishes/mapo_doufu.jpg	209	23	\N		2	36.00	2025-09-07 12:51:47.767585	2025-09-07 12:51:47.767597	\N
513	白切鸡	/images/dishes/baiqie_ji.jpg	209	24	\N		3	114.00	2025-09-07 12:51:47.76867	2025-09-07 12:51:47.768828	\N
514	糖醋里脊	/images/dishes/tangcu_liji.jpg	210	26	\N		3	105.00	2025-09-07 12:51:47.772404	2025-09-07 12:51:47.772242	\N
515	糖醋里脊	/images/dishes/tangcu_liji.jpg	210	26	\N		2	70.00	2025-09-07 12:51:47.77478	2025-09-07 12:51:47.775159	\N
516	白切鸡	/images/dishes/baiqie_ji.jpg	210	24	\N		1	38.00	2025-09-07 12:51:47.776509	2025-09-07 12:51:47.776759	\N
517	糖醋里脊	/images/dishes/tangcu_liji.jpg	211	26	\N		2	70.00	2025-09-07 12:51:47.781438	2025-09-07 12:51:47.781552	\N
518	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	211	25	\N		1	58.00	2025-09-07 12:51:47.78374	2025-09-07 12:51:47.783759	\N
519	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	211	22	\N		2	56.00	2025-09-07 12:51:47.78549	2025-09-07 12:51:47.78559	\N
520	麻婆豆腐	/images/dishes/mapo_doufu.jpg	212	23	\N		3	54.00	2025-09-07 12:51:47.790141	2025-09-07 12:51:47.790028	\N
521	麻婆豆腐	/images/dishes/mapo_doufu.jpg	212	23	\N		1	18.00	2025-09-07 12:51:47.791242	2025-09-07 12:51:47.79136	\N
522	糖醋里脊	/images/dishes/tangcu_liji.jpg	212	26	\N		2	70.00	2025-09-07 12:51:47.792365	2025-09-07 12:51:47.792435	\N
523	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	213	22	\N		1	28.00	2025-09-07 12:51:47.797345	2025-09-07 12:51:47.797674	\N
524	白切鸡	/images/dishes/baiqie_ji.jpg	213	24	\N		3	114.00	2025-09-07 12:51:47.798945	2025-09-07 12:51:47.798978	\N
525	麻婆豆腐	/images/dishes/mapo_doufu.jpg	213	23	\N		1	18.00	2025-09-07 12:51:47.80002	2025-09-07 12:51:47.800263	\N
526	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	213	25	\N		3	174.00	2025-09-07 12:51:47.801102	2025-09-07 12:51:47.801485	\N
527	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	214	25	\N		1	58.00	2025-09-07 12:51:47.806382	2025-09-07 12:51:47.806427	\N
528	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	214	25	\N		1	58.00	2025-09-07 12:51:47.808037	2025-09-07 12:51:47.807932	\N
529	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	214	22	\N		2	56.00	2025-09-07 12:51:47.809394	2025-09-07 12:51:47.809588	\N
530	麻婆豆腐	/images/dishes/mapo_doufu.jpg	215	23	\N		1	18.00	2025-09-07 12:51:47.81537	2025-09-07 12:51:47.815633	\N
531	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	215	22	\N		1	28.00	2025-09-07 12:51:47.817038	2025-09-07 12:51:47.81725	\N
532	麻婆豆腐	/images/dishes/mapo_doufu.jpg	216	23	\N		3	54.00	2025-09-07 12:51:47.821526	2025-09-07 12:51:47.821873	\N
533	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	216	22	\N		2	56.00	2025-09-07 12:51:47.823757	2025-09-07 12:51:47.82365	\N
534	白切鸡	/images/dishes/baiqie_ji.jpg	216	24	\N		3	114.00	2025-09-07 12:51:47.825887	2025-09-07 12:51:47.826136	\N
535	糖醋里脊	/images/dishes/tangcu_liji.jpg	217	26	\N		3	105.00	2025-09-07 12:51:47.830358	2025-09-07 12:51:47.830641	\N
536	糖醋里脊	/images/dishes/tangcu_liji.jpg	217	26	\N		2	70.00	2025-09-07 12:51:47.831431	2025-09-07 12:51:47.831862	\N
537	白切鸡	/images/dishes/baiqie_ji.jpg	218	24	\N		3	114.00	2025-09-07 12:51:47.836771	2025-09-07 12:51:47.837183	\N
538	糖醋里脊	/images/dishes/tangcu_liji.jpg	219	26	\N		2	70.00	2025-09-07 12:51:47.842832	2025-09-07 12:51:47.842827	\N
539	麻婆豆腐	/images/dishes/mapo_doufu.jpg	219	23	\N		2	36.00	2025-09-07 12:51:47.844351	2025-09-07 12:51:47.844617	\N
540	糖醋里脊	/images/dishes/tangcu_liji.jpg	219	26	\N		1	35.00	2025-09-07 12:51:47.845797	2025-09-07 12:51:47.846076	\N
541	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	219	22	\N		1	28.00	2025-09-07 12:51:47.847664	2025-09-07 12:51:47.84754	\N
542	糖醋里脊	/images/dishes/tangcu_liji.jpg	220	26	\N		1	35.00	2025-09-07 12:51:47.851473	2025-09-07 12:51:47.851369	\N
543	麻婆豆腐	/images/dishes/mapo_doufu.jpg	220	23	\N		3	54.00	2025-09-07 12:51:47.853532	2025-09-07 12:51:47.85338	\N
544	白切鸡	/images/dishes/baiqie_ji.jpg	220	24	\N		2	76.00	2025-09-07 12:51:47.855062	2025-09-07 12:51:47.855411	\N
545	糖醋里脊	/images/dishes/tangcu_liji.jpg	220	26	\N		2	70.00	2025-09-07 12:51:47.856362	2025-09-07 12:51:47.856581	\N
546	麻婆豆腐	/images/dishes/mapo_doufu.jpg	221	23	\N		2	36.00	2025-09-07 12:51:47.86059	2025-09-07 12:51:47.860531	\N
547	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	221	25	\N		2	116.00	2025-09-07 12:51:47.861665	2025-09-07 12:51:47.861823	\N
548	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	222	25	\N		3	174.00	2025-09-07 12:51:47.866812	2025-09-07 12:51:47.867062	\N
549	糖醋里脊	/images/dishes/tangcu_liji.jpg	222	26	\N		2	70.00	2025-09-07 12:51:47.868704	2025-09-07 12:51:47.868549	\N
550	糖醋里脊	/images/dishes/tangcu_liji.jpg	222	26	\N		2	70.00	2025-09-07 12:51:47.870258	2025-09-07 12:51:47.869954	\N
551	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	223	22	\N		2	56.00	2025-09-07 12:51:47.875546	2025-09-07 12:51:47.875687	\N
552	麻婆豆腐	/images/dishes/mapo_doufu.jpg	223	23	\N		3	54.00	2025-09-07 12:51:47.877254	2025-09-07 12:51:47.87714	\N
553	麻婆豆腐	/images/dishes/mapo_doufu.jpg	223	23	\N		3	54.00	2025-09-07 12:51:47.878958	2025-09-07 12:51:47.87882	\N
554	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	224	25	\N		2	116.00	2025-09-07 12:51:47.882802	2025-09-07 12:51:47.882692	\N
555	糖醋里脊	/images/dishes/tangcu_liji.jpg	225	26	\N		3	105.00	2025-09-07 12:51:47.888384	2025-09-07 12:51:47.888478	\N
556	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	226	25	\N		1	58.00	2025-09-07 12:51:47.893375	2025-09-07 12:51:47.893473	\N
557	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	226	25	\N		1	58.00	2025-09-07 12:51:47.895697	2025-09-07 12:51:47.89597	\N
558	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	226	25	\N		3	174.00	2025-09-07 12:51:47.89693	2025-09-07 12:51:47.897122	\N
559	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	226	25	\N		1	58.00	2025-09-07 12:51:47.89866	2025-09-07 12:51:47.898533	\N
560	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	227	22	\N		1	28.00	2025-09-07 12:51:47.904581	2025-09-07 12:51:47.904557	\N
561	糖醋里脊	/images/dishes/tangcu_liji.jpg	227	26	\N		2	70.00	2025-09-07 12:51:47.906324	2025-09-07 12:51:47.906321	\N
562	麻婆豆腐	/images/dishes/mapo_doufu.jpg	228	23	\N		3	54.00	2025-09-07 12:51:47.910629	2025-09-07 12:51:47.910885	\N
563	麻婆豆腐	/images/dishes/mapo_doufu.jpg	228	23	\N		3	54.00	2025-09-07 12:51:47.91177	2025-09-07 12:51:47.911934	\N
564	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	228	25	\N		1	58.00	2025-09-07 12:51:47.913962	2025-09-07 12:51:47.91385	\N
565	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	229	25	\N		1	58.00	2025-09-07 12:51:47.919489	2025-09-07 12:51:47.919336	\N
566	白切鸡	/images/dishes/baiqie_ji.jpg	229	24	\N		1	38.00	2025-09-07 12:51:47.920535	2025-09-07 12:51:47.920846	\N
567	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	229	22	\N		3	84.00	2025-09-07 12:51:47.922483	2025-09-07 12:51:47.922323	\N
568	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	229	25	\N		2	116.00	2025-09-07 12:51:47.924768	2025-09-07 12:51:47.924614	\N
569	糖醋里脊	/images/dishes/tangcu_liji.jpg	230	26	\N		3	105.00	2025-09-07 12:51:47.929408	2025-09-07 12:51:47.929522	\N
570	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	230	22	\N		1	28.00	2025-09-07 12:51:47.930769	2025-09-07 12:51:47.931102	\N
571	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	231	22	\N		1	28.00	2025-09-07 12:51:47.93549	2025-09-07 12:51:47.935864	\N
572	麻婆豆腐	/images/dishes/mapo_doufu.jpg	231	23	\N		1	18.00	2025-09-07 12:51:47.9375	2025-09-07 12:51:47.937358	\N
573	糖醋里脊	/images/dishes/tangcu_liji.jpg	231	26	\N		1	35.00	2025-09-07 12:51:47.939342	2025-09-07 12:51:47.939232	\N
574	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	232	22	\N		3	84.00	2025-09-07 12:51:47.942685	2025-09-07 12:51:47.942749	\N
575	白切鸡	/images/dishes/baiqie_ji.jpg	232	24	\N		2	76.00	2025-09-07 12:51:47.944214	2025-09-07 12:51:47.944566	\N
576	白切鸡	/images/dishes/baiqie_ji.jpg	232	24	\N		1	38.00	2025-09-07 12:51:47.946112	2025-09-07 12:51:47.946332	\N
577	白切鸡	/images/dishes/baiqie_ji.jpg	232	24	\N		2	76.00	2025-09-07 12:51:47.948234	2025-09-07 12:51:47.948139	\N
578	白切鸡	/images/dishes/baiqie_ji.jpg	233	24	\N		2	76.00	2025-09-07 12:51:47.951536	2025-09-07 12:51:47.951801	\N
579	白切鸡	/images/dishes/baiqie_ji.jpg	233	24	\N		3	114.00	2025-09-07 12:51:47.953935	2025-09-07 12:51:47.953927	\N
580	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	233	22	\N		3	84.00	2025-09-07 12:51:47.955975	2025-09-07 12:51:47.955867	\N
581	糖醋里脊	/images/dishes/tangcu_liji.jpg	233	26	\N		3	105.00	2025-09-07 12:51:47.957793	2025-09-07 12:51:47.957215	\N
582	白切鸡	/images/dishes/baiqie_ji.jpg	234	24	\N		3	114.00	2025-09-07 12:51:47.961502	2025-09-07 12:51:47.961813	\N
583	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	235	22	\N		1	28.00	2025-09-07 12:51:47.967397	2025-09-07 12:51:47.967447	\N
584	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	235	25	\N		2	116.00	2025-09-07 12:51:47.969067	2025-09-07 12:51:47.968973	\N
585	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	235	25	\N		3	174.00	2025-09-07 12:51:47.970001	2025-09-07 12:51:47.970322	\N
586	糖醋里脊	/images/dishes/tangcu_liji.jpg	236	26	\N		1	35.00	2025-09-07 12:51:47.975053	2025-09-07 12:51:47.97506	\N
587	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	237	25	\N		2	116.00	2025-09-07 12:51:47.980706	2025-09-07 12:51:47.980724	\N
588	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	237	25	\N		2	116.00	2025-09-07 12:51:47.981768	2025-09-07 12:51:47.982096	\N
589	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	237	22	\N		3	84.00	2025-09-07 12:51:47.983971	2025-09-07 12:51:47.983991	\N
590	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	238	22	\N		1	28.00	2025-09-07 12:51:47.988691	2025-09-07 12:51:47.988691	\N
591	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	239	22	\N		1	28.00	2025-09-07 12:51:47.993455	2025-09-07 12:51:47.993334	\N
592	白切鸡	/images/dishes/baiqie_ji.jpg	240	24	\N		1	38.00	2025-09-07 12:51:47.998978	2025-09-07 12:51:47.999266	\N
593	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	241	22	\N		2	56.00	2025-09-07 12:51:48.004858	2025-09-07 12:51:48.004817	\N
594	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	241	25	\N		3	174.00	2025-09-07 12:51:48.005951	2025-09-07 12:51:48.006321	\N
595	白切鸡	/images/dishes/baiqie_ji.jpg	241	24	\N		1	38.00	2025-09-07 12:51:48.007804	2025-09-07 12:51:48.008065	\N
596	白切鸡	/images/dishes/baiqie_ji.jpg	242	24	\N		3	114.00	2025-09-07 12:51:48.012297	2025-09-07 12:51:48.01205	\N
597	糖醋里脊	/images/dishes/tangcu_liji.jpg	242	26	\N		1	35.00	2025-09-07 12:51:48.014175	2025-09-07 12:51:48.014025	\N
598	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	243	22	\N		3	84.00	2025-09-07 12:51:48.018925	2025-09-07 12:51:48.01879	\N
599	白切鸡	/images/dishes/baiqie_ji.jpg	243	24	\N		2	76.00	2025-09-07 12:51:48.020009	2025-09-07 12:51:48.02026	\N
600	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	243	22	\N		3	84.00	2025-09-07 12:51:48.021162	2025-09-07 12:51:48.021288	\N
601	白切鸡	/images/dishes/baiqie_ji.jpg	243	24	\N		3	114.00	2025-09-07 12:51:48.022321	2025-09-07 12:51:48.022792	\N
602	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	244	25	\N		1	58.00	2025-09-07 12:51:48.028622	2025-09-07 12:51:48.028468	\N
603	白切鸡	/images/dishes/baiqie_ji.jpg	245	24	\N		3	114.00	2025-09-07 12:51:48.032803	2025-09-07 12:51:48.032663	\N
604	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	245	22	\N		3	84.00	2025-09-07 12:51:48.034849	2025-09-07 12:51:48.034647	\N
605	白切鸡	/images/dishes/baiqie_ji.jpg	245	24	\N		2	76.00	2025-09-07 12:51:48.036843	2025-09-07 12:51:48.036737	\N
606	糖醋里脊	/images/dishes/tangcu_liji.jpg	246	26	\N		1	35.00	2025-09-07 12:51:48.040895	2025-09-07 12:51:48.041138	\N
607	糖醋里脊	/images/dishes/tangcu_liji.jpg	246	26	\N		2	70.00	2025-09-07 12:51:48.042005	2025-09-07 12:51:48.042046	\N
608	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	247	25	\N		2	116.00	2025-09-07 12:51:48.047609	2025-09-07 12:51:48.047471	\N
609	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	247	25	\N		2	116.00	2025-09-07 12:51:48.049165	2025-09-07 12:51:48.049035	\N
610	麻婆豆腐	/images/dishes/mapo_doufu.jpg	247	23	\N		1	18.00	2025-09-07 12:51:48.050581	2025-09-07 12:51:48.050479	\N
611	麻婆豆腐	/images/dishes/mapo_doufu.jpg	248	23	\N		2	36.00	2025-09-07 12:51:48.055776	2025-09-07 12:51:48.055516	\N
612	麻婆豆腐	/images/dishes/mapo_doufu.jpg	248	23	\N		2	36.00	2025-09-07 12:51:48.057483	2025-09-07 12:51:48.057347	\N
613	糖醋里脊	/images/dishes/tangcu_liji.jpg	249	26	\N		2	70.00	2025-09-07 12:51:48.061879	2025-09-07 12:51:48.061899	\N
614	麻婆豆腐	/images/dishes/mapo_doufu.jpg	250	23	\N		2	36.00	2025-09-07 12:51:48.067263	2025-09-07 12:51:48.067297	\N
615	麻婆豆腐	/images/dishes/mapo_doufu.jpg	251	23	\N		1	18.00	2025-09-07 12:51:48.072608	2025-09-07 12:51:48.072448	\N
616	麻婆豆腐	/images/dishes/mapo_doufu.jpg	251	23	\N		2	36.00	2025-09-07 12:51:48.074338	2025-09-07 12:51:48.07446	\N
617	糖醋里脊	/images/dishes/tangcu_liji.jpg	252	26	\N		1	35.00	2025-09-07 12:51:48.07963	2025-09-07 12:51:48.079492	\N
618	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	253	22	\N		2	56.00	2025-09-07 12:51:48.085473	2025-09-07 12:51:48.08537	\N
619	糖醋里脊	/images/dishes/tangcu_liji.jpg	254	26	\N		2	70.00	2025-09-07 12:51:48.089762	2025-09-07 12:51:48.089931	\N
620	麻婆豆腐	/images/dishes/mapo_doufu.jpg	254	23	\N		3	54.00	2025-09-07 12:51:48.090901	2025-09-07 12:51:48.091266	\N
621	麻婆豆腐	/images/dishes/mapo_doufu.jpg	255	23	\N		3	54.00	2025-09-07 12:51:48.096464	2025-09-07 12:51:48.096348	\N
622	麻婆豆腐	/images/dishes/mapo_doufu.jpg	255	23	\N		3	54.00	2025-09-07 12:51:48.097548	2025-09-07 12:51:48.097886	\N
623	麻婆豆腐	/images/dishes/mapo_doufu.jpg	255	23	\N		2	36.00	2025-09-07 12:51:48.099924	2025-09-07 12:51:48.10017	\N
624	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	256	22	\N		3	84.00	2025-09-07 12:51:48.106424	2025-09-07 12:51:48.1065	\N
625	白切鸡	/images/dishes/baiqie_ji.jpg	256	24	\N		1	38.00	2025-09-07 12:51:48.108075	2025-09-07 12:51:48.107899	\N
626	白切鸡	/images/dishes/baiqie_ji.jpg	256	24	\N		1	38.00	2025-09-07 12:51:48.109839	2025-09-07 12:51:48.109786	\N
627	麻婆豆腐	/images/dishes/mapo_doufu.jpg	256	23	\N		3	54.00	2025-09-07 12:51:48.110893	2025-09-07 12:51:48.111152	\N
628	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	257	25	\N		2	116.00	2025-09-07 12:51:48.117519	2025-09-07 12:51:48.117775	\N
629	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	258	25	\N		2	116.00	2025-09-07 12:51:48.122759	2025-09-07 12:51:48.122723	\N
630	白切鸡	/images/dishes/baiqie_ji.jpg	259	24	\N		3	114.00	2025-09-07 12:51:48.127599	2025-09-07 12:51:48.127452	\N
631	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	259	25	\N		3	174.00	2025-09-07 12:51:48.129021	2025-09-07 12:51:48.128904	\N
632	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	259	25	\N		1	58.00	2025-09-07 12:51:48.130215	2025-09-07 12:51:48.130521	\N
633	麻婆豆腐	/images/dishes/mapo_doufu.jpg	259	23	\N		3	54.00	2025-09-07 12:51:48.131809	2025-09-07 12:51:48.131972	\N
634	白切鸡	/images/dishes/baiqie_ji.jpg	260	24	\N		1	38.00	2025-09-07 12:51:48.137122	2025-09-07 12:51:48.137267	\N
635	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	260	25	\N		2	116.00	2025-09-07 12:51:48.138743	2025-09-07 12:51:48.13876	\N
636	白切鸡	/images/dishes/baiqie_ji.jpg	260	24	\N		1	38.00	2025-09-07 12:51:48.13986	2025-09-07 12:51:48.14014	\N
637	白切鸡	/images/dishes/baiqie_ji.jpg	260	24	\N		1	38.00	2025-09-07 12:51:48.141501	2025-09-07 12:51:48.141654	\N
638	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	261	22	\N		3	84.00	2025-09-07 12:51:48.146449	2025-09-07 12:51:48.146687	\N
639	糖醋里脊	/images/dishes/tangcu_liji.jpg	262	26	\N		3	105.00	2025-09-07 12:51:48.151209	2025-09-07 12:51:48.151048	\N
640	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	262	22	\N		3	84.00	2025-09-07 12:51:48.152593	2025-09-07 12:51:48.152418	\N
641	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	262	25	\N		2	116.00	2025-09-07 12:51:48.153816	2025-09-07 12:51:48.154476	\N
642	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	262	25	\N		1	58.00	2025-09-07 12:51:48.156081	2025-09-07 12:51:48.156	\N
643	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	263	25	\N		3	174.00	2025-09-07 12:51:48.165418	2025-09-07 12:51:48.165532	\N
644	白切鸡	/images/dishes/baiqie_ji.jpg	264	24	\N		3	114.00	2025-09-07 12:51:48.170546	2025-09-07 12:51:48.170587	\N
645	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	264	25	\N		2	116.00	2025-09-07 12:51:48.17299	2025-09-07 12:51:48.17224	\N
646	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	264	25	\N		1	58.00	2025-09-07 12:51:48.175245	2025-09-07 12:51:48.175349	\N
647	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	265	22	\N		1	28.00	2025-09-07 12:51:48.19861	2025-09-07 12:51:48.198825	\N
648	麻婆豆腐	/images/dishes/mapo_doufu.jpg	265	23	\N		2	36.00	2025-09-07 12:51:48.200836	2025-09-07 12:51:48.200803	\N
649	麻婆豆腐	/images/dishes/mapo_doufu.jpg	266	23	\N		2	36.00	2025-09-07 12:51:48.207751	2025-09-07 12:51:48.207902	\N
650	糖醋里脊	/images/dishes/tangcu_liji.jpg	266	26	\N		1	35.00	2025-09-07 12:51:48.208862	2025-09-07 12:51:48.209279	\N
651	白切鸡	/images/dishes/baiqie_ji.jpg	266	24	\N		3	114.00	2025-09-07 12:51:48.210497	2025-09-07 12:51:48.210441	\N
652	白切鸡	/images/dishes/baiqie_ji.jpg	267	24	\N		2	76.00	2025-09-07 12:51:48.216013	2025-09-07 12:51:48.215862	\N
653	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	267	22	\N		2	56.00	2025-09-07 12:51:48.217656	2025-09-07 12:51:48.217517	\N
654	麻婆豆腐	/images/dishes/mapo_doufu.jpg	267	23	\N		1	18.00	2025-09-07 12:51:48.220158	2025-09-07 12:51:48.219972	\N
655	糖醋里脊	/images/dishes/tangcu_liji.jpg	267	26	\N		3	105.00	2025-09-07 12:51:48.224417	2025-09-07 12:51:48.224018	\N
656	麻婆豆腐	/images/dishes/mapo_doufu.jpg	268	23	\N		1	18.00	2025-09-07 12:51:48.230297	2025-09-07 12:51:48.230608	\N
657	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	268	25	\N		1	58.00	2025-09-07 12:51:48.2327	2025-09-07 12:51:48.232829	\N
658	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	268	25	\N		3	174.00	2025-09-07 12:51:48.236307	2025-09-07 12:51:48.23592	\N
659	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	268	25	\N		2	116.00	2025-09-07 12:51:48.239088	2025-09-07 12:51:48.238808	\N
660	麻婆豆腐	/images/dishes/mapo_doufu.jpg	269	23	\N		1	18.00	2025-09-07 12:51:48.245167	2025-09-07 12:51:48.245114	\N
661	糖醋里脊	/images/dishes/tangcu_liji.jpg	269	26	\N		1	35.00	2025-09-07 12:51:48.247982	2025-09-07 12:51:48.248	\N
662	白切鸡	/images/dishes/baiqie_ji.jpg	269	24	\N		2	76.00	2025-09-07 12:51:48.250054	2025-09-07 12:51:48.250424	\N
663	白切鸡	/images/dishes/baiqie_ji.jpg	269	24	\N		3	114.00	2025-09-07 12:51:48.253489	2025-09-07 12:51:48.252619	\N
664	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	270	25	\N		1	58.00	2025-09-07 12:51:48.259471	2025-09-07 12:51:48.259369	\N
665	麻婆豆腐	/images/dishes/mapo_doufu.jpg	270	23	\N		2	36.00	2025-09-07 12:51:48.261766	2025-09-07 12:51:48.261493	\N
666	白切鸡	/images/dishes/baiqie_ji.jpg	270	24	\N		1	38.00	2025-09-07 12:51:48.265462	2025-09-07 12:51:48.264516	\N
667	麻婆豆腐	/images/dishes/mapo_doufu.jpg	271	23	\N		3	54.00	2025-09-07 12:51:48.27304	2025-09-07 12:51:48.272243	\N
668	糖醋里脊	/images/dishes/tangcu_liji.jpg	271	26	\N		3	105.00	2025-09-07 12:51:48.275247	2025-09-07 12:51:48.275505	\N
669	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	272	22	\N		3	84.00	2025-09-07 12:51:48.282903	2025-09-07 12:51:48.282792	\N
670	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	272	22	\N		3	84.00	2025-09-07 12:51:48.284629	2025-09-07 12:51:48.284924	\N
671	白切鸡	/images/dishes/baiqie_ji.jpg	272	24	\N		3	114.00	2025-09-07 12:51:48.28685	2025-09-07 12:51:48.286766	\N
672	糖醋里脊	/images/dishes/tangcu_liji.jpg	272	26	\N		3	105.00	2025-09-07 12:51:48.287958	2025-09-07 12:51:48.28823	\N
673	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	273	25	\N		2	116.00	2025-09-07 12:51:48.294102	2025-09-07 12:51:48.293896	\N
674	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	273	25	\N		2	116.00	2025-09-07 12:51:48.296215	2025-09-07 12:51:48.296014	\N
675	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	273	25	\N		3	174.00	2025-09-07 12:51:48.297793	2025-09-07 12:51:48.297719	\N
676	白切鸡	/images/dishes/baiqie_ji.jpg	273	24	\N		1	38.00	2025-09-07 12:51:48.299518	2025-09-07 12:51:48.299427	\N
677	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	274	25	\N		2	116.00	2025-09-07 12:51:48.305187	2025-09-07 12:51:48.305248	\N
678	白切鸡	/images/dishes/baiqie_ji.jpg	274	24	\N		2	76.00	2025-09-07 12:51:48.306444	2025-09-07 12:51:48.306727	\N
679	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	274	25	\N		2	116.00	2025-09-07 12:51:48.30857	2025-09-07 12:51:48.308382	\N
680	麻婆豆腐	/images/dishes/mapo_doufu.jpg	275	23	\N		3	54.00	2025-09-07 12:51:48.315161	2025-09-07 12:51:48.315164	\N
681	麻婆豆腐	/images/dishes/mapo_doufu.jpg	276	23	\N		3	54.00	2025-09-07 12:51:48.321182	2025-09-07 12:51:48.320965	\N
682	白切鸡	/images/dishes/baiqie_ji.jpg	276	24	\N		1	38.00	2025-09-07 12:51:48.32344	2025-09-07 12:51:48.323177	\N
683	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	276	25	\N		3	174.00	2025-09-07 12:51:48.327091	2025-09-07 12:51:48.327012	\N
684	白切鸡	/images/dishes/baiqie_ji.jpg	277	24	\N		1	38.00	2025-09-07 12:51:48.333459	2025-09-07 12:51:48.333373	\N
685	糖醋里脊	/images/dishes/tangcu_liji.jpg	278	26	\N		3	105.00	2025-09-07 12:51:48.338558	2025-09-07 12:51:48.338952	\N
686	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	278	22	\N		2	56.00	2025-09-07 12:51:48.340755	2025-09-07 12:51:48.340642	\N
687	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	278	22	\N		3	84.00	2025-09-07 12:51:48.34383	2025-09-07 12:51:48.343659	\N
688	糖醋里脊	/images/dishes/tangcu_liji.jpg	278	26	\N		1	35.00	2025-09-07 12:51:48.345732	2025-09-07 12:51:48.346004	\N
689	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	279	22	\N		1	28.00	2025-09-07 12:51:48.350782	2025-09-07 12:51:48.351133	\N
690	麻婆豆腐	/images/dishes/mapo_doufu.jpg	280	23	\N		2	36.00	2025-09-07 12:51:48.358139	2025-09-07 12:51:48.357915	\N
691	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	280	22	\N		2	56.00	2025-09-07 12:51:48.360074	2025-09-07 12:51:48.35991	\N
692	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	280	25	\N		3	174.00	2025-09-07 12:51:48.361175	2025-09-07 12:51:48.361524	\N
693	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	281	22	\N		1	28.00	2025-09-07 12:51:48.368168	2025-09-07 12:51:48.368142	\N
694	麻婆豆腐	/images/dishes/mapo_doufu.jpg	281	23	\N		3	54.00	2025-09-07 12:51:48.369882	2025-09-07 12:51:48.369728	\N
695	麻婆豆腐	/images/dishes/mapo_doufu.jpg	281	23	\N		3	54.00	2025-09-07 12:51:48.370969	2025-09-07 12:51:48.371251	\N
696	白切鸡	/images/dishes/baiqie_ji.jpg	281	24	\N		1	38.00	2025-09-07 12:51:48.37406	2025-09-07 12:51:48.374284	\N
697	麻婆豆腐	/images/dishes/mapo_doufu.jpg	282	23	\N		2	36.00	2025-09-07 12:51:48.379801	2025-09-07 12:51:48.379806	\N
698	白切鸡	/images/dishes/baiqie_ji.jpg	283	24	\N		1	38.00	2025-09-07 12:51:48.386536	2025-09-07 12:51:48.386547	\N
699	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	284	25	\N		3	174.00	2025-09-07 12:51:48.391204	2025-09-07 12:51:48.391117	\N
700	糖醋里脊	/images/dishes/tangcu_liji.jpg	284	26	\N		1	35.00	2025-09-07 12:51:48.39247	2025-09-07 12:51:48.392728	\N
701	白切鸡	/images/dishes/baiqie_ji.jpg	284	24	\N		3	114.00	2025-09-07 12:51:48.395151	2025-09-07 12:51:48.395463	\N
702	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	285	22	\N		1	28.00	2025-09-07 12:51:48.400383	2025-09-07 12:51:48.400311	\N
703	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	285	25	\N		2	116.00	2025-09-07 12:51:48.401477	2025-09-07 12:51:48.40157	\N
704	糖醋里脊	/images/dishes/tangcu_liji.jpg	285	26	\N		3	105.00	2025-09-07 12:51:48.404566	2025-09-07 12:51:48.404654	\N
705	白切鸡	/images/dishes/baiqie_ji.jpg	285	24	\N		2	76.00	2025-09-07 12:51:48.406179	2025-09-07 12:51:48.40616	\N
706	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	286	25	\N		2	116.00	2025-09-07 12:51:48.409578	2025-09-07 12:51:48.409786	\N
707	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	286	25	\N		2	116.00	2025-09-07 12:51:48.410702	2025-09-07 12:51:48.410812	\N
708	白切鸡	/images/dishes/baiqie_ji.jpg	286	24	\N		2	76.00	2025-09-07 12:51:48.41179	2025-09-07 12:51:48.412016	\N
709	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	287	22	\N		3	84.00	2025-09-07 12:51:48.41873	2025-09-07 12:51:48.418651	\N
710	麻婆豆腐	/images/dishes/mapo_doufu.jpg	288	23	\N		3	54.00	2025-09-07 12:51:48.423778	2025-09-07 12:51:48.423637	\N
711	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	288	25	\N		1	58.00	2025-09-07 12:51:48.42501	2025-09-07 12:51:48.425229	\N
712	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	288	22	\N		1	28.00	2025-09-07 12:51:48.426607	2025-09-07 12:51:48.426594	\N
713	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	288	22	\N		3	84.00	2025-09-07 12:51:48.427659	2025-09-07 12:51:48.427959	\N
714	麻婆豆腐	/images/dishes/mapo_doufu.jpg	289	23	\N		2	36.00	2025-09-07 12:51:48.432124	2025-09-07 12:51:48.431998	\N
715	糖醋里脊	/images/dishes/tangcu_liji.jpg	289	26	\N		3	105.00	2025-09-07 12:51:48.435349	2025-09-07 12:51:48.43547	\N
716	糖醋里脊	/images/dishes/tangcu_liji.jpg	290	26	\N		2	70.00	2025-09-07 12:51:48.439974	2025-09-07 12:51:48.439971	\N
717	麻婆豆腐	/images/dishes/mapo_doufu.jpg	290	23	\N		2	36.00	2025-09-07 12:51:48.441586	2025-09-07 12:51:48.44154	\N
718	糖醋里脊	/images/dishes/tangcu_liji.jpg	290	26	\N		2	70.00	2025-09-07 12:51:48.442866	2025-09-07 12:51:48.443052	\N
719	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	291	22	\N		1	28.00	2025-09-07 12:51:48.448325	2025-09-07 12:51:48.448086	\N
720	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	292	22	\N		2	56.00	2025-09-07 12:51:48.454571	2025-09-07 12:51:48.454477	\N
721	糖醋里脊	/images/dishes/tangcu_liji.jpg	293	26	\N		1	35.00	2025-09-07 12:51:48.45891	2025-09-07 12:51:48.459185	\N
722	白切鸡	/images/dishes/baiqie_ji.jpg	293	24	\N		2	76.00	2025-09-07 12:51:48.460226	2025-09-07 12:51:48.460586	\N
723	麻婆豆腐	/images/dishes/mapo_doufu.jpg	293	23	\N		3	54.00	2025-09-07 12:51:48.461474	2025-09-07 12:51:48.461827	\N
724	麻婆豆腐	/images/dishes/mapo_doufu.jpg	293	23	\N		3	54.00	2025-09-07 12:51:48.464733	2025-09-07 12:51:48.464142	\N
725	白切鸡	/images/dishes/baiqie_ji.jpg	294	24	\N		2	76.00	2025-09-07 12:51:48.469403	2025-09-07 12:51:48.469315	\N
726	糖醋里脊	/images/dishes/tangcu_liji.jpg	294	26	\N		3	105.00	2025-09-07 12:51:48.470095	2025-09-07 12:51:48.47043	\N
727	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	295	25	\N		1	58.00	2025-09-07 12:51:48.475109	2025-09-07 12:51:48.475412	\N
728	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	295	25	\N		2	116.00	2025-09-07 12:51:48.476459	2025-09-07 12:51:48.476803	\N
729	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	295	22	\N		1	28.00	2025-09-07 12:51:48.478972	2025-09-07 12:51:48.479063	\N
730	糖醋里脊	/images/dishes/tangcu_liji.jpg	296	26	\N		2	70.00	2025-09-07 12:51:48.483299	2025-09-07 12:51:48.483481	\N
731	白切鸡	/images/dishes/baiqie_ji.jpg	296	24	\N		1	38.00	2025-09-07 12:51:48.485221	2025-09-07 12:51:48.485168	\N
732	麻婆豆腐	/images/dishes/mapo_doufu.jpg	297	23	\N		2	36.00	2025-09-07 12:51:48.489842	2025-09-07 12:51:48.490108	\N
733	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	297	22	\N		2	56.00	2025-09-07 12:51:48.491019	2025-09-07 12:51:48.491361	\N
734	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	297	22	\N		3	84.00	2025-09-07 12:51:48.492732	2025-09-07 12:51:48.492663	\N
735	麻婆豆腐	/images/dishes/mapo_doufu.jpg	298	23	\N		1	18.00	2025-09-07 12:51:48.499501	2025-09-07 12:51:48.499406	\N
736	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	298	25	\N		3	174.00	2025-09-07 12:51:48.501116	2025-09-07 12:51:48.501335	\N
737	麻婆豆腐	/images/dishes/mapo_doufu.jpg	298	23	\N		1	18.00	2025-09-07 12:51:48.503478	2025-09-07 12:51:48.503321	\N
738	糖醋里脊	/images/dishes/tangcu_liji.jpg	299	26	\N		3	105.00	2025-09-07 12:51:48.508404	2025-09-07 12:51:48.508323	\N
739	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	299	22	\N		2	56.00	2025-09-07 12:51:48.509853	2025-09-07 12:51:48.50993	\N
740	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	300	22	\N		3	84.00	2025-09-07 12:51:48.515056	2025-09-07 12:51:48.515114	\N
741	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	301	25	\N		1	58.00	2025-09-07 12:51:48.520046	2025-09-07 12:51:48.519854	\N
742	白切鸡	/images/dishes/baiqie_ji.jpg	301	24	\N		3	114.00	2025-09-07 12:51:48.521271	2025-09-07 12:51:48.521677	\N
743	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	301	22	\N		3	84.00	2025-09-07 12:51:48.523445	2025-09-07 12:51:48.523525	\N
744	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	301	22	\N		2	56.00	2025-09-07 12:51:48.525787	2025-09-07 12:51:48.525732	\N
745	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	302	25	\N		1	58.00	2025-09-07 12:51:48.531105	2025-09-07 12:51:48.531148	\N
746	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	302	25	\N		1	58.00	2025-09-07 12:51:48.532784	2025-09-07 12:51:48.532593	\N
747	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	302	25	\N		2	116.00	2025-09-07 12:51:48.534884	2025-09-07 12:51:48.534754	\N
748	麻婆豆腐	/images/dishes/mapo_doufu.jpg	303	23	\N		3	54.00	2025-09-07 12:51:48.538851	2025-09-07 12:51:48.539038	\N
749	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	303	25	\N		1	58.00	2025-09-07 12:51:48.540718	2025-09-07 12:51:48.540766	\N
750	糖醋里脊	/images/dishes/tangcu_liji.jpg	304	26	\N		1	35.00	2025-09-07 12:51:48.546508	2025-09-07 12:51:48.546592	\N
751	白切鸡	/images/dishes/baiqie_ji.jpg	304	24	\N		2	76.00	2025-09-07 12:51:48.54815	2025-09-07 12:51:48.548004	\N
752	麻婆豆腐	/images/dishes/mapo_doufu.jpg	304	23	\N		3	54.00	2025-09-07 12:51:48.549783	2025-09-07 12:51:48.549707	\N
753	糖醋里脊	/images/dishes/tangcu_liji.jpg	305	26	\N		2	70.00	2025-09-07 12:51:48.554467	2025-09-07 12:51:48.554775	\N
754	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	305	25	\N		1	58.00	2025-09-07 12:51:48.558188	2025-09-07 12:51:48.558122	\N
755	白切鸡	/images/dishes/baiqie_ji.jpg	306	24	\N		1	38.00	2025-09-07 12:51:48.564144	2025-09-07 12:51:48.564075	\N
756	糖醋里脊	/images/dishes/tangcu_liji.jpg	306	26	\N		1	35.00	2025-09-07 12:51:48.565818	2025-09-07 12:51:48.565909	\N
757	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	307	25	\N		1	58.00	2025-09-07 12:51:48.571006	2025-09-07 12:51:48.570847	\N
758	麻婆豆腐	/images/dishes/mapo_doufu.jpg	307	23	\N		3	54.00	2025-09-07 12:51:48.572915	2025-09-07 12:51:48.572838	\N
759	糖醋里脊	/images/dishes/tangcu_liji.jpg	307	26	\N		2	70.00	2025-09-07 12:51:48.57503	2025-09-07 12:51:48.575078	\N
760	白切鸡	/images/dishes/baiqie_ji.jpg	308	24	\N		3	114.00	2025-09-07 12:51:48.58179	2025-09-07 12:51:48.581706	\N
761	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	308	25	\N		3	174.00	2025-09-07 12:51:48.58487	2025-09-07 12:51:48.584658	\N
762	白切鸡	/images/dishes/baiqie_ji.jpg	309	24	\N		1	38.00	2025-09-07 12:51:48.591839	2025-09-07 12:51:48.591779	\N
763	糖醋里脊	/images/dishes/tangcu_liji.jpg	309	26	\N		3	105.00	2025-09-07 12:51:48.593848	2025-09-07 12:51:48.593915	\N
764	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	309	25	\N		2	116.00	2025-09-07 12:51:48.596751	2025-09-07 12:51:48.596658	\N
765	麻婆豆腐	/images/dishes/mapo_doufu.jpg	309	23	\N		3	54.00	2025-09-07 12:51:48.598939	2025-09-07 12:51:48.598688	\N
766	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	310	22	\N		1	28.00	2025-09-07 12:51:48.606528	2025-09-07 12:51:48.606665	\N
767	白切鸡	/images/dishes/baiqie_ji.jpg	310	24	\N		3	114.00	2025-09-07 12:51:48.608361	2025-09-07 12:51:48.608333	\N
768	糖醋里脊	/images/dishes/tangcu_liji.jpg	310	26	\N		3	105.00	2025-09-07 12:51:48.610249	2025-09-07 12:51:48.610079	\N
769	白切鸡	/images/dishes/baiqie_ji.jpg	310	24	\N		3	114.00	2025-09-07 12:51:48.611455	2025-09-07 12:51:48.611754	\N
770	糖醋里脊	/images/dishes/tangcu_liji.jpg	311	26	\N		2	70.00	2025-09-07 12:51:48.718216	2025-09-07 12:51:48.718044	\N
771	糖醋里脊	/images/dishes/tangcu_liji.jpg	312	26	\N		1	35.00	2025-09-07 12:51:48.774101	2025-09-07 12:51:48.774117	\N
772	麻婆豆腐	/images/dishes/mapo_doufu.jpg	312	23	\N		1	18.00	2025-09-07 12:51:48.776129	2025-09-07 12:51:48.776054	\N
773	麻婆豆腐	/images/dishes/mapo_doufu.jpg	312	23	\N		1	18.00	2025-09-07 12:51:48.778295	2025-09-07 12:51:48.779076	\N
774	麻婆豆腐	/images/dishes/mapo_doufu.jpg	313	23	\N		3	54.00	2025-09-07 12:51:48.788652	2025-09-07 12:51:48.788926	\N
775	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	313	25	\N		3	174.00	2025-09-07 12:51:48.792206	2025-09-07 12:51:48.792121	\N
776	麻婆豆腐	/images/dishes/mapo_doufu.jpg	313	23	\N		2	36.00	2025-09-07 12:51:48.794774	2025-09-07 12:51:48.794654	\N
777	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	314	25	\N		3	174.00	2025-09-07 12:51:48.801133	2025-09-07 12:51:48.80085	\N
778	糖醋里脊	/images/dishes/tangcu_liji.jpg	314	26	\N		3	105.00	2025-09-07 12:51:48.803349	2025-09-07 12:51:48.803543	\N
779	麻婆豆腐	/images/dishes/mapo_doufu.jpg	315	23	\N		1	18.00	2025-09-07 12:51:48.809482	2025-09-07 12:51:48.809872	\N
780	白切鸡	/images/dishes/baiqie_ji.jpg	315	24	\N		2	76.00	2025-09-07 12:51:48.811746	2025-09-07 12:51:48.811702	\N
781	白切鸡	/images/dishes/baiqie_ji.jpg	316	24	\N		1	38.00	2025-09-07 12:51:48.83755	2025-09-07 12:51:48.837926	\N
782	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	316	22	\N		2	56.00	2025-09-07 12:51:48.839843	2025-09-07 12:51:48.839938	\N
783	麻婆豆腐	/images/dishes/mapo_doufu.jpg	316	23	\N		1	18.00	2025-09-07 12:51:48.843204	2025-09-07 12:51:48.842057	\N
784	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	316	25	\N		3	174.00	2025-09-07 12:51:48.848338	2025-09-07 12:51:48.848283	\N
785	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	317	25	\N		1	58.00	2025-09-07 12:51:48.854953	2025-09-07 12:51:48.854898	\N
786	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	318	22	\N		3	84.00	2025-09-07 12:51:48.860924	2025-09-07 12:51:48.860826	\N
787	糖醋里脊	/images/dishes/tangcu_liji.jpg	318	26	\N		2	70.00	2025-09-07 12:51:48.862817	2025-09-07 12:51:48.86301	\N
788	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	319	22	\N		2	56.00	2025-09-07 12:51:48.868861	2025-09-07 12:51:48.869256	\N
789	白切鸡	/images/dishes/baiqie_ji.jpg	319	24	\N		2	76.00	2025-09-07 12:51:48.871236	2025-09-07 12:51:48.871066	\N
790	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	319	22	\N		3	84.00	2025-09-07 12:51:48.872283	2025-09-07 12:51:48.872793	\N
791	糖醋里脊	/images/dishes/tangcu_liji.jpg	320	26	\N		1	35.00	2025-09-07 12:51:48.881787	2025-09-07 12:51:48.881892	\N
792	麻婆豆腐	/images/dishes/mapo_doufu.jpg	320	23	\N		1	18.00	2025-09-07 12:51:48.884244	2025-09-07 12:51:48.884031	\N
793	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	320	22	\N		1	28.00	2025-09-07 12:51:48.886493	2025-09-07 12:51:48.886669	\N
794	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	321	25	\N		2	116.00	2025-09-07 12:51:48.89256	2025-09-07 12:51:48.892273	\N
795	糖醋里脊	/images/dishes/tangcu_liji.jpg	322	26	\N		2	70.00	2025-09-07 12:51:48.899093	2025-09-07 12:51:48.899184	\N
796	糖醋里脊	/images/dishes/tangcu_liji.jpg	322	26	\N		1	35.00	2025-09-07 12:51:48.900868	2025-09-07 12:51:48.900932	\N
797	糖醋里脊	/images/dishes/tangcu_liji.jpg	322	26	\N		3	105.00	2025-09-07 12:51:48.903343	2025-09-07 12:51:48.903088	\N
798	麻婆豆腐	/images/dishes/mapo_doufu.jpg	323	23	\N		2	36.00	2025-09-07 12:51:48.909212	2025-09-07 12:51:48.909435	\N
799	糖醋里脊	/images/dishes/tangcu_liji.jpg	323	26	\N		3	105.00	2025-09-07 12:51:48.910939	2025-09-07 12:51:48.911206	\N
800	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	324	25	\N		3	174.00	2025-09-07 12:51:48.91729	2025-09-07 12:51:48.917371	\N
801	麻婆豆腐	/images/dishes/mapo_doufu.jpg	324	23	\N		2	36.00	2025-09-07 12:51:48.919281	2025-09-07 12:51:48.919481	\N
802	麻婆豆腐	/images/dishes/mapo_doufu.jpg	324	23	\N		1	18.00	2025-09-07 12:51:48.921691	2025-09-07 12:51:48.921499	\N
803	糖醋里脊	/images/dishes/tangcu_liji.jpg	324	26	\N		3	105.00	2025-09-07 12:51:48.923598	2025-09-07 12:51:48.923699	\N
804	糖醋里脊	/images/dishes/tangcu_liji.jpg	325	26	\N		3	105.00	2025-09-07 12:51:48.928465	2025-09-07 12:51:48.928466	\N
805	麻婆豆腐	/images/dishes/mapo_doufu.jpg	325	23	\N		1	18.00	2025-09-07 12:51:48.930286	2025-09-07 12:51:48.930252	\N
806	白切鸡	/images/dishes/baiqie_ji.jpg	325	24	\N		2	76.00	2025-09-07 12:51:48.931541	2025-09-07 12:51:48.931909	\N
807	白切鸡	/images/dishes/baiqie_ji.jpg	325	24	\N		2	76.00	2025-09-07 12:51:48.933807	2025-09-07 12:51:48.933811	\N
808	白切鸡	/images/dishes/baiqie_ji.jpg	326	24	\N		3	114.00	2025-09-07 12:51:48.938322	2025-09-07 12:51:48.938688	\N
809	糖醋里脊	/images/dishes/tangcu_liji.jpg	326	26	\N		1	35.00	2025-09-07 12:51:48.939838	2025-09-07 12:51:48.94018	\N
810	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	327	25	\N		2	116.00	2025-09-07 12:51:48.945772	2025-09-07 12:51:48.945706	\N
811	白切鸡	/images/dishes/baiqie_ji.jpg	327	24	\N		1	38.00	2025-09-07 12:51:48.946922	2025-09-07 12:51:48.947214	\N
812	白切鸡	/images/dishes/baiqie_ji.jpg	327	24	\N		3	114.00	2025-09-07 12:51:48.949136	2025-09-07 12:51:48.949001	\N
813	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	327	22	\N		2	56.00	2025-09-07 12:51:48.950905	2025-09-07 12:51:48.950782	\N
814	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	328	25	\N		3	174.00	2025-09-07 12:51:48.956747	2025-09-07 12:51:48.956755	\N
815	糖醋里脊	/images/dishes/tangcu_liji.jpg	328	26	\N		3	105.00	2025-09-07 12:51:48.958958	2025-09-07 12:51:48.959256	\N
816	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	329	22	\N		2	56.00	2025-09-07 12:51:48.965017	2025-09-07 12:51:48.964764	\N
817	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	329	25	\N		1	58.00	2025-09-07 12:51:48.966829	2025-09-07 12:51:48.966647	\N
818	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	330	22	\N	不辣, 甜味	1	28.00	2025-09-13 14:16:03.631306	2025-09-13 14:16:03.619853	\N
819	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	331	22	\N	不辣, 甜味	1	28.00	2025-09-15 17:19:31.603607	2025-09-15 17:19:31.599493	\N
820	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	331	22	\N	重辣, 甜味	1	28.00	2025-09-15 17:19:31.603607	2025-09-15 17:19:31.599493	\N
821	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	332	22	\N	不辣, 甜味	1	28.00	2025-09-16 10:36:36.998297	2025-09-16 10:36:36.992366	\N
822	白切鸡	/uploads/dishes/1757834539920259700.jpg	333	24	\N		2	38.00	2025-09-16 15:01:31.718614	2025-09-16 15:01:31.715586	\N
823	剁椒鱼头	/uploads/dishes/1757834553101742200.jpg	334	25	\N	特辣	1	58.00	2025-09-16 19:38:04.367661	2025-09-16 19:38:04.365269	\N
824	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	335	26	\N		1	35.00	2025-09-16 20:06:51.626659	2025-09-16 20:06:51.625071	\N
825	麻婆豆腐	/uploads/dishes/1757834528208064400.jpg	335	23	\N	微辣	1	18.00	2025-09-16 20:06:51.626659	2025-09-16 20:06:51.625071	\N
826	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	336	26	\N		1	35.00	2025-09-16 20:07:45.691759	2025-09-16 20:07:45.690846	\N
827	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	337	22	\N	不辣, 甜味	1	28.00	2025-09-16 20:09:06.008422	2025-09-16 20:09:06.006394	\N
828	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	338	26	\N		1	35.00	2025-09-16 20:16:04.499098	2025-09-16 20:16:04.498335	\N
829	剁椒鱼头	/uploads/dishes/1757834553101742200.jpg	339	25	\N	重辣	1	58.00	2025-09-16 20:21:34.461482	2025-09-16 20:21:34.460715	\N
830	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	340	22	\N	重辣, 甜味	1	28.00	2025-09-16 20:29:47.310986	2025-09-16 20:29:47.310379	\N
831	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	341	22	\N	微辣, 麻辣	1	28.00	2025-09-16 23:41:45.964312	2025-09-16 23:41:45.961972	\N
832	白切鸡	/uploads/dishes/1757834539920259700.jpg	342	24	\N		1	38.00	2025-09-19 14:22:17.431493	2025-09-19 14:22:17.428775	\N
833	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	343	22	\N	不辣, 甜味	1	28.00	2025-09-22 14:18:46.3891	2025-09-22 14:18:46.384988	\N
\.


--
-- TOC entry 5079 (class 0 OID 16753)
-- Dependencies: 232
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, number, status, user_id, address_book_id, order_time, checkout_time, pay_method, pay_status, amount, remark, phone, address, user_name, consignee, delivery_time, estimated_delivery_time, created_at, updated_at, cancel_reason, rejection_reason, cancel_time, delivery_status, pack_amount, tableware_number, tableware_status, deleted_at, alipay_order_no, pay_time) FROM stdin;
4	ORDER202508080001	5	9	1	2025-08-08 09:32:00	2025-08-08 09:51:00	2	1	112.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 10:39:00	\N	2025-09-07 12:51:45.995049	2025-09-07 12:51:46.011833			\N	1	0	0	1	\N	\N	\N
5	ORDER202508080002	5	9	1	2025-08-08 06:02:00	2025-08-08 06:22:00	2	1	150.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 06:55:00	\N	2025-09-07 12:51:46.025595	2025-09-07 12:51:46.033934			\N	1	0	0	1	\N	\N	\N
6	ORDER202508080003	5	8	1	2025-08-08 09:37:00	2025-08-08 10:01:00	1	1	295.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-08 10:50:00	\N	2025-09-07 12:51:46.036101	2025-09-07 12:51:46.046819			\N	1	0	0	1	\N	\N	\N
7	ORDER202508080004	3	8	1	2025-08-08 08:12:00	\N	1	1	430.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:46.048832	2025-09-07 12:51:46.057294			\N	1	0	0	1	\N	\N	\N
8	ORDER202508080005	5	8	1	2025-08-08 12:11:00	2025-08-08 12:49:00	2	1	276.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-08 13:28:00	\N	2025-09-07 12:51:46.058588	2025-09-07 12:51:46.067116			\N	1	0	0	1	\N	\N	\N
9	ORDER202508080006	5	9	1	2025-08-08 17:49:00	2025-08-08 18:01:00	2	1	102.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 18:42:00	\N	2025-09-07 12:51:46.069209	2025-09-07 12:51:46.079432			\N	1	0	0	1	\N	\N	\N
10	ORDER202508080007	5	9	1	2025-08-08 07:42:00	2025-08-08 07:55:00	2	1	114.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 08:48:00	\N	2025-09-07 12:51:46.081853	2025-09-07 12:51:46.087612			\N	1	0	0	1	\N	\N	\N
11	ORDER202508080008	5	9	1	2025-08-08 14:49:00	2025-08-08 15:07:00	2	1	174.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 15:50:00	\N	2025-09-07 12:51:46.089194	2025-09-07 12:51:46.092843			\N	1	0	0	1	\N	\N	\N
12	ORDER202508080009	5	9	1	2025-08-08 18:52:00	2025-08-08 19:23:00	2	1	129.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 19:49:00	\N	2025-09-07 12:51:46.095749	2025-09-07 12:51:46.104825			\N	1	0	0	1	\N	\N	\N
13	ORDER202508080010	5	9	1	2025-08-08 04:19:00	2025-08-08 04:32:00	1	1	190.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 05:22:00	\N	2025-09-07 12:51:46.106857	2025-09-07 12:51:46.120378			\N	1	0	0	1	\N	\N	\N
14	ORDER202508080011	5	9	1	2025-08-08 09:35:00	2025-08-08 09:45:00	1	1	280.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-08 10:12:00	\N	2025-09-07 12:51:46.122141	2025-09-07 12:51:46.130358			\N	1	0	0	1	\N	\N	\N
15	ORDER202508090012	5	9	1	2025-08-09 20:18:00	2025-08-09 20:40:00	1	1	158.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-09 21:21:00	\N	2025-09-07 12:51:46.132756	2025-09-07 12:51:46.14086			\N	1	0	0	1	\N	\N	\N
16	ORDER202508090013	5	8	1	2025-08-09 22:45:00	2025-08-09 23:02:00	2	1	231.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-09 23:46:00	\N	2025-09-07 12:51:46.14284	2025-09-07 12:51:46.151661			\N	1	0	0	1	\N	\N	\N
17	ORDER202508090014	5	9	1	2025-08-09 09:26:00	2025-08-09 09:50:00	1	1	289.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-09 10:31:00	\N	2025-09-07 12:51:46.153668	2025-09-07 12:51:46.162691			\N	1	0	0	1	\N	\N	\N
18	ORDER202508090015	5	8	1	2025-08-09 00:44:00	2025-08-09 01:21:00	1	1	142.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-09 01:53:00	\N	2025-09-07 12:51:46.164821	2025-09-07 12:51:46.173695			\N	1	0	0	1	\N	\N	\N
19	ORDER202508090016	5	10	1	2025-08-09 08:28:00	2025-08-09 08:43:00	2	1	346.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-09 09:17:00	\N	2025-09-07 12:51:46.176971	2025-09-07 12:51:46.186863			\N	1	0	0	1	\N	\N	\N
20	ORDER202508090017	5	8	1	2025-08-09 10:44:00	2025-08-09 11:00:00	1	1	172.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-09 11:36:00	\N	2025-09-07 12:51:46.188073	2025-09-07 12:51:46.195465			\N	1	0	0	1	\N	\N	\N
21	ORDER202508090018	5	10	1	2025-08-09 03:01:00	2025-08-09 03:21:00	1	1	174.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-09 03:43:00	\N	2025-09-07 12:51:46.197288	2025-09-07 12:51:46.201612			\N	1	0	0	1	\N	\N	\N
22	ORDER202508090019	5	8	1	2025-08-09 13:29:00	2025-08-09 13:39:00	1	1	120.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-09 14:25:00	\N	2025-09-07 12:51:46.205604	2025-09-07 12:51:46.216322			\N	1	0	0	1	\N	\N	\N
23	ORDER202508090020	5	9	1	2025-08-09 09:08:00	2025-08-09 09:39:00	2	1	18.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-09 10:11:00	\N	2025-09-07 12:51:46.218367	2025-09-07 12:51:46.222654			\N	1	0	0	1	\N	\N	\N
24	ORDER202508100021	5	10	1	2025-08-10 22:31:00	2025-08-10 23:09:00	1	1	74.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-10 23:30:00	\N	2025-09-07 12:51:46.225192	2025-09-07 12:51:46.23158			\N	1	0	0	1	\N	\N	\N
25	ORDER202508100022	5	10	1	2025-08-10 20:25:00	2025-08-10 20:54:00	1	1	192.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-10 21:33:00	\N	2025-09-07 12:51:46.233673	2025-09-07 12:51:46.24275			\N	1	0	0	1	\N	\N	\N
26	ORDER202508100023	5	10	1	2025-08-10 05:29:00	2025-08-10 05:42:00	1	1	161.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-10 06:41:00	\N	2025-09-07 12:51:46.244153	2025-09-07 12:51:46.250975			\N	1	0	0	1	\N	\N	\N
27	ORDER202508100024	6	9	1	2025-08-10 17:49:00	\N	2	2	150.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:46.252031	2025-09-07 12:51:46.25917			\N	1	0	0	1	\N	\N	\N
28	ORDER202508100025	5	9	1	2025-08-10 07:05:00	2025-08-10 07:41:00	1	1	105.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-10 08:18:00	\N	2025-09-07 12:51:46.260969	2025-09-07 12:51:46.26576			\N	1	0	0	1	\N	\N	\N
29	ORDER202508100026	5	9	1	2025-08-10 01:23:00	2025-08-10 01:35:00	2	1	56.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-10 02:03:00	\N	2025-09-07 12:51:46.26731	2025-09-07 12:51:46.270922			\N	1	0	0	1	\N	\N	\N
30	ORDER202508100027	5	8	1	2025-08-10 07:09:00	2025-08-10 07:27:00	1	1	419.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-10 08:18:00	\N	2025-09-07 12:51:46.272379	2025-09-07 12:51:46.281601			\N	1	0	0	1	\N	\N	\N
31	ORDER202508100028	5	9	1	2025-08-10 23:27:00	2025-08-10 23:57:00	1	1	96.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-11 00:30:00	\N	2025-09-07 12:51:46.284131	2025-09-07 12:51:46.289128			\N	1	0	0	1	\N	\N	\N
32	ORDER202508100029	5	8	1	2025-08-10 16:22:00	2025-08-10 16:37:00	2	1	84.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-10 17:07:00	\N	2025-09-07 12:51:46.290913	2025-09-07 12:51:46.295164			\N	1	0	0	1	\N	\N	\N
33	ORDER202508100030	5	8	1	2025-08-10 08:21:00	2025-08-10 09:00:00	2	1	181.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-10 09:59:00	\N	2025-09-07 12:51:46.298594	2025-09-07 12:51:46.307764			\N	1	0	0	1	\N	\N	\N
34	ORDER202508100031	5	10	1	2025-08-10 07:42:00	2025-08-10 08:21:00	1	1	198.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-10 08:41:00	\N	2025-09-07 12:51:46.308724	2025-09-07 12:51:46.318036			\N	1	0	0	1	\N	\N	\N
35	ORDER202508100032	5	9	1	2025-08-10 22:08:00	2025-08-10 22:21:00	1	1	114.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-10 23:11:00	\N	2025-09-07 12:51:46.319725	2025-09-07 12:51:46.322865			\N	1	0	0	1	\N	\N	\N
36	ORDER202508100033	1	9	1	2025-08-10 01:49:00	\N	2	1	210.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:46.324683	2025-09-07 12:51:46.331248			\N	1	0	0	1	\N	\N	\N
37	ORDER202508100034	4	8	1	2025-08-10 17:29:00	\N	2	1	36.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:46.332812	2025-09-07 12:51:46.336012			\N	1	0	0	1	\N	\N	\N
38	ORDER202508100035	5	9	1	2025-08-10 11:17:00	2025-08-10 11:40:00	1	1	227.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-10 12:35:00	\N	2025-09-07 12:51:46.337514	2025-09-07 12:51:46.346277			\N	1	0	0	1	\N	\N	\N
39	ORDER202508110036	5	10	1	2025-08-11 09:28:00	2025-08-11 09:52:00	1	1	174.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-11 10:25:00	\N	2025-09-07 12:51:46.347975	2025-09-07 12:51:46.353132			\N	1	0	0	1	\N	\N	\N
40	ORDER202508110037	5	8	1	2025-08-11 18:17:00	2025-08-11 18:32:00	1	1	56.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-11 19:30:00	\N	2025-09-07 12:51:46.355425	2025-09-07 12:51:46.36065			\N	1	0	0	1	\N	\N	\N
41	ORDER202508110038	5	10	1	2025-08-11 21:32:00	2025-08-11 21:56:00	2	1	114.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-11 22:35:00	\N	2025-09-07 12:51:46.362295	2025-09-07 12:51:46.366297			\N	1	0	0	1	\N	\N	\N
42	ORDER202508110039	5	10	1	2025-08-11 23:01:00	2025-08-11 23:33:00	2	1	105.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-12 00:13:00	\N	2025-09-07 12:51:46.367502	2025-09-07 12:51:46.372753			\N	1	0	0	1	\N	\N	\N
43	ORDER202508110040	5	9	1	2025-08-11 21:38:00	2025-08-11 22:02:00	2	1	354.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-11 22:24:00	\N	2025-09-07 12:51:46.37523	2025-09-07 12:51:46.385113			\N	1	0	0	1	\N	\N	\N
44	ORDER202508110041	5	9	1	2025-08-11 14:34:00	2025-08-11 14:48:00	1	1	347.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-11 15:41:00	\N	2025-09-07 12:51:46.386306	2025-09-07 12:51:46.396223			\N	1	0	0	1	\N	\N	\N
45	ORDER202508110042	5	10	1	2025-08-11 21:05:00	2025-08-11 21:41:00	1	1	353.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-11 22:12:00	\N	2025-09-07 12:51:46.397892	2025-09-07 12:51:46.407536			\N	1	0	0	1	\N	\N	\N
46	ORDER202508110043	5	9	1	2025-08-11 12:31:00	2025-08-11 13:10:00	2	1	257.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-11 13:47:00	\N	2025-09-07 12:51:46.408948	2025-09-07 12:51:46.416346			\N	1	0	0	1	\N	\N	\N
47	ORDER202508110044	1	8	1	2025-08-11 07:25:00	\N	1	1	159.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:46.417648	2025-09-07 12:51:46.424411			\N	1	0	0	1	\N	\N	\N
48	ORDER202508110045	5	10	1	2025-08-11 16:50:00	2025-08-11 17:16:00	1	1	393.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-11 17:57:00	\N	2025-09-07 12:51:46.426189	2025-09-07 12:51:46.432176			\N	1	0	0	1	\N	\N	\N
49	ORDER202508110046	5	10	1	2025-08-11 05:07:00	2025-08-11 05:34:00	1	1	76.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-11 06:07:00	\N	2025-09-07 12:51:46.434956	2025-09-07 12:51:46.439101			\N	1	0	0	1	\N	\N	\N
50	ORDER202508110047	5	8	1	2025-08-11 03:07:00	2025-08-11 03:17:00	2	1	360.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-11 04:09:00	\N	2025-09-07 12:51:46.440889	2025-09-07 12:51:46.448371			\N	1	0	0	1	\N	\N	\N
51	ORDER202508110048	5	9	1	2025-08-11 21:34:00	2025-08-11 21:58:00	1	1	94.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-11 22:30:00	\N	2025-09-07 12:51:46.450111	2025-09-07 12:51:46.456544			\N	1	0	0	1	\N	\N	\N
52	ORDER202508120049	5	8	1	2025-08-12 19:05:00	2025-08-12 19:24:00	2	1	230.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-12 19:50:00	\N	2025-09-07 12:51:46.457588	2025-09-07 12:51:46.462305			\N	1	0	0	1	\N	\N	\N
53	ORDER202508120050	4	10	1	2025-08-12 15:39:00	\N	2	1	306.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:46.464416	2025-09-07 12:51:46.475671			\N	1	0	0	1	\N	\N	\N
54	ORDER202508120051	5	8	1	2025-08-12 04:14:00	2025-08-12 04:36:00	1	1	108.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-12 05:10:00	\N	2025-09-07 12:51:46.477073	2025-09-07 12:51:46.485723			\N	1	0	0	1	\N	\N	\N
55	ORDER202508120052	5	9	1	2025-08-12 23:43:00	2025-08-13 00:10:00	2	1	294.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-13 00:46:00	\N	2025-09-07 12:51:46.487298	2025-09-07 12:51:46.496848			\N	1	0	0	1	\N	\N	\N
56	ORDER202508120053	5	8	1	2025-08-12 11:14:00	2025-08-12 11:32:00	2	1	92.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-12 12:25:00	\N	2025-09-07 12:51:46.498142	2025-09-07 12:51:46.50396			\N	1	0	0	1	\N	\N	\N
57	ORDER202508120054	5	9	1	2025-08-12 06:10:00	2025-08-12 06:42:00	1	1	402.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-12 07:13:00	\N	2025-09-07 12:51:46.506273	2025-09-07 12:51:46.517404			\N	1	0	0	1	\N	\N	\N
58	ORDER202508120055	5	8	1	2025-08-12 10:16:00	2025-08-12 10:43:00	1	1	203.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-12 11:28:00	\N	2025-09-07 12:51:46.519383	2025-09-07 12:51:46.528484			\N	1	0	0	1	\N	\N	\N
59	ORDER202508120056	5	9	1	2025-08-12 07:28:00	2025-08-12 07:59:00	1	1	240.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-12 08:36:00	\N	2025-09-07 12:51:46.529918	2025-09-07 12:51:46.537507			\N	1	0	0	1	\N	\N	\N
60	ORDER202508130057	5	10	1	2025-08-13 14:53:00	2025-08-13 15:32:00	1	1	356.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 16:01:00	\N	2025-09-07 12:51:46.538812	2025-09-07 12:51:46.546296			\N	1	0	0	1	\N	\N	\N
61	ORDER202508130058	5	10	1	2025-08-13 00:22:00	2025-08-13 00:57:00	1	1	284.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 01:37:00	\N	2025-09-07 12:51:46.547334	2025-09-07 12:51:46.554231			\N	1	0	0	1	\N	\N	\N
62	ORDER202508130059	5	8	1	2025-08-13 05:23:00	2025-08-13 05:54:00	1	1	38.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-13 06:45:00	\N	2025-09-07 12:51:46.556008	2025-09-07 12:51:46.559448			\N	1	0	0	1	\N	\N	\N
63	ORDER202508130060	5	10	1	2025-08-13 12:00:00	2025-08-13 12:38:00	1	1	38.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 13:27:00	\N	2025-09-07 12:51:46.560375	2025-09-07 12:51:46.563543			\N	1	0	0	1	\N	\N	\N
64	ORDER202508130061	5	10	1	2025-08-13 17:05:00	2025-08-13 17:18:00	1	1	172.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 17:43:00	\N	2025-09-07 12:51:46.565342	2025-09-07 12:51:46.569555			\N	1	0	0	1	\N	\N	\N
65	ORDER202508130062	5	8	1	2025-08-13 11:59:00	2025-08-13 12:36:00	1	1	214.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-13 13:00:00	\N	2025-09-07 12:51:46.570204	2025-09-07 12:51:46.578681			\N	1	0	0	1	\N	\N	\N
66	ORDER202508130063	5	9	1	2025-08-13 09:34:00	2025-08-13 09:54:00	2	1	84.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-13 10:31:00	\N	2025-09-07 12:51:46.579541	2025-09-07 12:51:46.582774			\N	1	0	0	1	\N	\N	\N
67	ORDER202508130064	5	9	1	2025-08-13 18:41:00	2025-08-13 19:02:00	1	1	70.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-13 19:42:00	\N	2025-09-07 12:51:46.584158	2025-09-07 12:51:46.587564			\N	1	0	0	1	\N	\N	\N
68	ORDER202508130065	5	8	1	2025-08-13 23:04:00	2025-08-13 23:14:00	1	1	35.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-13 23:43:00	\N	2025-09-07 12:51:46.589262	2025-09-07 12:51:46.591925			\N	1	0	0	1	\N	\N	\N
69	ORDER202508130066	5	10	1	2025-08-13 20:57:00	2025-08-13 21:22:00	2	1	105.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 22:19:00	\N	2025-09-07 12:51:46.593653	2025-09-07 12:51:46.597014			\N	1	0	0	1	\N	\N	\N
70	ORDER202508130067	5	10	1	2025-08-13 10:34:00	2025-08-13 10:47:00	1	1	284.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 11:24:00	\N	2025-09-07 12:51:46.597991	2025-09-07 12:51:46.605108			\N	1	0	0	1	\N	\N	\N
71	ORDER202508130068	5	10	1	2025-08-13 17:15:00	2025-08-13 17:29:00	2	1	54.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 17:58:00	\N	2025-09-07 12:51:46.606453	2025-09-07 12:51:46.610027			\N	1	0	0	1	\N	\N	\N
72	ORDER202508130069	5	10	1	2025-08-13 17:07:00	2025-08-13 17:19:00	2	1	38.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-13 17:44:00	\N	2025-09-07 12:51:46.610926	2025-09-07 12:51:46.614224			\N	1	0	0	1	\N	\N	\N
73	ORDER202508130070	5	9	1	2025-08-13 10:18:00	2025-08-13 10:50:00	1	1	246.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-13 11:13:00	\N	2025-09-07 12:51:46.615446	2025-09-07 12:51:46.623152			\N	1	0	0	1	\N	\N	\N
74	ORDER202508140071	5	8	1	2025-08-14 18:46:00	2025-08-14 19:23:00	2	1	447.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-14 19:57:00	\N	2025-09-07 12:51:46.62481	2025-09-07 12:51:46.631156			\N	1	0	0	1	\N	\N	\N
75	ORDER202508140072	5	10	1	2025-08-14 01:40:00	2025-08-14 02:15:00	2	1	149.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-14 02:44:00	\N	2025-09-07 12:51:46.632185	2025-09-07 12:51:46.638701			\N	1	0	0	1	\N	\N	\N
76	ORDER202508140073	5	9	1	2025-08-14 21:09:00	2025-08-14 21:23:00	1	1	277.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-14 22:18:00	\N	2025-09-07 12:51:46.639817	2025-09-07 12:51:46.647588			\N	1	0	0	1	\N	\N	\N
77	ORDER202508140074	5	8	1	2025-08-14 03:34:00	2025-08-14 03:54:00	1	1	194.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-14 04:52:00	\N	2025-09-07 12:51:46.649532	2025-09-07 12:51:46.6562			\N	1	0	0	1	\N	\N	\N
78	ORDER202508140075	5	10	1	2025-08-14 18:25:00	2025-08-14 18:40:00	1	1	228.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-14 19:02:00	\N	2025-09-07 12:51:46.657556	2025-09-07 12:51:46.665408			\N	1	0	0	1	\N	\N	\N
79	ORDER202508140076	4	10	1	2025-08-14 06:00:00	\N	1	1	268.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:46.667061	2025-09-07 12:51:46.673414			\N	1	0	0	1	\N	\N	\N
80	ORDER202508150077	5	9	1	2025-08-15 16:16:00	2025-08-15 16:37:00	2	1	442.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-15 17:25:00	\N	2025-09-07 12:51:46.67541	2025-09-07 12:51:46.684341			\N	1	0	0	1	\N	\N	\N
81	ORDER202508150078	5	9	1	2025-08-15 20:57:00	2025-08-15 21:09:00	1	1	36.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-15 21:52:00	\N	2025-09-07 12:51:46.685513	2025-09-07 12:51:46.688968			\N	1	0	0	1	\N	\N	\N
82	ORDER202508150079	6	9	1	2025-08-15 07:40:00	\N	1	2	28.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:46.690482	2025-09-07 12:51:46.693623			\N	1	0	0	1	\N	\N	\N
83	ORDER202508150080	5	10	1	2025-08-15 14:25:00	2025-08-15 14:41:00	1	1	98.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-15 15:18:00	\N	2025-09-07 12:51:46.695178	2025-09-07 12:51:46.701777			\N	1	0	0	1	\N	\N	\N
84	ORDER202508150081	5	8	1	2025-08-15 13:29:00	2025-08-15 13:53:00	2	1	441.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-15 14:26:00	\N	2025-09-07 12:51:46.704214	2025-09-07 12:51:46.712208			\N	1	0	0	1	\N	\N	\N
85	ORDER202508150082	5	9	1	2025-08-15 18:35:00	2025-08-15 18:45:00	1	1	38.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-15 19:11:00	\N	2025-09-07 12:51:46.714499	2025-09-07 12:51:46.71816			\N	1	0	0	1	\N	\N	\N
86	ORDER202508150083	5	8	1	2025-08-15 23:38:00	2025-08-15 23:54:00	2	1	128.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-16 00:20:00	\N	2025-09-07 12:51:46.720331	2025-09-07 12:51:46.729001			\N	1	0	0	1	\N	\N	\N
87	ORDER202508160084	5	9	1	2025-08-16 07:28:00	2025-08-16 07:58:00	1	1	268.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-16 08:19:00	\N	2025-09-07 12:51:46.730491	2025-09-07 12:51:46.739167			\N	1	0	0	1	\N	\N	\N
88	ORDER202508160085	5	10	1	2025-08-16 22:03:00	2025-08-16 22:37:00	2	1	76.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-16 23:36:00	\N	2025-09-07 12:51:46.741297	2025-09-07 12:51:46.745252			\N	1	0	0	1	\N	\N	\N
89	ORDER202508160086	5	9	1	2025-08-16 23:46:00	2025-08-17 00:21:00	1	1	105.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-17 01:12:00	\N	2025-09-07 12:51:46.747069	2025-09-07 12:51:46.750026			\N	1	0	0	1	\N	\N	\N
90	ORDER202508160087	5	8	1	2025-08-16 00:34:00	2025-08-16 01:08:00	2	1	56.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-16 01:43:00	\N	2025-09-07 12:51:46.750903	2025-09-07 12:51:46.754978			\N	1	0	0	1	\N	\N	\N
91	ORDER202508160088	5	8	1	2025-08-16 12:31:00	2025-08-16 13:00:00	2	1	189.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-16 13:55:00	\N	2025-09-07 12:51:46.757449	2025-09-07 12:51:46.764284			\N	1	0	0	1	\N	\N	\N
92	ORDER202508160089	5	9	1	2025-08-16 19:16:00	2025-08-16 19:33:00	2	1	341.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-16 20:27:00	\N	2025-09-07 12:51:46.766235	2025-09-07 12:51:46.775409			\N	1	0	0	1	\N	\N	\N
93	ORDER202508160090	5	8	1	2025-08-16 16:33:00	2025-08-16 16:49:00	2	1	246.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-16 17:19:00	\N	2025-09-07 12:51:46.776662	2025-09-07 12:51:46.786737			\N	1	0	0	1	\N	\N	\N
94	ORDER202508160091	5	10	1	2025-08-16 23:57:00	2025-08-17 00:28:00	2	1	70.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-17 01:21:00	\N	2025-09-07 12:51:46.788011	2025-09-07 12:51:46.791234			\N	1	0	0	1	\N	\N	\N
95	ORDER202508160092	5	9	1	2025-08-16 10:13:00	2025-08-16 10:25:00	2	1	209.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-16 10:45:00	\N	2025-09-07 12:51:46.792879	2025-09-07 12:51:46.798595			\N	1	0	0	1	\N	\N	\N
96	ORDER202508160093	5	8	1	2025-08-16 23:07:00	2025-08-16 23:20:00	2	1	38.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-16 23:59:00	\N	2025-09-07 12:51:46.800043	2025-09-07 12:51:46.805023			\N	1	0	0	1	\N	\N	\N
97	ORDER202508160094	5	9	1	2025-08-16 21:27:00	2025-08-16 22:00:00	1	1	132.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-16 22:38:00	\N	2025-09-07 12:51:46.806686	2025-09-07 12:51:46.811564			\N	1	0	0	1	\N	\N	\N
98	ORDER202508170095	5	8	1	2025-08-17 03:49:00	2025-08-17 04:22:00	2	1	152.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 05:17:00	\N	2025-09-07 12:51:46.813315	2025-09-07 12:51:46.819707			\N	1	0	0	1	\N	\N	\N
99	ORDER202508170096	5	8	1	2025-08-17 19:03:00	2025-08-17 19:32:00	1	1	106.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 20:05:00	\N	2025-09-07 12:51:46.821993	2025-09-07 12:51:46.827536			\N	1	0	0	1	\N	\N	\N
100	ORDER202508170097	5	10	1	2025-08-17 09:04:00	2025-08-17 09:42:00	2	1	116.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-17 10:08:00	\N	2025-09-07 12:51:46.829398	2025-09-07 12:51:46.833251			\N	1	0	0	1	\N	\N	\N
101	ORDER202508170098	5	8	1	2025-08-17 15:42:00	2025-08-17 15:53:00	2	1	58.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 16:17:00	\N	2025-09-07 12:51:46.835041	2025-09-07 12:51:46.838908			\N	1	0	0	1	\N	\N	\N
102	ORDER202508170099	5	8	1	2025-08-17 14:53:00	2025-08-17 15:26:00	1	1	334.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 16:00:00	\N	2025-09-07 12:51:46.840136	2025-09-07 12:51:46.850633			\N	1	0	0	1	\N	\N	\N
103	ORDER202508170100	5	8	1	2025-08-17 12:57:00	2025-08-17 13:10:00	1	1	389.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 13:55:00	\N	2025-09-07 12:51:46.852522	2025-09-07 12:51:46.861947			\N	1	0	0	1	\N	\N	\N
104	ORDER202508170101	5	8	1	2025-08-17 18:33:00	2025-08-17 19:02:00	2	1	276.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 19:51:00	\N	2025-09-07 12:51:46.864832	2025-09-07 12:51:46.87553			\N	1	0	0	1	\N	\N	\N
105	ORDER202508170102	5	10	1	2025-08-17 09:08:00	2025-08-17 09:23:00	2	1	284.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-17 10:11:00	\N	2025-09-07 12:51:46.877415	2025-09-07 12:51:46.885474			\N	1	0	0	1	\N	\N	\N
106	ORDER202508170103	5	8	1	2025-08-17 21:28:00	2025-08-17 21:43:00	1	1	186.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 22:18:00	\N	2025-09-07 12:51:46.88675	2025-09-07 12:51:46.892731			\N	1	0	0	1	\N	\N	\N
107	ORDER202508170104	5	8	1	2025-08-17 20:47:00	2025-08-17 21:05:00	2	1	56.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-17 21:56:00	\N	2025-09-07 12:51:46.895122	2025-09-07 12:51:46.898545			\N	1	0	0	1	\N	\N	\N
108	ORDER202508180105	5	10	1	2025-08-18 03:20:00	2025-08-18 03:55:00	1	1	198.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-18 04:30:00	\N	2025-09-07 12:51:46.900302	2025-09-07 12:51:46.908626			\N	1	0	0	1	\N	\N	\N
109	ORDER202508180106	5	9	1	2025-08-18 02:46:00	2025-08-18 03:20:00	2	1	246.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-18 04:14:00	\N	2025-09-07 12:51:46.910199	2025-09-07 12:51:46.918739			\N	1	0	0	1	\N	\N	\N
110	ORDER202508180107	5	9	1	2025-08-18 06:17:00	2025-08-18 06:27:00	1	1	56.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-18 07:24:00	\N	2025-09-07 12:51:46.920306	2025-09-07 12:51:46.925692			\N	1	0	0	1	\N	\N	\N
111	ORDER202508180108	5	8	1	2025-08-18 12:36:00	2025-08-18 13:11:00	2	1	258.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-18 13:56:00	\N	2025-09-07 12:51:46.927514	2025-09-07 12:51:46.934172			\N	1	0	0	1	\N	\N	\N
112	ORDER202508180109	5	9	1	2025-08-18 16:45:00	2025-08-18 17:02:00	1	1	76.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-18 17:42:00	\N	2025-09-07 12:51:46.935884	2025-09-07 12:51:46.939288			\N	1	0	0	1	\N	\N	\N
113	ORDER202508180110	5	8	1	2025-08-18 10:57:00	2025-08-18 11:24:00	1	1	205.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-18 11:49:00	\N	2025-09-07 12:51:46.940811	2025-09-07 12:51:46.949084			\N	1	0	0	1	\N	\N	\N
114	ORDER202508180111	6	9	1	2025-08-18 21:11:00	\N	1	2	180.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:46.950579	2025-09-07 12:51:46.958286			\N	1	0	0	1	\N	\N	\N
115	ORDER202508190112	5	10	1	2025-08-19 10:44:00	2025-08-19 11:11:00	2	1	35.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-19 11:32:00	\N	2025-09-07 12:51:46.96039	2025-09-07 12:51:46.964788			\N	1	0	0	1	\N	\N	\N
116	ORDER202508190113	5	10	1	2025-08-19 13:48:00	2025-08-19 14:26:00	2	1	112.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-19 15:17:00	\N	2025-09-07 12:51:46.965946	2025-09-07 12:51:46.971343			\N	1	0	0	1	\N	\N	\N
117	ORDER202508190114	5	8	1	2025-08-19 19:35:00	2025-08-19 19:46:00	2	1	56.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-19 20:40:00	\N	2025-09-07 12:51:46.973544	2025-09-07 12:51:46.97699			\N	1	0	0	1	\N	\N	\N
118	ORDER202508190115	5	10	1	2025-08-19 17:31:00	2025-08-19 18:09:00	1	1	54.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-19 18:33:00	\N	2025-09-07 12:51:46.979115	2025-09-07 12:51:46.982022			\N	1	0	0	1	\N	\N	\N
119	ORDER202508190116	5	8	1	2025-08-19 04:55:00	2025-08-19 05:33:00	1	1	243.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-19 06:31:00	\N	2025-09-07 12:51:46.984682	2025-09-07 12:51:46.996083			\N	1	0	0	1	\N	\N	\N
120	ORDER202508190117	5	10	1	2025-08-19 02:52:00	2025-08-19 03:06:00	2	1	74.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-19 03:34:00	\N	2025-09-07 12:51:46.99763	2025-09-07 12:51:47.004815			\N	1	0	0	1	\N	\N	\N
121	ORDER202508190118	5	9	1	2025-08-19 07:54:00	2025-08-19 08:10:00	2	1	56.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-19 08:58:00	\N	2025-09-07 12:51:47.006174	2025-09-07 12:51:47.010241			\N	1	0	0	1	\N	\N	\N
122	ORDER202508200119	5	10	1	2025-08-20 12:34:00	2025-08-20 13:12:00	2	1	198.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-20 13:49:00	\N	2025-09-07 12:51:47.012854	2025-09-07 12:51:47.01938			\N	1	0	0	1	\N	\N	\N
123	ORDER202508200120	5	9	1	2025-08-20 08:29:00	2025-08-20 08:52:00	1	1	228.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-20 09:12:00	\N	2025-09-07 12:51:47.021515	2025-09-07 12:51:47.032119			\N	1	0	0	1	\N	\N	\N
124	ORDER202508200121	5	10	1	2025-08-20 03:16:00	2025-08-20 03:51:00	2	1	255.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-20 04:13:00	\N	2025-09-07 12:51:47.034284	2025-09-07 12:51:47.040499			\N	1	0	0	1	\N	\N	\N
125	ORDER202508200122	5	9	1	2025-08-20 19:16:00	2025-08-20 19:38:00	1	1	155.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-20 20:31:00	\N	2025-09-07 12:51:47.042066	2025-09-07 12:51:47.050526			\N	1	0	0	1	\N	\N	\N
126	ORDER202508200123	5	9	1	2025-08-20 20:54:00	2025-08-20 21:26:00	1	1	226.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-20 22:13:00	\N	2025-09-07 12:51:47.052938	2025-09-07 12:51:47.063641			\N	1	0	0	1	\N	\N	\N
127	ORDER202508200124	5	9	1	2025-08-20 13:33:00	2025-08-20 13:58:00	2	1	246.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-20 14:21:00	\N	2025-09-07 12:51:47.06572	2025-09-07 12:51:47.076588			\N	1	0	0	1	\N	\N	\N
128	ORDER202508200125	5	10	1	2025-08-20 01:01:00	2025-08-20 01:30:00	2	1	154.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-20 02:25:00	\N	2025-09-07 12:51:47.078513	2025-09-07 12:51:47.086891			\N	1	0	0	1	\N	\N	\N
129	ORDER202508200126	5	10	1	2025-08-20 23:14:00	2025-08-20 23:39:00	2	1	89.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-21 00:34:00	\N	2025-09-07 12:51:47.088919	2025-09-07 12:51:47.097419			\N	1	0	0	1	\N	\N	\N
130	ORDER202508210127	5	9	1	2025-08-21 11:37:00	2025-08-21 11:51:00	2	1	439.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-21 12:46:00	\N	2025-09-07 12:51:47.100561	2025-09-07 12:51:47.11832			\N	1	0	0	1	\N	\N	\N
131	ORDER202508210128	5	8	1	2025-08-21 23:22:00	2025-08-22 00:00:00	1	1	288.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-22 00:57:00	\N	2025-09-07 12:51:47.120171	2025-09-07 12:51:47.127108			\N	1	0	0	1	\N	\N	\N
132	ORDER202508210129	3	10	1	2025-08-21 18:42:00	\N	1	1	76.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:47.128872	2025-09-07 12:51:47.132792			\N	1	0	0	1	\N	\N	\N
133	ORDER202508210130	5	9	1	2025-08-21 20:20:00	2025-08-21 20:54:00	2	1	74.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-21 21:26:00	\N	2025-09-07 12:51:47.134849	2025-09-07 12:51:47.14133			\N	1	0	0	1	\N	\N	\N
134	ORDER202508210131	5	9	1	2025-08-21 19:11:00	2025-08-21 19:47:00	2	1	288.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-21 20:19:00	\N	2025-09-07 12:51:47.143419	2025-09-07 12:51:47.14946			\N	1	0	0	1	\N	\N	\N
135	ORDER202508210132	5	10	1	2025-08-21 17:23:00	2025-08-21 17:50:00	1	1	28.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-21 18:15:00	\N	2025-09-07 12:51:47.151505	2025-09-07 12:51:47.15694			\N	1	0	0	1	\N	\N	\N
136	ORDER202508210133	5	9	1	2025-08-21 15:24:00	2025-08-21 15:44:00	2	1	314.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-21 16:37:00	\N	2025-09-07 12:51:47.1585	2025-09-07 12:51:47.169354			\N	1	0	0	1	\N	\N	\N
137	ORDER202508210134	5	10	1	2025-08-21 11:55:00	2025-08-21 12:34:00	2	1	407.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-21 13:09:00	\N	2025-09-07 12:51:47.17133	2025-09-07 12:51:47.181668			\N	1	0	0	1	\N	\N	\N
138	ORDER202508210135	5	8	1	2025-08-21 02:15:00	2025-08-21 02:47:00	1	1	267.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-21 03:22:00	\N	2025-09-07 12:51:47.184845	2025-09-07 12:51:47.193695			\N	1	0	0	1	\N	\N	\N
139	ORDER202508210136	5	8	1	2025-08-21 03:03:00	2025-08-21 03:28:00	2	1	317.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-21 03:58:00	\N	2025-09-07 12:51:47.195337	2025-09-07 12:51:47.206007			\N	1	0	0	1	\N	\N	\N
140	ORDER202508220137	5	10	1	2025-08-22 08:23:00	2025-08-22 08:52:00	1	1	38.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-22 09:12:00	\N	2025-09-07 12:51:47.207941	2025-09-07 12:51:47.215389			\N	1	0	0	1	\N	\N	\N
141	ORDER202508220138	6	8	1	2025-08-22 17:55:00	\N	2	2	339.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:47.217128	2025-09-07 12:51:47.226422			\N	1	0	0	1	\N	\N	\N
142	ORDER202508220139	5	9	1	2025-08-22 14:10:00	2025-08-22 14:21:00	1	1	130.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-22 14:58:00	\N	2025-09-07 12:51:47.229402	2025-09-07 12:51:47.239829			\N	1	0	0	1	\N	\N	\N
143	ORDER202508220140	5	10	1	2025-08-22 19:01:00	2025-08-22 19:13:00	1	1	250.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-22 19:58:00	\N	2025-09-07 12:51:47.24159	2025-09-07 12:51:47.248636			\N	1	0	0	1	\N	\N	\N
144	ORDER202508220141	5	10	1	2025-08-22 08:43:00	2025-08-22 09:00:00	2	1	124.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-22 09:21:00	\N	2025-09-07 12:51:47.249997	2025-09-07 12:51:47.255398			\N	1	0	0	1	\N	\N	\N
145	ORDER202508220142	5	10	1	2025-08-22 00:55:00	2025-08-22 01:05:00	2	1	179.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-22 01:55:00	\N	2025-09-07 12:51:47.25712	2025-09-07 12:51:47.264463			\N	1	0	0	1	\N	\N	\N
146	ORDER202508220143	5	9	1	2025-08-22 09:36:00	2025-08-22 10:10:00	2	1	186.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-22 10:55:00	\N	2025-09-07 12:51:47.265742	2025-09-07 12:51:47.271303			\N	1	0	0	1	\N	\N	\N
147	ORDER202508220144	5	10	1	2025-08-22 06:52:00	2025-08-22 07:19:00	2	1	174.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-22 08:15:00	\N	2025-09-07 12:51:47.273171	2025-09-07 12:51:47.277898			\N	1	0	0	1	\N	\N	\N
148	ORDER202508220145	5	9	1	2025-08-22 15:25:00	2025-08-22 15:53:00	2	1	99.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-22 16:35:00	\N	2025-09-07 12:51:47.279075	2025-09-07 12:51:47.286108			\N	1	0	0	1	\N	\N	\N
149	ORDER202508220146	6	8	1	2025-08-22 23:05:00	\N	2	2	315.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:47.287772	2025-09-07 12:51:47.29601			\N	1	0	0	1	\N	\N	\N
150	ORDER202508230147	5	9	1	2025-08-23 16:55:00	2025-08-23 17:06:00	1	1	210.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-23 17:45:00	\N	2025-09-07 12:51:47.297636	2025-09-07 12:51:47.302189			\N	1	0	0	1	\N	\N	\N
151	ORDER202508230148	5	10	1	2025-08-23 19:17:00	2025-08-23 19:52:00	1	1	221.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-23 20:29:00	\N	2025-09-07 12:51:47.303441	2025-09-07 12:51:47.308906			\N	1	0	0	1	\N	\N	\N
152	ORDER202508230149	5	8	1	2025-08-23 19:11:00	2025-08-23 19:45:00	1	1	125.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 20:17:00	\N	2025-09-07 12:51:47.309804	2025-09-07 12:51:47.316442			\N	1	0	0	1	\N	\N	\N
153	ORDER202508230150	5	8	1	2025-08-23 04:15:00	2025-08-23 04:45:00	1	1	112.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 05:24:00	\N	2025-09-07 12:51:47.317641	2025-09-07 12:51:47.324605			\N	1	0	0	1	\N	\N	\N
154	ORDER202508230151	5	8	1	2025-08-23 16:11:00	2025-08-23 16:32:00	2	1	18.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 17:00:00	\N	2025-09-07 12:51:47.326495	2025-09-07 12:51:47.330319			\N	1	0	0	1	\N	\N	\N
155	ORDER202508230152	5	8	1	2025-08-23 12:23:00	2025-08-23 12:42:00	1	1	197.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 13:04:00	\N	2025-09-07 12:51:47.332315	2025-09-07 12:51:47.340357			\N	1	0	0	1	\N	\N	\N
156	ORDER202508230153	5	8	1	2025-08-23 20:40:00	2025-08-23 20:50:00	2	1	38.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 21:48:00	\N	2025-09-07 12:51:47.342109	2025-09-07 12:51:47.34694			\N	1	0	0	1	\N	\N	\N
157	ORDER202508230154	5	10	1	2025-08-23 19:35:00	2025-08-23 20:03:00	1	1	288.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-23 21:00:00	\N	2025-09-07 12:51:47.347968	2025-09-07 12:51:47.354597			\N	1	0	0	1	\N	\N	\N
158	ORDER202508230155	6	9	1	2025-08-23 07:28:00	\N	2	2	105.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:47.356391	2025-09-07 12:51:47.36133			\N	1	0	0	1	\N	\N	\N
159	ORDER202508230156	5	8	1	2025-08-23 20:05:00	2025-08-23 20:25:00	2	1	199.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-23 21:19:00	\N	2025-09-07 12:51:47.363609	2025-09-07 12:51:47.374387			\N	1	0	0	1	\N	\N	\N
160	ORDER202508230157	1	10	1	2025-08-23 10:09:00	\N	2	1	168.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:47.37576	2025-09-07 12:51:47.38411			\N	1	0	0	1	\N	\N	\N
161	ORDER202508230158	5	9	1	2025-08-23 20:00:00	2025-08-23 20:32:00	2	1	114.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-23 20:54:00	\N	2025-09-07 12:51:47.386025	2025-09-07 12:51:47.390572			\N	1	0	0	1	\N	\N	\N
162	ORDER202508230159	5	9	1	2025-08-23 07:50:00	2025-08-23 08:03:00	1	1	140.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-23 08:34:00	\N	2025-09-07 12:51:47.391487	2025-09-07 12:51:47.399779			\N	1	0	0	1	\N	\N	\N
163	ORDER202508230160	5	10	1	2025-08-23 00:28:00	2025-08-23 00:54:00	2	1	94.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-23 01:51:00	\N	2025-09-07 12:51:47.401507	2025-09-07 12:51:47.408937			\N	1	0	0	1	\N	\N	\N
164	ORDER202508240161	5	8	1	2025-08-24 22:48:00	2025-08-24 23:18:00	1	1	209.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-25 00:02:00	\N	2025-09-07 12:51:47.41081	2025-09-07 12:51:47.417823			\N	1	0	0	1	\N	\N	\N
165	ORDER202508240162	5	10	1	2025-08-24 18:01:00	2025-08-24 18:32:00	2	1	152.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-24 19:13:00	\N	2025-09-07 12:51:47.418745	2025-09-07 12:51:47.427338			\N	1	0	0	1	\N	\N	\N
166	ORDER202508240163	5	8	1	2025-08-24 05:53:00	2025-08-24 06:04:00	1	1	219.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 06:36:00	\N	2025-09-07 12:51:47.428697	2025-09-07 12:51:47.435097			\N	1	0	0	1	\N	\N	\N
167	ORDER202508240164	5	9	1	2025-08-24 22:01:00	2025-08-24 22:15:00	2	1	104.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-24 22:47:00	\N	2025-09-07 12:51:47.436706	2025-09-07 12:51:47.443591			\N	1	0	0	1	\N	\N	\N
168	ORDER202508240165	5	9	1	2025-08-24 21:35:00	2025-08-24 22:06:00	1	1	349.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-24 23:00:00	\N	2025-09-07 12:51:47.445885	2025-09-07 12:51:47.454344			\N	1	0	0	1	\N	\N	\N
169	ORDER202508240166	5	8	1	2025-08-24 14:41:00	2025-08-24 15:05:00	1	1	54.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 15:42:00	\N	2025-09-07 12:51:47.455901	2025-09-07 12:51:47.459176			\N	1	0	0	1	\N	\N	\N
170	ORDER202508240167	5	9	1	2025-08-24 18:22:00	2025-08-24 19:01:00	1	1	174.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-24 19:22:00	\N	2025-09-07 12:51:47.460421	2025-09-07 12:51:47.464313			\N	1	0	0	1	\N	\N	\N
171	ORDER202508240168	5	8	1	2025-08-24 05:36:00	2025-08-24 06:13:00	2	1	414.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 06:44:00	\N	2025-09-07 12:51:47.465669	2025-09-07 12:51:47.474527			\N	1	0	0	1	\N	\N	\N
172	ORDER202508240169	5	8	1	2025-08-24 10:37:00	2025-08-24 10:58:00	1	1	164.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 11:30:00	\N	2025-09-07 12:51:47.476804	2025-09-07 12:51:47.482983			\N	1	0	0	1	\N	\N	\N
173	ORDER202508240170	5	8	1	2025-08-24 11:46:00	2025-08-24 12:04:00	1	1	236.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 12:27:00	\N	2025-09-07 12:51:47.485032	2025-09-07 12:51:47.491003			\N	1	0	0	1	\N	\N	\N
174	ORDER202508240171	5	10	1	2025-08-24 06:21:00	2025-08-24 06:36:00	2	1	98.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-24 07:31:00	\N	2025-09-07 12:51:47.492535	2025-09-07 12:51:47.498316			\N	1	0	0	1	\N	\N	\N
175	ORDER202508240172	5	8	1	2025-08-24 21:11:00	2025-08-24 21:23:00	1	1	54.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-24 21:56:00	\N	2025-09-07 12:51:47.499913	2025-09-07 12:51:47.504265			\N	1	0	0	1	\N	\N	\N
176	ORDER202508240173	6	10	1	2025-08-24 03:32:00	\N	2	2	197.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:47.506273	2025-09-07 12:51:47.515986			\N	1	0	0	1	\N	\N	\N
177	ORDER202508250174	1	8	1	2025-08-25 10:46:00	\N	1	1	182.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:47.517785	2025-09-07 12:51:47.527368			\N	1	0	0	1	\N	\N	\N
178	ORDER202508250175	6	8	1	2025-08-25 06:16:00	\N	2	2	373.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:47.528715	2025-09-07 12:51:47.540369			\N	1	0	0	1	\N	\N	\N
179	ORDER202508250176	5	10	1	2025-08-25 22:31:00	2025-08-25 23:07:00	2	1	70.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-25 23:44:00	\N	2025-09-07 12:51:47.543046	2025-09-07 12:51:47.547646			\N	1	0	0	1	\N	\N	\N
180	ORDER202508250177	5	10	1	2025-08-25 02:51:00	2025-08-25 03:30:00	2	1	56.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-25 04:11:00	\N	2025-09-07 12:51:47.548845	2025-09-07 12:51:47.554559			\N	1	0	0	1	\N	\N	\N
181	ORDER202508250178	5	10	1	2025-08-25 02:28:00	2025-08-25 02:40:00	1	1	112.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-25 03:33:00	\N	2025-09-07 12:51:47.556442	2025-09-07 12:51:47.561803			\N	1	0	0	1	\N	\N	\N
182	ORDER202508260179	5	9	1	2025-08-26 04:36:00	2025-08-26 04:46:00	2	1	257.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 05:21:00	\N	2025-09-07 12:51:47.56507	2025-09-07 12:51:47.571909			\N	1	0	0	1	\N	\N	\N
183	ORDER202508260180	5	10	1	2025-08-26 06:21:00	2025-08-26 06:54:00	2	1	130.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-26 07:50:00	\N	2025-09-07 12:51:47.57512	2025-09-07 12:51:47.581159			\N	1	0	0	1	\N	\N	\N
184	ORDER202508260181	5	10	1	2025-08-26 16:59:00	2025-08-26 17:19:00	1	1	411.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-26 18:03:00	\N	2025-09-07 12:51:47.583205	2025-09-07 12:51:47.591042			\N	1	0	0	1	\N	\N	\N
185	ORDER202508260182	5	8	1	2025-08-26 22:49:00	2025-08-26 23:23:00	2	1	200.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-26 23:54:00	\N	2025-09-07 12:51:47.592738	2025-09-07 12:51:47.603396			\N	1	0	0	1	\N	\N	\N
186	ORDER202508260183	5	9	1	2025-08-26 19:23:00	2025-08-26 19:40:00	1	1	56.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 20:26:00	\N	2025-09-07 12:51:47.605073	2025-09-07 12:51:47.608425			\N	1	0	0	1	\N	\N	\N
187	ORDER202508260184	5	9	1	2025-08-26 22:07:00	2025-08-26 22:30:00	1	1	150.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 23:28:00	\N	2025-09-07 12:51:47.609641	2025-09-07 12:51:47.61532			\N	1	0	0	1	\N	\N	\N
188	ORDER202508260185	5	9	1	2025-08-26 13:18:00	2025-08-26 13:55:00	2	1	76.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 14:29:00	\N	2025-09-07 12:51:47.61719	2025-09-07 12:51:47.62024			\N	1	0	0	1	\N	\N	\N
189	ORDER202508260186	5	10	1	2025-08-26 07:54:00	2025-08-26 08:11:00	1	1	210.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-26 08:48:00	\N	2025-09-07 12:51:47.621344	2025-09-07 12:51:47.628698			\N	1	0	0	1	\N	\N	\N
190	ORDER202508260187	5	10	1	2025-08-26 18:27:00	2025-08-26 18:45:00	1	1	54.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-26 19:11:00	\N	2025-09-07 12:51:47.630503	2025-09-07 12:51:47.634001			\N	1	0	0	1	\N	\N	\N
191	ORDER202508260188	5	10	1	2025-08-26 12:26:00	2025-08-26 12:56:00	1	1	224.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-26 13:43:00	\N	2025-09-07 12:51:47.635099	2025-09-07 12:51:47.643556			\N	1	0	0	1	\N	\N	\N
192	ORDER202508260189	4	8	1	2025-08-26 04:33:00	\N	2	1	295.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:47.645252	2025-09-07 12:51:47.650323			\N	1	0	0	1	\N	\N	\N
193	ORDER202508260190	5	9	1	2025-08-26 04:23:00	2025-08-26 04:33:00	2	1	308.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 05:00:00	\N	2025-09-07 12:51:47.651504	2025-09-07 12:51:47.658523			\N	1	0	0	1	\N	\N	\N
194	ORDER202508260191	5	9	1	2025-08-26 09:13:00	2025-08-26 09:52:00	1	1	56.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-26 10:43:00	\N	2025-09-07 12:51:47.66001	2025-09-07 12:51:47.663999			\N	1	0	0	1	\N	\N	\N
195	ORDER202508270192	5	9	1	2025-08-27 04:49:00	2025-08-27 05:03:00	1	1	112.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-27 05:59:00	\N	2025-09-07 12:51:47.665157	2025-09-07 12:51:47.669474			\N	1	0	0	1	\N	\N	\N
196	ORDER202508270193	6	10	1	2025-08-27 20:03:00	\N	2	2	219.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:47.670389	2025-09-07 12:51:47.676571			\N	1	0	0	1	\N	\N	\N
197	ORDER202508270194	5	8	1	2025-08-27 03:57:00	2025-08-27 04:23:00	1	1	242.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 05:15:00	\N	2025-09-07 12:51:47.678082	2025-09-07 12:51:47.684254			\N	1	0	0	1	\N	\N	\N
198	ORDER202508270195	5	8	1	2025-08-27 04:55:00	2025-08-27 05:34:00	2	1	36.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 06:05:00	\N	2025-09-07 12:51:47.685461	2025-09-07 12:51:47.688517			\N	1	0	0	1	\N	\N	\N
199	ORDER202508270196	5	8	1	2025-08-27 09:44:00	2025-08-27 10:23:00	2	1	72.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 11:11:00	\N	2025-09-07 12:51:47.689866	2025-09-07 12:51:47.695405			\N	1	0	0	1	\N	\N	\N
200	ORDER202508270197	5	8	1	2025-08-27 04:07:00	2025-08-27 04:44:00	1	1	174.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 05:34:00	\N	2025-09-07 12:51:47.696775	2025-09-07 12:51:47.699338			\N	1	0	0	1	\N	\N	\N
201	ORDER202508270198	5	8	1	2025-08-27 19:15:00	2025-08-27 19:44:00	2	1	132.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 20:32:00	\N	2025-09-07 12:51:47.700513	2025-09-07 12:51:47.708435			\N	1	0	0	1	\N	\N	\N
202	ORDER202508270199	5	8	1	2025-08-27 01:10:00	2025-08-27 01:33:00	2	1	180.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 01:59:00	\N	2025-09-07 12:51:47.709796	2025-09-07 12:51:47.71602			\N	1	0	0	1	\N	\N	\N
203	ORDER202508270200	5	10	1	2025-08-27 20:07:00	2025-08-27 20:26:00	2	1	263.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-27 20:48:00	\N	2025-09-07 12:51:47.718211	2025-09-07 12:51:47.724629			\N	1	0	0	1	\N	\N	\N
204	ORDER202508270201	5	10	1	2025-08-27 04:09:00	2025-08-27 04:48:00	2	1	110.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-27 05:42:00	\N	2025-09-07 12:51:47.72579	2025-09-07 12:51:47.73147			\N	1	0	0	1	\N	\N	\N
205	ORDER202508270202	5	8	1	2025-08-27 10:05:00	2025-08-27 10:43:00	2	1	333.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 11:03:00	\N	2025-09-07 12:51:47.73375	2025-09-07 12:51:47.741046			\N	1	0	0	1	\N	\N	\N
206	ORDER202508270203	5	10	1	2025-08-27 18:01:00	2025-08-27 18:24:00	1	1	219.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-27 18:57:00	\N	2025-09-07 12:51:47.742102	2025-09-07 12:51:47.748668			\N	1	0	0	1	\N	\N	\N
207	ORDER202508270204	5	9	1	2025-08-27 05:51:00	2025-08-27 06:02:00	2	1	258.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-27 07:01:00	\N	2025-09-07 12:51:47.749382	2025-09-07 12:51:47.753078			\N	1	0	0	1	\N	\N	\N
208	ORDER202508270205	5	9	1	2025-08-27 03:54:00	2025-08-27 04:08:00	1	1	370.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-27 04:43:00	\N	2025-09-07 12:51:47.754354	2025-09-07 12:51:47.761079			\N	1	0	0	1	\N	\N	\N
209	ORDER202508270206	5	8	1	2025-08-27 04:00:00	2025-08-27 04:34:00	1	1	304.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-27 05:04:00	\N	2025-09-07 12:51:47.762194	2025-09-07 12:51:47.769859			\N	1	0	0	1	\N	\N	\N
210	ORDER202508280207	5	10	1	2025-08-28 16:25:00	2025-08-28 16:52:00	2	1	213.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-28 17:37:00	\N	2025-09-07 12:51:47.7708	2025-09-07 12:51:47.778276			\N	1	0	0	1	\N	\N	\N
211	ORDER202508280208	5	10	1	2025-08-28 09:37:00	2025-08-28 10:14:00	1	1	184.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-28 11:06:00	\N	2025-09-07 12:51:47.780283	2025-09-07 12:51:47.786876			\N	1	0	0	1	\N	\N	\N
212	ORDER202508280209	5	9	1	2025-08-28 10:43:00	2025-08-28 11:16:00	2	1	142.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-28 11:45:00	\N	2025-09-07 12:51:47.787959	2025-09-07 12:51:47.794405			\N	1	0	0	1	\N	\N	\N
213	ORDER202508280210	5	10	1	2025-08-28 15:49:00	2025-08-28 16:07:00	2	1	334.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-28 16:32:00	\N	2025-09-07 12:51:47.795704	2025-09-07 12:51:47.803332			\N	1	0	0	1	\N	\N	\N
214	ORDER202508280211	5	8	1	2025-08-28 05:37:00	2025-08-28 05:48:00	2	1	172.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-28 06:10:00	\N	2025-09-07 12:51:47.80477	2025-09-07 12:51:47.811551			\N	1	0	0	1	\N	\N	\N
215	ORDER202508280212	5	8	1	2025-08-28 13:33:00	2025-08-28 14:06:00	2	1	46.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-28 14:53:00	\N	2025-09-07 12:51:47.813999	2025-09-07 12:51:47.819037			\N	1	0	0	1	\N	\N	\N
216	ORDER202508280213	4	9	1	2025-08-28 16:43:00	\N	1	1	224.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:47.820436	2025-09-07 12:51:47.827719			\N	1	0	0	1	\N	\N	\N
217	ORDER202508280214	5	9	1	2025-08-28 06:31:00	2025-08-28 06:48:00	1	1	175.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-28 07:46:00	\N	2025-09-07 12:51:47.829213	2025-09-07 12:51:47.833494			\N	1	0	0	1	\N	\N	\N
218	ORDER202508280215	5	8	1	2025-08-28 22:22:00	2025-08-28 22:52:00	1	1	114.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-28 23:13:00	\N	2025-09-07 12:51:47.835443	2025-09-07 12:51:47.838804			\N	1	0	0	1	\N	\N	\N
219	ORDER202508280216	5	10	1	2025-08-28 15:43:00	2025-08-28 16:17:00	1	1	169.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-28 17:16:00	\N	2025-09-07 12:51:47.840486	2025-09-07 12:51:47.849104			\N	1	0	0	1	\N	\N	\N
220	ORDER202508280217	5	9	1	2025-08-28 18:47:00	2025-08-28 19:00:00	1	1	235.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-28 19:40:00	\N	2025-09-07 12:51:47.849899	2025-09-07 12:51:47.857968			\N	1	0	0	1	\N	\N	\N
221	ORDER202508280218	5	9	1	2025-08-28 16:36:00	2025-08-28 17:06:00	2	1	152.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-28 17:32:00	\N	2025-09-07 12:51:47.858807	2025-09-07 12:51:47.863929			\N	1	0	0	1	\N	\N	\N
222	ORDER202508280219	5	8	1	2025-08-28 07:26:00	2025-08-28 07:52:00	1	1	314.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-28 08:30:00	\N	2025-09-07 12:51:47.865723	2025-09-07 12:51:47.871607			\N	1	0	0	1	\N	\N	\N
223	ORDER202508280220	5	9	1	2025-08-28 20:46:00	2025-08-28 20:56:00	2	1	164.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-28 21:18:00	\N	2025-09-07 12:51:47.87346	2025-09-07 12:51:47.880252			\N	1	0	0	1	\N	\N	\N
224	ORDER202508290221	5	9	1	2025-08-29 20:44:00	2025-08-29 21:12:00	1	1	116.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-29 21:56:00	\N	2025-09-07 12:51:47.881224	2025-09-07 12:51:47.884395			\N	1	0	0	1	\N	\N	\N
225	ORDER202508290222	5	9	1	2025-08-29 04:42:00	2025-08-29 05:11:00	2	1	105.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-29 06:05:00	\N	2025-09-07 12:51:47.886691	2025-09-07 12:51:47.890022			\N	1	0	0	1	\N	\N	\N
226	ORDER202508290223	5	10	1	2025-08-29 20:34:00	2025-08-29 21:01:00	1	1	348.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-29 21:52:00	\N	2025-09-07 12:51:47.891407	2025-09-07 12:51:47.900003			\N	1	0	0	1	\N	\N	\N
227	ORDER202508290224	6	10	1	2025-08-29 17:31:00	\N	1	2	98.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:47.901195	2025-09-07 12:51:47.908			\N	1	0	0	1	\N	\N	\N
228	ORDER202508290225	4	9	1	2025-08-29 14:28:00	\N	2	1	166.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	\N	\N	2025-09-07 12:51:47.909212	2025-09-07 12:51:47.91542			\N	1	0	0	1	\N	\N	\N
229	ORDER202508290226	5	8	1	2025-08-29 02:28:00	2025-08-29 02:45:00	1	1	296.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-29 03:34:00	\N	2025-09-07 12:51:47.917682	2025-09-07 12:51:47.926343			\N	1	0	0	1	\N	\N	\N
230	ORDER202508290227	5	8	1	2025-08-29 04:44:00	2025-08-29 05:09:00	2	1	133.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-29 05:51:00	\N	2025-09-07 12:51:47.927581	2025-09-07 12:51:47.932342			\N	1	0	0	1	\N	\N	\N
231	ORDER202508290228	5	10	1	2025-08-29 01:56:00	2025-08-29 02:26:00	1	1	81.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-29 02:49:00	\N	2025-09-07 12:51:47.934442	2025-09-07 12:51:47.940443			\N	1	0	0	1	\N	\N	\N
232	ORDER202508290229	5	9	1	2025-08-29 00:11:00	2025-08-29 00:28:00	1	1	274.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-29 00:48:00	\N	2025-09-07 12:51:47.941327	2025-09-07 12:51:47.949513			\N	1	0	0	1	\N	\N	\N
233	ORDER202508290230	5	10	1	2025-08-29 05:47:00	2025-08-29 06:24:00	2	1	379.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-29 06:52:00	\N	2025-09-07 12:51:47.95038	2025-09-07 12:51:47.959333			\N	1	0	0	1	\N	\N	\N
234	ORDER202508290231	5	9	1	2025-08-29 20:41:00	2025-08-29 21:17:00	1	1	114.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-29 21:43:00	\N	2025-09-07 12:51:47.960168	2025-09-07 12:51:47.96423			\N	1	0	0	1	\N	\N	\N
235	ORDER202508300232	5	9	1	2025-08-30 11:14:00	2025-08-30 11:42:00	2	1	318.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-30 12:23:00	\N	2025-09-07 12:51:47.965483	2025-09-07 12:51:47.971538			\N	1	0	0	1	\N	\N	\N
236	ORDER202508300233	5	9	1	2025-08-30 01:16:00	2025-08-30 01:55:00	2	1	35.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-30 02:27:00	\N	2025-09-07 12:51:47.973077	2025-09-07 12:51:47.977281			\N	1	0	0	1	\N	\N	\N
237	ORDER202508300234	5	10	1	2025-08-30 15:53:00	2025-08-30 16:06:00	1	1	316.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-30 16:32:00	\N	2025-09-07 12:51:47.979065	2025-09-07 12:51:47.985461			\N	1	0	0	1	\N	\N	\N
238	ORDER202508300235	5	10	1	2025-08-30 08:56:00	2025-08-30 09:12:00	1	1	28.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-30 09:55:00	\N	2025-09-07 12:51:47.987009	2025-09-07 12:51:47.989923			\N	1	0	0	1	\N	\N	\N
239	ORDER202508300236	5	9	1	2025-08-30 11:30:00	2025-08-30 11:43:00	1	1	28.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-30 12:42:00	\N	2025-09-07 12:51:47.99076	2025-09-07 12:51:47.995431			\N	1	0	0	1	\N	\N	\N
240	ORDER202508300237	5	9	1	2025-08-30 20:18:00	2025-08-30 20:45:00	2	1	38.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-30 21:23:00	\N	2025-09-07 12:51:47.996972	2025-09-07 12:51:48.00073			\N	1	0	0	1	\N	\N	\N
241	ORDER202508300238	5	8	1	2025-08-30 02:04:00	2025-08-30 02:40:00	2	1	268.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-30 03:09:00	\N	2025-09-07 12:51:48.002341	2025-09-07 12:51:48.009398			\N	1	0	0	1	\N	\N	\N
242	ORDER202508300239	5	9	1	2025-08-30 07:17:00	2025-08-30 07:50:00	2	1	149.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-30 08:38:00	\N	2025-09-07 12:51:48.010523	2025-09-07 12:51:48.015842			\N	1	0	0	1	\N	\N	\N
243	ORDER202508300240	5	10	1	2025-08-30 08:38:00	2025-08-30 08:58:00	2	1	358.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-30 09:43:00	\N	2025-09-07 12:51:48.016804	2025-09-07 12:51:48.025057			\N	1	0	0	1	\N	\N	\N
245	ORDER202508310242	5	9	1	2025-08-31 07:55:00	2025-08-31 08:16:00	1	1	274.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-31 09:13:00	\N	2025-09-07 12:51:48.030909	2025-09-07 12:51:48.038404			\N	1	0	0	1	\N	\N	\N
246	ORDER202508310243	5	9	1	2025-08-31 01:14:00	2025-08-31 01:45:00	2	1	105.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-31 02:34:00	\N	2025-09-07 12:51:48.039849	2025-09-07 12:51:48.043693			\N	1	0	0	1	\N	\N	\N
247	ORDER202508310244	5	9	1	2025-08-31 21:12:00	2025-08-31 21:36:00	2	1	250.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-31 22:14:00	\N	2025-09-07 12:51:48.045835	2025-09-07 12:51:48.051734			\N	1	0	0	1	\N	\N	\N
248	ORDER202508310245	5	10	1	2025-08-31 13:02:00	2025-08-31 13:23:00	1	1	72.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-31 13:46:00	\N	2025-09-07 12:51:48.052845	2025-09-07 12:51:48.059072			\N	1	0	0	1	\N	\N	\N
249	ORDER202508310246	5	8	1	2025-08-31 02:37:00	2025-08-31 03:12:00	2	1	70.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-31 03:46:00	\N	2025-09-07 12:51:48.06029	2025-09-07 12:51:48.063584			\N	1	0	0	1	\N	\N	\N
250	ORDER202508310247	5	8	1	2025-08-31 19:34:00	2025-08-31 20:05:00	1	1	36.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-31 20:51:00	\N	2025-09-07 12:51:48.065611	2025-09-07 12:51:48.069454			\N	1	0	0	1	\N	\N	\N
251	ORDER202508310248	5	8	1	2025-08-31 02:50:00	2025-08-31 03:07:00	1	1	54.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-31 03:54:00	\N	2025-09-07 12:51:48.070889	2025-09-07 12:51:48.076196			\N	1	0	0	1	\N	\N	\N
252	ORDER202508310249	5	10	1	2025-08-31 18:32:00	2025-08-31 18:44:00	2	1	35.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-31 19:35:00	\N	2025-09-07 12:51:48.077903	2025-09-07 12:51:48.08129			\N	1	0	0	1	\N	\N	\N
253	ORDER202508310250	5	10	1	2025-08-31 18:37:00	2025-08-31 18:51:00	1	1	56.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-31 19:43:00	\N	2025-09-07 12:51:48.082752	2025-09-07 12:51:48.087326			\N	1	0	0	1	\N	\N	\N
254	ORDER202508310251	5	10	1	2025-08-31 05:52:00	2025-08-31 06:05:00	2	1	124.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-31 06:34:00	\N	2025-09-07 12:51:48.088198	2025-09-07 12:51:48.092744			\N	1	0	0	1	\N	\N	\N
255	ORDER202508310252	5	9	1	2025-08-31 19:15:00	2025-08-31 19:35:00	2	1	144.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-08-31 20:19:00	\N	2025-09-07 12:51:48.094233	2025-09-07 12:51:48.102654			\N	1	0	0	1	\N	\N	\N
256	ORDER202508310253	5	8	1	2025-08-31 07:03:00	2025-08-31 07:20:00	1	1	214.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-31 08:13:00	\N	2025-09-07 12:51:48.104512	2025-09-07 12:51:48.112768			\N	1	0	0	1	\N	\N	\N
257	ORDER202508310254	5	10	1	2025-08-31 22:08:00	2025-08-31 22:37:00	2	1	116.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-08-31 23:28:00	\N	2025-09-07 12:51:48.115908	2025-09-07 12:51:48.119158			\N	1	0	0	1	\N	\N	\N
258	ORDER202508310255	5	8	1	2025-08-31 07:33:00	2025-08-31 07:54:00	1	1	116.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-08-31 08:32:00	\N	2025-09-07 12:51:48.120961	2025-09-07 12:51:48.124653			\N	1	0	0	1	\N	\N	\N
259	ORDER202509010256	5	8	1	2025-09-01 23:04:00	2025-09-01 23:15:00	1	1	400.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-01 23:40:00	\N	2025-09-07 12:51:48.125664	2025-09-07 12:51:48.133936			\N	1	0	0	1	\N	\N	\N
244	ORDER202508310241	5	9	1	2025-08-31 15:47:00	\N	1	1	58.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-10 13:38:54.8425	\N	2025-09-07 12:51:48.026885	2025-09-10 13:38:54.843046			\N	1	0	0	1	\N	\N	\N
260	ORDER202509010257	5	9	1	2025-09-01 20:01:00	2025-09-01 20:24:00	1	1	230.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-01 21:04:00	\N	2025-09-07 12:51:48.135506	2025-09-07 12:51:48.143959			\N	1	0	0	1	\N	\N	\N
261	ORDER202509010258	5	9	1	2025-09-01 06:32:00	2025-09-01 07:09:00	1	1	84.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-01 07:42:00	\N	2025-09-07 12:51:48.145197	2025-09-07 12:51:48.147975			\N	1	0	0	1	\N	\N	\N
262	ORDER202509010259	5	8	1	2025-09-01 12:44:00	2025-09-01 13:16:00	1	1	363.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-01 13:53:00	\N	2025-09-07 12:51:48.149408	2025-09-07 12:51:48.157567			\N	1	0	0	1	\N	\N	\N
263	ORDER202509010260	5	8	1	2025-09-01 19:59:00	2025-09-01 20:31:00	2	1	174.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-01 21:11:00	\N	2025-09-07 12:51:48.161994	2025-09-07 12:51:48.16714			\N	1	0	0	1	\N	\N	\N
264	ORDER202509010261	5	9	1	2025-09-01 01:35:00	2025-09-01 02:08:00	2	1	288.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-01 02:48:00	\N	2025-09-07 12:51:48.168337	2025-09-07 12:51:48.176883			\N	1	0	0	1	\N	\N	\N
265	ORDER202509010262	5	8	1	2025-09-01 09:09:00	2025-09-01 09:43:00	2	1	64.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-01 10:27:00	\N	2025-09-07 12:51:48.180664	2025-09-07 12:51:48.204582			\N	1	0	0	1	\N	\N	\N
266	ORDER202509010263	5	10	1	2025-09-01 07:49:00	2025-09-01 08:16:00	1	1	185.00	少放辣椒	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-01 08:56:00	\N	2025-09-07 12:51:48.20612	2025-09-07 12:51:48.211798			\N	1	0	0	1	\N	\N	\N
267	ORDER202509020264	5	10	1	2025-09-02 06:27:00	2025-09-02 07:01:00	1	1	255.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-02 07:55:00	\N	2025-09-07 12:51:48.213448	2025-09-07 12:51:48.226541			\N	1	0	0	1	\N	\N	\N
268	ORDER202509020265	5	10	1	2025-09-02 05:03:00	2025-09-02 05:39:00	2	1	366.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-02 06:04:00	\N	2025-09-07 12:51:48.228602	2025-09-07 12:51:48.24095			\N	1	0	0	1	\N	\N	\N
269	ORDER202509020266	6	8	1	2025-09-02 08:00:00	\N	2	2	243.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:48.243081	2025-09-07 12:51:48.255569			\N	1	0	0	1	\N	\N	\N
270	ORDER202509020267	5	10	1	2025-09-02 23:05:00	2025-09-02 23:26:00	2	1	132.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-03 00:13:00	\N	2025-09-07 12:51:48.257245	2025-09-07 12:51:48.267989			\N	1	0	0	1	\N	\N	\N
271	ORDER202509020268	5	8	1	2025-09-02 20:45:00	2025-09-02 21:09:00	1	1	159.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-02 21:54:00	\N	2025-09-07 12:51:48.270191	2025-09-07 12:51:48.27738			\N	1	0	0	1	\N	\N	\N
272	ORDER202509020269	5	10	1	2025-09-02 07:03:00	2025-09-02 07:13:00	2	1	387.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-02 08:07:00	\N	2025-09-07 12:51:48.279789	2025-09-07 12:51:48.289979			\N	1	0	0	1	\N	\N	\N
273	ORDER202509020270	5	8	1	2025-09-02 02:20:00	2025-09-02 02:46:00	1	1	444.00	少放辣椒	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-02 03:41:00	\N	2025-09-07 12:51:48.291243	2025-09-07 12:51:48.301508			\N	1	0	0	1	\N	\N	\N
274	ORDER202509030271	5	9	1	2025-09-03 04:00:00	2025-09-03 04:38:00	2	1	308.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 05:19:00	\N	2025-09-07 12:51:48.303485	2025-09-07 12:51:48.310174			\N	1	0	0	1	\N	\N	\N
275	ORDER202509030272	5	9	1	2025-09-03 02:26:00	2025-09-03 02:45:00	2	1	54.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 03:10:00	\N	2025-09-07 12:51:48.311855	2025-09-07 12:51:48.317204			\N	1	0	0	1	\N	\N	\N
276	ORDER202509030273	5	10	1	2025-09-03 07:07:00	2025-09-03 07:29:00	2	1	266.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-03 08:16:00	\N	2025-09-07 12:51:48.318788	2025-09-07 12:51:48.329053			\N	1	0	0	1	\N	\N	\N
277	ORDER202509030274	5	9	1	2025-09-03 09:00:00	2025-09-03 09:36:00	1	1	38.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 10:02:00	\N	2025-09-07 12:51:48.330809	2025-09-07 12:51:48.335186			\N	1	0	0	1	\N	\N	\N
278	ORDER202509030275	5	9	1	2025-09-03 17:03:00	2025-09-03 17:21:00	2	1	280.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 18:04:00	\N	2025-09-07 12:51:48.336901	2025-09-07 12:51:48.34767			\N	1	0	0	1	\N	\N	\N
279	ORDER202509030276	5	9	1	2025-09-03 04:09:00	2025-09-03 04:30:00	1	1	28.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 05:05:00	\N	2025-09-07 12:51:48.349134	2025-09-07 12:51:48.353224			\N	1	0	0	1	\N	\N	\N
280	ORDER202509030277	5	10	1	2025-09-03 19:46:00	2025-09-03 20:17:00	1	1	266.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-03 20:44:00	\N	2025-09-07 12:51:48.354886	2025-09-07 12:51:48.364229			\N	1	0	0	1	\N	\N	\N
281	ORDER202509030278	5	8	1	2025-09-03 20:24:00	2025-09-03 20:49:00	2	1	174.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-03 21:34:00	\N	2025-09-07 12:51:48.366208	2025-09-07 12:51:48.376401			\N	1	0	0	1	\N	\N	\N
282	ORDER202509030279	5	9	1	2025-09-03 05:40:00	2025-09-03 05:58:00	1	1	36.00	不要香菜	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 06:27:00	\N	2025-09-07 12:51:48.377865	2025-09-07 12:51:48.381565			\N	1	0	0	1	\N	\N	\N
283	ORDER202509030280	6	10	1	2025-09-03 03:50:00	\N	2	2	38.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	\N	\N	2025-09-07 12:51:48.383305	2025-09-07 12:51:48.38864			\N	1	0	0	1	\N	\N	\N
284	ORDER202509030281	5	9	1	2025-09-03 00:48:00	2025-09-03 01:13:00	1	1	323.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 01:37:00	\N	2025-09-07 12:51:48.389999	2025-09-07 12:51:48.396989			\N	1	0	0	1	\N	\N	\N
285	ORDER202509030282	5	10	1	2025-09-03 15:32:00	2025-09-03 15:47:00	2	1	325.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-03 16:11:00	\N	2025-09-07 12:51:48.398683	2025-09-07 12:51:48.407569			\N	1	0	0	1	\N	\N	\N
286	ORDER202509030283	5	8	1	2025-09-03 07:50:00	2025-09-03 08:22:00	1	1	308.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-03 09:12:00	\N	2025-09-07 12:51:48.408483	2025-09-07 12:51:48.414733			\N	1	0	0	1	\N	\N	\N
287	ORDER202509030284	5	9	1	2025-09-03 22:48:00	2025-09-03 23:09:00	2	1	84.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 23:32:00	\N	2025-09-07 12:51:48.416335	2025-09-07 12:51:48.420166			\N	1	0	0	1	\N	\N	\N
288	ORDER202509030285	5	9	1	2025-09-03 01:55:00	2025-09-03 02:21:00	2	1	224.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-03 03:13:00	\N	2025-09-07 12:51:48.421493	2025-09-07 12:51:48.429653			\N	1	0	0	1	\N	\N	\N
289	ORDER202509040286	5	9	1	2025-09-04 15:39:00	2025-09-04 15:52:00	2	1	141.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-04 16:17:00	\N	2025-09-07 12:51:48.430374	2025-09-07 12:51:48.436815			\N	1	0	0	1	\N	\N	\N
290	ORDER202509040287	5	9	1	2025-09-04 13:51:00	2025-09-04 14:26:00	2	1	176.00	口味清淡一些	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-04 15:14:00	\N	2025-09-07 12:51:48.438087	2025-09-07 12:51:48.445037			\N	1	0	0	1	\N	\N	\N
291	ORDER202509040288	5	9	1	2025-09-04 17:10:00	2025-09-04 17:37:00	2	1	28.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-04 18:06:00	\N	2025-09-07 12:51:48.446449	2025-09-07 12:51:48.450677			\N	1	0	0	1	\N	\N	\N
292	ORDER202509040289	5	10	1	2025-09-04 03:46:00	2025-09-04 04:09:00	2	1	56.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-04 04:38:00	\N	2025-09-07 12:51:48.452136	2025-09-07 12:51:48.456119			\N	1	0	0	1	\N	\N	\N
293	ORDER202509040290	5	9	1	2025-09-04 08:42:00	2025-09-04 09:08:00	2	1	219.00	少放辣椒	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-04 09:34:00	\N	2025-09-07 12:51:48.457285	2025-09-07 12:51:48.466526			\N	1	0	0	1	\N	\N	\N
294	ORDER202509040291	5	10	1	2025-09-04 15:37:00	2025-09-04 15:47:00	2	1	181.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-04 16:22:00	\N	2025-09-07 12:51:48.467473	2025-09-07 12:51:48.471762			\N	1	0	0	1	\N	\N	\N
295	ORDER202509040292	5	8	1	2025-09-04 09:10:00	2025-09-04 09:43:00	2	1	202.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-04 10:17:00	\N	2025-09-07 12:51:48.473343	2025-09-07 12:51:48.48057			\N	1	0	0	1	\N	\N	\N
296	ORDER202509050293	5	10	1	2025-09-05 03:36:00	2025-09-05 03:57:00	1	1	108.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-05 04:46:00	\N	2025-09-07 12:51:48.481538	2025-09-07 12:51:48.486926			\N	1	0	0	1	\N	\N	\N
297	ORDER202509050294	5	9	1	2025-09-05 18:11:00	2025-09-05 18:43:00	1	1	176.00		13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-05 19:06:00	\N	2025-09-07 12:51:48.488182	2025-09-07 12:51:48.495641			\N	1	0	0	1	\N	\N	\N
298	ORDER202509050295	5	9	1	2025-09-05 08:52:00	2025-09-05 09:03:00	2	1	210.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-05 09:37:00	\N	2025-09-07 12:51:48.497861	2025-09-07 12:51:48.505126			\N	1	0	0	1	\N	\N	\N
299	ORDER202509050296	5	10	1	2025-09-05 09:52:00	2025-09-05 10:09:00	1	1	161.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-05 10:46:00	\N	2025-09-07 12:51:48.506183	2025-09-07 12:51:48.511274			\N	1	0	0	1	\N	\N	\N
300	ORDER202509050297	5	10	1	2025-09-05 16:43:00	2025-09-05 17:05:00	2	1	84.00	打包好一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-05 17:47:00	\N	2025-09-07 12:51:48.513066	2025-09-07 12:51:48.516583			\N	1	0	0	1	\N	\N	\N
301	ORDER202509050298	5	10	1	2025-09-05 18:00:00	2025-09-05 18:36:00	1	1	312.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-05 19:10:00	\N	2025-09-07 12:51:48.517775	2025-09-07 12:51:48.527495			\N	1	0	0	1	\N	\N	\N
302	ORDER202509050299	1	8	1	2025-09-05 05:49:00	\N	1	1	232.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	\N	\N	2025-09-07 12:51:48.529487	2025-09-07 12:51:48.536294			\N	1	0	0	1	\N	\N	\N
303	ORDER202509050300	5	8	1	2025-09-05 06:32:00	2025-09-05 06:50:00	1	1	112.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-05 07:31:00	\N	2025-09-07 12:51:48.537116	2025-09-07 12:51:48.542424			\N	1	0	0	1	\N	\N	\N
304	ORDER202509050301	5	9	1	2025-09-05 20:14:00	2025-09-05 20:53:00	1	1	165.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-05 21:52:00	\N	2025-09-07 12:51:48.5443	2025-09-07 12:51:48.551199			\N	1	0	0	1	\N	\N	\N
305	ORDER202509050302	5	10	1	2025-09-05 17:50:00	2025-09-05 18:19:00	1	1	128.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-05 19:05:00	\N	2025-09-07 12:51:48.55277	2025-09-07 12:51:48.560173			\N	1	0	0	1	\N	\N	\N
306	ORDER202509060303	5	9	1	2025-09-06 13:42:00	2025-09-06 14:04:00	2	1	73.00	送餐快一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-06 14:50:00	\N	2025-09-07 12:51:48.561617	2025-09-07 12:51:48.567498			\N	1	0	0	1	\N	\N	\N
307	ORDER202509060304	5	8	1	2025-09-06 07:25:00	2025-09-06 07:51:00	1	1	182.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-06 08:19:00	\N	2025-09-07 12:51:48.56929	2025-09-07 12:51:48.577401			\N	1	0	0	1	\N	\N	\N
308	ORDER202509060305	5	8	1	2025-09-06 07:14:00	2025-09-06 07:32:00	1	1	288.00		13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-06 08:07:00	\N	2025-09-07 12:51:48.579386	2025-09-07 12:51:48.58767			\N	1	0	0	1	\N	\N	\N
309	ORDER202509060306	5	10	1	2025-09-06 17:14:00	2025-09-06 17:42:00	1	1	313.00	送餐快一点	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 18:22:00	\N	2025-09-07 12:51:48.589354	2025-09-07 12:51:48.600794			\N	1	0	0	1	\N	\N	\N
310	ORDER202509060307	5	8	1	2025-09-06 17:40:00	2025-09-06 18:04:00	2	1	361.00	打包好一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-06 18:28:00	\N	2025-09-07 12:51:48.604378	2025-09-07 12:51:48.61519			\N	1	0	0	1	\N	\N	\N
311	ORDER202509060308	5	10	1	2025-09-06 13:37:00	2025-09-06 14:01:00	1	1	70.00	不要香菜	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 14:35:00	\N	2025-09-07 12:51:48.618316	2025-09-07 12:51:48.767969			\N	1	0	0	1	\N	\N	\N
312	ORDER202509060309	5	10	1	2025-09-06 03:49:00	2025-09-06 04:28:00	1	1	71.00	不要葱	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 04:49:00	\N	2025-09-07 12:51:48.77132	2025-09-07 12:51:48.781071			\N	1	0	0	1	\N	\N	\N
313	ORDER202509060310	5	8	1	2025-09-06 17:28:00	2025-09-06 17:59:00	2	1	264.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-06 18:26:00	\N	2025-09-07 12:51:48.786116	2025-09-07 12:51:48.796731			\N	1	0	0	1	\N	\N	\N
314	ORDER202509060311	5	10	1	2025-09-06 18:43:00	2025-09-06 19:11:00	2	1	279.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 19:59:00	\N	2025-09-07 12:51:48.798027	2025-09-07 12:51:48.805655			\N	1	0	0	1	\N	\N	\N
315	ORDER202509060312	5	10	1	2025-09-06 23:07:00	2025-09-06 23:33:00	2	1	94.00	多加米饭	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 23:55:00	\N	2025-09-07 12:51:48.806708	2025-09-07 12:51:48.813883			\N	1	0	0	1	\N	\N	\N
316	ORDER202509060313	5	8	1	2025-09-06 10:54:00	2025-09-06 11:21:00	1	1	286.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-06 11:45:00	\N	2025-09-07 12:51:48.835744	2025-09-07 12:51:48.850275			\N	1	0	0	1	\N	\N	\N
317	ORDER202509060314	5	10	1	2025-09-06 13:58:00	2025-09-06 14:09:00	2	1	58.00	口味清淡一些	13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-06 14:44:00	\N	2025-09-07 12:51:48.852051	2025-09-07 12:51:48.857265			\N	1	0	0	1	\N	\N	\N
318	ORDER202509070315	5	8	1	2025-09-07 15:31:00	2025-09-07 16:06:00	2	1	154.00	不要香菜	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 16:38:00	\N	2025-09-07 12:51:48.858858	2025-09-07 12:51:48.864971			\N	1	0	0	1	\N	\N	\N
319	ORDER202509070316	5	10	1	2025-09-07 08:58:00	2025-09-07 09:32:00	1	1	216.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-07 09:55:00	\N	2025-09-07 12:51:48.867228	2025-09-07 12:51:48.876224			\N	1	0	0	1	\N	\N	\N
320	ORDER202509070317	5	8	1	2025-09-07 12:02:00	2025-09-07 12:25:00	2	1	81.00	不要葱	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 13:13:00	\N	2025-09-07 12:51:48.879588	2025-09-07 12:51:48.888342			\N	1	0	0	1	\N	\N	\N
321	ORDER202509070318	5	9	1	2025-09-07 08:57:00	2025-09-07 09:17:00	1	1	116.00	打包好一点	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-07 09:46:00	\N	2025-09-07 12:51:48.889531	2025-09-07 12:51:48.894909			\N	1	0	0	1	\N	\N	\N
322	ORDER202509070319	5	9	1	2025-09-07 23:13:00	2025-09-07 23:37:00	1	1	210.00	多加米饭	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-08 00:25:00	\N	2025-09-07 12:51:48.896752	2025-09-07 12:51:48.905517			\N	1	0	0	1	\N	\N	\N
323	ORDER202509070320	5	8	1	2025-09-07 02:14:00	2025-09-07 02:31:00	2	1	141.00	多加米饭	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 02:52:00	\N	2025-09-07 12:51:48.90758	2025-09-07 12:51:48.913807			\N	1	0	0	1	\N	\N	\N
324	ORDER202509070321	5	8	1	2025-09-07 23:09:00	2025-09-07 23:31:00	2	1	333.00	口味清淡一些	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 23:51:00	\N	2025-09-07 12:51:48.915633	2025-09-07 12:51:48.925519			\N	1	0	0	1	\N	\N	\N
325	ORDER202509070322	5	8	1	2025-09-07 05:25:00	2025-09-07 05:55:00	1	1	275.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 06:30:00	\N	2025-09-07 12:51:48.926863	2025-09-07 12:51:48.935266			\N	1	0	0	1	\N	\N	\N
326	ORDER202509070323	5	10	1	2025-09-07 22:32:00	2025-09-07 22:58:00	2	1	149.00		13912345680	北京市朝阳区建国门外大街1号	王五	王五	2025-09-07 23:22:00	\N	2025-09-07 12:51:48.937277	2025-09-07 12:51:48.941994			\N	1	0	0	1	\N	\N	\N
327	ORDER202509070324	5	8	1	2025-09-07 11:28:00	2025-09-07 11:46:00	2	1	324.00	送餐快一点	13912345678	北京市朝阳区建国门外大街1号	张三	张三	2025-09-07 12:33:00	\N	2025-09-07 12:51:48.94412	2025-09-07 12:51:48.953184			\N	1	0	0	1	\N	\N	\N
328	ORDER202509070325	5	9	1	2025-09-07 14:29:00	2025-09-07 15:06:00	1	1	279.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-07 15:56:00	\N	2025-09-07 12:51:48.955019	2025-09-07 12:51:48.961229			\N	1	0	0	1	\N	\N	\N
329	ORDER202509070326	5	9	1	2025-09-07 02:23:00	2025-09-07 03:01:00	2	1	114.00	不要葱	13912345679	北京市朝阳区建国门外大街1号	李四	李四	2025-09-07 03:49:00	\N	2025-09-07 12:51:48.962821	2025-09-07 12:51:48.968759			\N	1	0	0	1	\N	\N	\N
330	20250913141603115800	6	11	5	2025-09-13 14:16:03.619515	\N	1	0	28.00		18012345678	3楼	18012345678	李白	\N	\N	2025-09-13 14:16:03.619515	2025-09-15 18:16:24.038587	用户自行取消		2025-09-15 14:03:38.298028	1	0	0	1	2025-09-15 18:16:24.038698	\N	\N
332	20250916103636115100	6	11	6	2025-09-16 10:36:36.991995	\N	2	0	28.00		18012345678	图书馆4楼	18012345678	李白	\N	\N	2025-09-16 10:36:36.992522	2025-09-16 10:42:38.023746	用户自行取消		2025-09-16 10:42:38.023381	1	0	0	1	\N	JD3321757990539	\N
339	20250916202134115800	2	11	7	2025-09-16 20:21:34.460445	2025-09-16 20:29:19.276159	2	1	58.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:21:34.460445	2025-09-16 20:29:19.276528			\N	1	0	-1	1	\N	MOCK-20250916202134115800	2025-09-16 20:29:19.276159
340	20250916202947114200	2	11	7	2025-09-16 20:29:47.310406	2025-09-16 20:29:49.512126	2	1	28.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:29:47.310481	2025-09-16 20:29:49.512567			\N	1	0	-1	1	\N	MOCK-20250916202947114200	2025-09-16 20:29:49.512126
338	20250916201604111700	2	11	7	2025-09-16 20:16:04.497961	2025-09-16 20:56:48.737883	1	1	35.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:16:04.498473	2025-09-16 20:56:48.738177			\N	1	0	-1	1	\N	MOCK-20250916201604111700	2025-09-16 20:56:48.737883
335	2025091620065111600	2	11	7	2025-09-16 20:06:51.625	2025-09-16 20:58:30.171852	1	1	53.00	清单	13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:06:51.625	2025-09-16 20:58:30.172202			\N	1	0	-1	1	\N	MOCK-2025091620065111600	2025-09-16 20:58:30.171852
337	20250916200906115400	2	11	7	2025-09-16 20:09:06.006344	2025-09-16 22:24:21.869819	1	1	28.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:09:06.006344	2025-09-16 22:24:21.870174			\N	1	0	-1	1	\N	MOCK-20250916200906115400	2025-09-16 22:24:21.869819
336	20250916200745116000	2	11	7	2025-09-16 20:07:45.690899	2025-09-16 22:24:46.168433	1	1	35.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 20:07:45.690899	2025-09-16 22:24:46.168733			\N	1	0	-1	1	\N	MOCK-20250916200745116000	2025-09-16 22:24:46.168433
333	20250916150131115000	5	11	6	2025-09-16 15:01:31.715335	2025-09-16 18:17:41.159844	2	1	76.00		18012345678	图书馆4楼	18012345678	李白	2025-09-16 18:31:19.081001	\N	2025-09-16 15:01:31.715335	2025-09-16 18:31:19.081299			\N	1	0	0	1	\N	MOCK-20250916150131115000	2025-09-16 18:17:41.159844
331	20250915171931114200	4	11	6	2025-09-15 17:19:31.599234	2025-09-16 18:37:30.246812	1	1	56.00		18012345678	图书馆4楼	18012345678	李白	\N	\N	2025-09-15 17:19:31.599234	2025-09-16 18:44:33.231919			\N	1	0	0	1	\N	MOCK-20250915171931114200	2025-09-16 18:37:30.246812
334	20250916193804113700	6	11	6	2025-09-16 19:38:04.365033	2025-09-16 19:38:33.088795	1	1	58.00		18012345678	图书馆4楼	18012345678	李白	\N	\N	2025-09-16 19:38:04.365033	2025-09-16 19:39:05.823732		食材没了	2025-09-16 19:39:05.823444	1	0	-1	1	\N	MOCK-20250916193804113700	2025-09-16 19:38:33.088795
341	20250916234145115100	8	11	7	2025-09-16 23:41:45.961695	2025-09-16 23:41:47.43964	1	1	28.00	印度辣	13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-16 23:41:45.961695	2025-09-18 16:04:09.4751			\N	1	0	-1	1	\N	MOCK-20250916234145115100	2025-09-16 23:41:47.43964
342	20250919142217112200	1	11	7	2025-09-19 14:22:17.428472	\N	1	0	38.00		13512345678	广东省广州市番禺区东饭堂1楼	18012345678	李世民同学	\N	\N	2025-09-19 14:22:17.428472	2025-09-19 14:22:17.428472			\N	1	0	-1	1	\N		\N
343	20250922141846145600	3	14	8	2025-09-22 14:18:46.384845	2025-09-22 14:18:48.329394	1	1	28.00		13312345678	广东省广州市黄埔区信息楼217号	13312345678	杜杜鹃	\N	\N	2025-09-22 14:18:46.384845	2025-09-22 14:19:16.087137			\N	1	0	-1	1	\N	MOCK-20250922141846145600	2025-09-22 14:18:48.329394
\.


--
-- TOC entry 5075 (class 0 OID 16712)
-- Dependencies: 228
-- Data for Name: setmeal_dishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.setmeal_dishes (id, setmeal_id, dish_id, name, price, copies) FROM stdin;
18	3	22	宫保鸡丁	28.00	1
19	3	23	麻婆豆腐	18.00	1
20	3	24	白切鸡	38.00	1
21	3	25	剁椒鱼头	58.00	1
22	3	26	糖醋里脊	35.00	1
\.


--
-- TOC entry 5073 (class 0 OID 16692)
-- Dependencies: 226
-- Data for Name: setmeals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.setmeals (id, category_id, name, price, status, description, image, sales_count, created_at, updated_at, deleted_at, create_user, update_user) FROM stdin;
2	46	豪华商务餐	1000.00	0			0	2025-09-10 16:11:07.592923	2025-09-10 17:11:30.96572	2025-09-10 17:11:30.96668	18	18
3	51	九大簋	10000.00	1	好好味	/uploads/setmeals/1757835048795867000.jpeg	0	2025-09-10 20:56:18.46907	2025-09-14 15:31:06.707215	\N	18	18
\.


--
-- TOC entry 5077 (class 0 OID 16729)
-- Dependencies: 230
-- Data for Name: shopping_carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shopping_carts (id, name, image, user_id, dish_id, setmeal_id, dish_flavor, number, amount, created_at, updated_at, deleted_at) FROM stdin;
1	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-12 17:02:05.385495	2025-09-12 17:02:05.385495+08	2025-09-12 17:08:41.959897+08
2	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:02:17.419157	2025-09-12 17:02:17.419157+08	2025-09-12 17:09:20.369656+08
3	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-12 17:10:22.171659	2025-09-12 17:10:22.171659+08	2025-09-12 17:16:16.924655+08
22	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-13 14:15:35.485449	2025-09-13 14:15:35.485449+08	2025-09-13 14:16:03.634046+08
5	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	重辣	1	18.00	2025-09-12 17:16:27.176548	2025-09-12 17:16:27.176548+08	2025-09-12 17:16:28.852748+08
4	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:16:21.371729	2025-09-12 17:16:24.016149+08	2025-09-12 17:16:30.833392+08
7	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:16:35.513279	2025-09-12 17:16:35.513279+08	2025-09-12 17:16:36.771613+08
6	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	重辣	1	18.00	2025-09-12 17:16:33.04134	2025-09-12 17:16:33.04134+08	2025-09-12 17:22:28.702808+08
8	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:16:38.923977	2025-09-12 17:16:38.923977+08	2025-09-12 17:22:28.702808+08
9	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-12 17:22:30.40497	2025-09-12 17:22:32.940483+08	2025-09-12 17:22:33.541917+08
13	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	11	25	\N	中辣	1	58.00	2025-09-12 17:39:43.545208	2025-09-12 17:39:43.545208+08	2025-09-12 17:39:50.48759+08
14	白切鸡	/images/dishes/baiqie_ji.jpg	11	24	\N		1	38.00	2025-09-12 17:39:44.430268	2025-09-12 17:39:44.430268+08	2025-09-12 17:39:51.462173+08
10	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	2	28.00	2025-09-12 17:22:35.694511	2025-09-12 17:24:05.336057+08	2025-09-12 17:39:52.654797+08
11	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:22:38.52464	2025-09-12 17:22:38.52464+08	2025-09-12 17:39:52.654797+08
12	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	重辣, 麻辣	1	28.00	2025-09-12 17:24:13.625137	2025-09-12 17:24:13.625137+08	2025-09-12 17:39:52.654797+08
18	剁椒鱼头	/images/dishes/duojiao_yutou.jpg	11	25	\N	中辣	1	58.00	2025-09-12 17:43:35.383091	2025-09-12 17:43:35.383091+08	2025-09-12 17:43:37.798655+08
19	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	重辣	1	18.00	2025-09-12 17:56:30.316608	2025-09-12 17:56:30.316608+08	2025-09-12 19:16:23.391937+08
15	白切鸡	/images/dishes/baiqie_ji.jpg	11	24	\N		1	38.00	2025-09-12 17:39:54.333745	2025-09-12 17:39:54.333745+08	2025-09-12 19:16:27.239622+08
16	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-12 17:39:56.27309	2025-09-12 17:39:56.27309+08	2025-09-12 19:16:27.239622+08
17	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-12 17:39:58.118225	2025-09-12 17:39:58.118225+08	2025-09-12 19:16:27.239622+08
25	白切鸡	/images/dishes/baiqie_ji.jpg	11	24	\N		1	38.00	2025-09-13 19:39:45.009979	2025-09-13 19:39:45.009979+08	2025-09-13 19:40:41.734339+08
23	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-13 19:39:42.891026	2025-09-13 19:39:42.891026+08	2025-09-14 15:38:21.197611+08
20	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-12 19:16:29.970036	2025-09-12 19:16:32.702112+08	2025-09-12 19:16:40.494999+08
21	宫保鸡丁	/images/dishes/gongbao_jiding.jpg	11	22	\N	重辣, 甜味	1	28.00	2025-09-12 19:16:34.637297	2025-09-12 19:16:34.637297+08	2025-09-12 19:16:40.494999+08
24	麻婆豆腐	/images/dishes/mapo_doufu.jpg	11	23	\N	微辣	1	18.00	2025-09-13 19:39:44.250318	2025-09-13 19:39:44.250318+08	2025-09-14 15:38:22.399466+08
26	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-14 15:38:24.030206	2025-09-14 15:38:26.47027+08	2025-09-15 17:19:31.608927+08
27	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	重辣, 甜味	1	28.00	2025-09-14 15:38:28.770879	2025-09-14 15:38:28.770879+08	2025-09-15 17:19:31.608927+08
28	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-16 10:25:23.732431	2025-09-16 10:25:23.732431+08	2025-09-16 10:36:37.00387+08
33	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	11	26	\N		1	35.00	2025-09-16 20:06:14.472088	2025-09-16 20:06:14.472088+08	2025-09-16 20:06:51.628656+08
29	白切鸡	/uploads/dishes/1757834539920259700.jpg	11	24	\N		2	38.00	2025-09-16 15:01:20.908355	2025-09-16 15:01:23.15685+08	2025-09-16 15:01:31.721146+08
34	麻婆豆腐	/uploads/dishes/1757834528208064400.jpg	11	23	\N	微辣	1	18.00	2025-09-16 20:06:20.565615	2025-09-16 20:06:20.565615+08	2025-09-16 20:06:51.628656+08
31	白切鸡	/uploads/dishes/1757834539920259700.jpg	11	24	\N		1	38.00	2025-09-16 19:05:46.682835	2025-09-16 19:05:53.288742+08	2025-09-16 19:05:53.907529+08
30	白切鸡	/uploads/dishes/1757834539920259700.jpg	11	24	\N		2	38.00	2025-09-16 18:52:20.327608	2025-09-16 18:52:20.327608+08	2025-09-16 19:05:54.864844+08
32	剁椒鱼头	/uploads/dishes/1757834553101742200.jpg	11	25	\N	特辣	1	58.00	2025-09-16 19:21:34.155094	2025-09-16 19:21:34.155094+08	2025-09-16 19:38:04.370887+08
35	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	11	26	\N		1	35.00	2025-09-16 20:07:39.240775	2025-09-16 20:07:39.240775+08	2025-09-16 20:07:45.692643+08
36	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	不辣, 甜味	1	28.00	2025-09-16 20:08:14.927928	2025-09-16 20:08:14.927928+08	2025-09-16 20:09:06.010415+08
37	麻婆豆腐	/uploads/dishes/1757834528208064400.jpg	11	23	\N	微辣	1	18.00	2025-09-16 20:15:41.750237	2025-09-16 20:15:41.750237+08	2025-09-16 20:15:46.4093+08
38	糖醋里脊	/uploads/dishes/1757834564370474400.jpg	11	26	\N		1	35.00	2025-09-16 20:15:53.697194	2025-09-16 20:15:53.697194+08	2025-09-16 20:16:04.499926+08
39	剁椒鱼头	/uploads/dishes/1757834553101742200.jpg	11	25	\N	重辣	1	58.00	2025-09-16 20:21:29.867446	2025-09-16 20:21:29.867446+08	2025-09-16 20:21:34.462099+08
40	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	重辣, 甜味	1	28.00	2025-09-16 20:29:43.537507	2025-09-16 20:29:43.537507+08	2025-09-16 20:29:47.311661+08
41	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	11	22	\N	微辣, 麻辣	1	28.00	2025-09-16 23:41:31.860711	2025-09-16 23:41:31.860711+08	2025-09-16 23:41:45.967127+08
42	白切鸡	/uploads/dishes/1757834539920259700.jpg	11	24	\N		1	38.00	2025-09-19 14:22:10.256521	2025-09-19 14:22:10.256521+08	2025-09-19 14:22:17.433883+08
43	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	13	22	\N	不辣, 甜味	1	28.00	2025-09-19 14:41:18.65858	2025-09-19 14:41:18.65858+08	\N
44	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 麻辣	1	28.00	2025-09-22 11:32:14.714523	2025-09-22 11:32:14.714523+08	2025-09-22 12:54:56.446445+08
45	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	微辣, 咸味	1	28.00	2025-09-22 11:32:18.589364	2025-09-22 11:32:18.589364+08	2025-09-22 12:54:56.446445+08
46	白切鸡	/uploads/dishes/1757834539920259700.jpg	14	24	\N		1	38.00	2025-09-22 11:32:21.920232	2025-09-22 11:32:21.920232+08	2025-09-22 12:54:56.446445+08
47	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 甜味	1	28.00	2025-09-22 13:31:21.735731	2025-09-22 13:31:21.735731+08	2025-09-22 13:31:24.246786+08
48	九大簋	/uploads/setmeals/1757835048795867000.jpeg	14	\N	3		1	10000.00	2025-09-22 13:35:08.064439	2025-09-22 13:35:08.064439+08	2025-09-22 13:35:12.326669+08
49	九大簋	/uploads/setmeals/1757835048795867000.jpeg	14	\N	3		1	10000.00	2025-09-22 13:38:28.577328	2025-09-22 13:38:28.577328+08	2025-09-22 13:38:34.195357+08
61	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 甜味	1	28.00	2025-09-22 14:18:40.134565	2025-09-22 14:18:40.134565+08	2025-09-22 14:18:46.395379+08
50	九大簋	/uploads/setmeals/1757835048795867000.jpeg	14	\N	3		2	10000.00	2025-09-22 13:38:36.747026	2025-09-22 13:38:36.946033+08	2025-09-22 13:38:41.694432+08
51	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N		1	28.00	2025-09-22 13:38:45.86997	2025-09-22 13:38:45.86997+08	2025-09-22 13:38:50.396267+08
52	九大簋	/uploads/setmeals/1757835048795867000.jpeg	14	\N	3		1	10000.00	2025-09-22 13:40:31.90696	2025-09-22 13:40:31.90696+08	2025-09-22 13:42:45.744917+08
53	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N		1	28.00	2025-09-22 13:40:38.377174	2025-09-22 13:40:38.377174+08	2025-09-22 13:42:47.555874+08
54	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N		1	28.00	2025-09-22 13:42:52.887266	2025-09-22 13:42:52.887266+08	2025-09-22 13:42:56.762693+08
55	九大簋	/uploads/setmeals/1757835048795867000.jpeg	14	\N	3		1	10000.00	2025-09-22 13:43:05.317731	2025-09-22 13:43:05.317731+08	2025-09-22 13:49:22.499721+08
56	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N		2	28.00	2025-09-22 13:47:29.555473	2025-09-22 13:49:14.604747+08	2025-09-22 13:49:22.499721+08
57	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N		1	28.00	2025-09-22 13:49:25.344266	2025-09-22 13:49:25.344266+08	2025-09-22 13:49:33.480401+08
58	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 甜味	1	28.00	2025-09-22 13:49:30.906078	2025-09-22 13:49:30.906078+08	2025-09-22 13:49:33.480401+08
59	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 甜味	1	28.00	2025-09-22 13:52:26.595984	2025-09-22 13:52:26.595984+08	2025-09-22 13:52:30.432866+08
60	宫保鸡丁	/uploads/dishes/1757834433778227400.jpg	14	22	\N	不辣, 甜味	1	28.00	2025-09-22 13:52:32.598913	2025-09-22 13:52:32.598913+08	2025-09-22 13:52:34.532107+08
\.


--
-- TOC entry 5087 (class 0 OID 16949)
-- Dependencies: 249
-- Data for Name: store_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store_settings (id, name, address, phone, description, logo, created_at, updated_at, create_user, update_user, deleted_at, is_open) FROM stdin;
1	好想来酒家	广东省广州市黄埔区红山三路101号	18012345678	百年老店，值得信赖	/uploads/logos/1758510482711263200.jpg	2025-09-10 15:05:27.733053+08	2025-09-22 11:08:06.685271+08	18	18	\N	t
\.


--
-- TOC entry 5065 (class 0 OID 16613)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, phone, email, password, sex, avatar, login_type, last_login_time, is_active, created_at, updated_at, openid, deleted_at) FROM stdin;
8	张三	13912345678			1	/images/avatars/default_male.png	1	\N	t	2025-09-07 12:46:49.24289	2025-09-07 12:46:49.24289	test_openid_001	\N
10	王五	13912345680			1	/images/avatars/default_male.png	1	\N	t	2025-09-07 12:46:49.245856	2025-09-07 12:46:49.245856	test_openid_003	\N
14	杜存山	13312345678		$2a$10$mZUoeAnGieXy.ut6it7G1e2SEFsIWeru8eflPcxCpdg7bP7I2mWri	0		1	\N	t	2025-09-21 10:46:40.691112	2025-09-22 11:31:31.520858		\N
9	李四	13912345679			0	/images/avatars/default_female.png	1	\N	t	2025-09-07 12:46:49.244573	2025-09-10 14:34:29.311094	test_openid_002	\N
12	小明	18812345678		$2a$10$Q4Av5SYVY4zZ86i5IIAxFuwgKDv3SwFep0mN7rOwlLRZH5FMBnN7u	0		1	\N	t	2025-09-15 11:29:50.35641	2025-09-15 13:56:46.416038		\N
13	小明	18912345678		$2a$10$Y6IiZVhwqsjTpvZmHw8rdO30wTeGVhPeyDl3w022/DKe2un/TRYMe	0		1	\N	f	2025-09-19 14:39:45.206292	2025-09-19 14:40:54.193324		\N
11	李白属虎	18012345678		$2a$10$HWZtG4UM3/bnE1Zu9.l0kuj5pOE1HvI4AnynWPDxmYDw61yc6w9Gm	0	/uploads/avatars/1757929037698860900.png	1	\N	t	2025-09-12 13:50:40.262915	2025-09-22 11:21:30.365842		\N
15	杜存山1号	13412345678		$2a$10$MwIPRmWWcT3n.3y/gM9VmuHi9HeOYLd0JU3MHKNoijHHTceoBTQPe	1	/uploads/avatars/1758511831717189900.png	1	\N	t	2025-09-21 10:54:17.260052	2025-09-22 11:30:32.103806		\N
\.


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 241
-- Name: address_books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_books_id_seq', 8, true);


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 219
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 51, true);


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 223
-- Name: dish_flavors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_flavors_id_seq', 13, true);


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 221
-- Name: dishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishes_id_seq', 27, true);


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 239
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 24, true);


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_details_id_seq', 833, true);


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 343, true);


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 227
-- Name: setmeal_dishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.setmeal_dishes_id_seq', 22, true);


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 225
-- Name: setmeals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.setmeals_id_seq', 3, true);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 229
-- Name: shopping_carts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shopping_carts_id_seq', 61, true);


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 248
-- Name: store_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.store_settings_id_seq', 1, true);


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- TOC entry 4886 (class 2606 OID 16886)
-- Name: address_books address_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address_books
    ADD CONSTRAINT address_books_pkey PRIMARY KEY (id);


--
-- TOC entry 4837 (class 2606 OID 16657)
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- TOC entry 4839 (class 2606 OID 16655)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4852 (class 2606 OID 16685)
-- Name: dish_flavors dish_flavors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_flavors
    ADD CONSTRAINT dish_flavors_pkey PRIMARY KEY (id);


--
-- TOC entry 4844 (class 2606 OID 16673)
-- Name: dishes dishes_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_name_key UNIQUE (name);


--
-- TOC entry 4846 (class 2606 OID 16671)
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (id);


--
-- TOC entry 4882 (class 2606 OID 16874)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 4880 (class 2606 OID 16787)
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


--
-- TOC entry 4872 (class 2606 OID 16768)
-- Name: orders orders_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_number_key UNIQUE (number);


--
-- TOC entry 4874 (class 2606 OID 16766)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4861 (class 2606 OID 16717)
-- Name: setmeal_dishes setmeal_dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeal_dishes
    ADD CONSTRAINT setmeal_dishes_pkey PRIMARY KEY (id);


--
-- TOC entry 4857 (class 2606 OID 16705)
-- Name: setmeals setmeals_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeals
    ADD CONSTRAINT setmeals_name_key UNIQUE (name);


--
-- TOC entry 4859 (class 2606 OID 16703)
-- Name: setmeals setmeals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeals
    ADD CONSTRAINT setmeals_pkey PRIMARY KEY (id);


--
-- TOC entry 4865 (class 2606 OID 16736)
-- Name: shopping_carts shopping_carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_carts
    ADD CONSTRAINT shopping_carts_pkey PRIMARY KEY (id);


--
-- TOC entry 4892 (class 2606 OID 16956)
-- Name: store_settings store_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_settings
    ADD CONSTRAINT store_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 16626)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4835 (class 2606 OID 16624)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4887 (class 1259 OID 16916)
-- Name: idx_address_books_default; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_address_books_default ON public.address_books USING btree (user_id, is_default);


--
-- TOC entry 4888 (class 1259 OID 16887)
-- Name: idx_address_books_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_address_books_deleted_at ON public.address_books USING btree (deleted_at);


--
-- TOC entry 4889 (class 1259 OID 16915)
-- Name: idx_address_books_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_address_books_user_id ON public.address_books USING btree (user_id);


--
-- TOC entry 4840 (class 1259 OID 16892)
-- Name: idx_categories_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_deleted_at ON public.categories USING btree (deleted_at);


--
-- TOC entry 4841 (class 1259 OID 16912)
-- Name: idx_categories_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_status ON public.categories USING btree (status);


--
-- TOC entry 4842 (class 1259 OID 16911)
-- Name: idx_categories_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_type ON public.categories USING btree (type);


--
-- TOC entry 4847 (class 1259 OID 16817)
-- Name: idx_dishes_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishes_category_id ON public.dishes USING btree (category_id);


--
-- TOC entry 4848 (class 1259 OID 16909)
-- Name: idx_dishes_composite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishes_composite ON public.dishes USING btree (category_id, status);


--
-- TOC entry 4849 (class 1259 OID 16893)
-- Name: idx_dishes_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishes_deleted_at ON public.dishes USING btree (deleted_at);


--
-- TOC entry 4850 (class 1259 OID 16818)
-- Name: idx_dishes_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishes_status ON public.dishes USING btree (status);


--
-- TOC entry 4883 (class 1259 OID 16875)
-- Name: idx_employees_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employees_deleted_at ON public.employees USING btree (deleted_at);


--
-- TOC entry 4884 (class 1259 OID 16876)
-- Name: idx_employees_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_employees_username ON public.employees USING btree (username);


--
-- TOC entry 4875 (class 1259 OID 16896)
-- Name: idx_order_details_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_details_deleted_at ON public.order_details USING btree (deleted_at);


--
-- TOC entry 4876 (class 1259 OID 16907)
-- Name: idx_order_details_dish_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_details_dish_id ON public.order_details USING btree (dish_id);


--
-- TOC entry 4877 (class 1259 OID 16821)
-- Name: idx_order_details_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_details_order_id ON public.order_details USING btree (order_id);


--
-- TOC entry 4878 (class 1259 OID 16908)
-- Name: idx_order_details_setmeal_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_details_setmeal_id ON public.order_details USING btree (setmeal_id);


--
-- TOC entry 4866 (class 1259 OID 16906)
-- Name: idx_orders_composite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_composite ON public.orders USING btree (order_time, status, user_id);


--
-- TOC entry 4867 (class 1259 OID 16891)
-- Name: idx_orders_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_deleted_at ON public.orders USING btree (deleted_at);


--
-- TOC entry 4868 (class 1259 OID 16905)
-- Name: idx_orders_order_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_order_time ON public.orders USING btree (order_time);


--
-- TOC entry 4869 (class 1259 OID 16820)
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- TOC entry 4870 (class 1259 OID 16819)
-- Name: idx_orders_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);


--
-- TOC entry 4853 (class 1259 OID 16913)
-- Name: idx_setmeals_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_setmeals_category_id ON public.setmeals USING btree (category_id);


--
-- TOC entry 4854 (class 1259 OID 16894)
-- Name: idx_setmeals_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_setmeals_deleted_at ON public.setmeals USING btree (deleted_at);


--
-- TOC entry 4855 (class 1259 OID 16914)
-- Name: idx_setmeals_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_setmeals_status ON public.setmeals USING btree (status);


--
-- TOC entry 4862 (class 1259 OID 16866)
-- Name: idx_shopping_carts_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shopping_carts_deleted_at ON public.shopping_carts USING btree (deleted_at);


--
-- TOC entry 4863 (class 1259 OID 16822)
-- Name: idx_shopping_carts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shopping_carts_user_id ON public.shopping_carts USING btree (user_id);


--
-- TOC entry 4890 (class 1259 OID 16957)
-- Name: idx_store_settings_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_store_settings_deleted_at ON public.store_settings USING btree (deleted_at);


--
-- TOC entry 4829 (class 1259 OID 16910)
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- TOC entry 4830 (class 1259 OID 16888)
-- Name: idx_users_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at);


--
-- TOC entry 4831 (class 1259 OID 16815)
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_phone ON public.users USING btree (phone);


--
-- TOC entry 4906 (class 2620 OID 16826)
-- Name: categories update_categories_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4907 (class 2620 OID 16827)
-- Name: dishes update_dishes_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_dishes_updated_at BEFORE UPDATE ON public.dishes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4909 (class 2620 OID 16829)
-- Name: orders update_orders_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4908 (class 2620 OID 16828)
-- Name: setmeals update_setmeals_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_setmeals_updated_at BEFORE UPDATE ON public.setmeals FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4905 (class 2620 OID 16824)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4894 (class 2606 OID 16686)
-- Name: dish_flavors dish_flavors_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_flavors
    ADD CONSTRAINT dish_flavors_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id) ON DELETE CASCADE;


--
-- TOC entry 4893 (class 2606 OID 16674)
-- Name: dishes dishes_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 4902 (class 2606 OID 16793)
-- Name: order_details order_details_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id);


--
-- TOC entry 4903 (class 2606 OID 16788)
-- Name: order_details order_details_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 4904 (class 2606 OID 16798)
-- Name: order_details order_details_setmeal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_setmeal_id_fkey FOREIGN KEY (setmeal_id) REFERENCES public.setmeals(id);


--
-- TOC entry 4901 (class 2606 OID 16769)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4896 (class 2606 OID 16723)
-- Name: setmeal_dishes setmeal_dishes_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeal_dishes
    ADD CONSTRAINT setmeal_dishes_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id);


--
-- TOC entry 4897 (class 2606 OID 16718)
-- Name: setmeal_dishes setmeal_dishes_setmeal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeal_dishes
    ADD CONSTRAINT setmeal_dishes_setmeal_id_fkey FOREIGN KEY (setmeal_id) REFERENCES public.setmeals(id) ON DELETE CASCADE;


--
-- TOC entry 4895 (class 2606 OID 16706)
-- Name: setmeals setmeals_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setmeals
    ADD CONSTRAINT setmeals_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 4898 (class 2606 OID 16742)
-- Name: shopping_carts shopping_carts_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_carts
    ADD CONSTRAINT shopping_carts_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id);


--
-- TOC entry 4899 (class 2606 OID 16747)
-- Name: shopping_carts shopping_carts_setmeal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_carts
    ADD CONSTRAINT shopping_carts_setmeal_id_fkey FOREIGN KEY (setmeal_id) REFERENCES public.setmeals(id);


--
-- TOC entry 4900 (class 2606 OID 16737)
-- Name: shopping_carts shopping_carts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_carts
    ADD CONSTRAINT shopping_carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2025-09-23 14:47:50

--
-- PostgreSQL database dump complete
--

\unrestrict hRzgNccctUEpioz3TxdgyOlWf6lrfzNX59qFvzhl91pHckJ2IVIegSjZtNpBTFe

