import React, { useState, useEffect } from 'react';
import { Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import {
  AppstoreOutlined,
  ShopOutlined,
  UserOutlined,
  TeamOutlined,
  DesktopOutlined,
  FileOutlined,
  PieChartOutlined,
  LogoutOutlined,
  SettingOutlined,
} from '@ant-design/icons';
import { Layout, Menu, theme, Button, message, Avatar, Spin } from 'antd';
import Dashboard from './pages/Dashboard';
import DishManagement from './pages/DishManagement';
import OrderManagement from './pages/OrderManagement';
import EmployeeManagement from './pages/EmployeeManagement';
import LoginPage from './pages/Login';
import apiClient from './api';

// Placeholder pages for new menu items
const SetmealManagement = () => <div>套餐管理页面</div>;
import CategoryManagement from './pages/CategoryManagement';
const UserManagement = () => <div>用户管理页面</div>;
const StoreSettings = () => <div>店铺设置页面</div>;

const { Header, Content, Footer, Sider } = Layout;

const menuItems = [
  { key: '/', icon: <PieChartOutlined />, label: '工作台' },
  { key: '/orders', icon: <FileOutlined />, label: '订单管理' },
  {
    key: '/items',
    icon: <AppstoreOutlined />,
    label: '商品管理',
    children: [
      { key: '/dishes', icon: <DesktopOutlined />, label: '菜品管理' },
      { key: '/setmeals', icon: <ShopOutlined />, label: '套餐管理' },
      { key: '/categories', icon: <ShopOutlined />, label: '分类管理' },
    ],
  },
  {
    key: '/personnel',
    icon: <UserOutlined />,
    label: '人员管理',
    children: [
      { key: '/employees', icon: <TeamOutlined />, label: '员工管理' },
      { key: '/users', icon: <UserOutlined />, label: '用户管理' },
    ],
  },
  { key: '/settings', icon: <SettingOutlined />, label: '店铺设置' },
];

const App = () => {
  const [authStatus, setAuthStatus] = useState('loading'); // 状态: loading, authenticated, unauthenticated
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    const verifyToken = async () => {
      const token = localStorage.getItem('jwt_token');
      if (!token) {
        setAuthStatus('unauthenticated');
        return;
      }

      try {
        // 通过 /me 接口验证 token 有效性
        const response = await apiClient.get('/admin/me');
        if (response.data && response.data.code === 200) {
          setCurrentUser(response.data.data);
          setAuthStatus('authenticated');
        } else {
          throw new Error('Token verification failed');
        }
      } catch (error) {
        localStorage.removeItem('jwt_token');
        setAuthStatus('unauthenticated');
      }
    };

    verifyToken();
  }, []);

  const handleLoginSuccess = (user) => {
    setCurrentUser(user);
    setAuthStatus('authenticated');
  };

  const handleLogout = () => {
    localStorage.removeItem('jwt_token');
    setCurrentUser(null);
    setAuthStatus('unauthenticated');
    message.success('您已成功退出登录');
  };

  if (authStatus === 'loading') {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <Spin size="large" tip="验证身份中..." />
      </div>
    );
  }

  if (authStatus === 'unauthenticated') {
    return <LoginPage onLoginSuccess={handleLoginSuccess} />;
  }

  return <MainLayout user={currentUser} onLogout={handleLogout} />;
};

const MainLayout = ({ user, onLogout }) => {
  const [collapsed, setCollapsed] = useState(false);
  const { token: { colorBgContainer, borderRadiusLG } } = theme.useToken();
  const navigate = useNavigate();
  const location = useLocation();

  // Logic for menu keys
  const [openKeys, setOpenKeys] = useState([]);

  // Set default open key based on current path
  useEffect(() => {
    const currentPath = location.pathname;
    const parent = menuItems.find(
      (item) => item.children && item.children.some((child) => child.key === currentPath)
    );
    if (parent) {
      setOpenKeys([parent.key]);
    } else {
      // Optional: collapse others if a top-level item is clicked
      setOpenKeys([]);
    }
  }, [location.pathname]);

  const handleMenuClick = (e) => {
    navigate(e.key);
  };

  const onOpenChange = (keys) => {
    setOpenKeys(keys);
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider collapsible collapsed={collapsed} onCollapse={(value) => setCollapsed(value)}>
        <div style={{ height: 32, margin: 16, background: 'rgba(255, 255, 255, 0.2)', textAlign: 'center', color: 'white', lineHeight: '32px', borderRadius: '6px' }}>JD 外卖</div>
        <Menu 
          theme="dark" 
          selectedKeys={[location.pathname]} 
          openKeys={openKeys}
          onOpenChange={onOpenChange}
          mode="inline" 
          items={menuItems} 
          onClick={handleMenuClick} 
        />
      </Sider>
      <Layout>
        <Header style={{ padding: '0 16px', background: colorBgContainer, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }} >
            <h2 style={{ margin: 0 }}>管理员后台</h2>
            <div>
              <Avatar style={{ backgroundColor: '#87d068', marginRight: '8px' }} icon={<UserOutlined />} />
              <span style={{marginRight: '16px'}}>欢迎, {user?.name || '管理员'}</span>
              <Button icon={<LogoutOutlined />} onClick={onLogout}>
                退出登录
              </Button>
            </div>
        </Header>
        <Content style={{ margin: '16px', display: 'flex', flexDirection: 'column' }}>
          <div style={{ padding: 24, background: colorBgContainer, borderRadius: borderRadiusLG, flex: 1 }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/orders" element={<OrderManagement />} />
              <Route path="/dishes" element={<DishManagement />} />
              <Route path="/setmeals" element={<SetmealManagement />} />
              <Route path="/categories" element={<CategoryManagement />} />
              <Route path="/employees" element={<EmployeeManagement />} />
              <Route path="/users" element={<UserManagement />} />
              <Route path="/settings" element={<StoreSettings />} />
            </Routes>
          </div>
        </Content>
        <Footer style={{ textAlign: 'center' }}>
          JD Take-Out Admin ©{new Date().getFullYear()} Created by Gemini
        </Footer>
      </Layout>
    </Layout>
  );
};

export default App;
