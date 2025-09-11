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
import { Layout, Menu, theme, Button, message, Avatar, Spin, App as AntApp, Space, Switch } from 'antd';
import Dashboard from './pages/Dashboard';
import DishManagement from './pages/DishManagement';
import OrderManagement from './pages/OrderManagement';
import EmployeeManagement from './pages/EmployeeManagement';
import SetmealManagement from './pages/SetmealManagement';
import CategoryManagement from './pages/CategoryManagement';
import UserManagement from './pages/UserManagement';
import StoreSettings from './pages/StoreSettings'; // Corrected import
import LoginPage from './pages/Login';
import apiClient from './api';

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
  const [storeStatus, setStoreStatus] = useState(null); // New state for store status

  useEffect(() => {
    const verifyTokenAndFetchSettings = async () => {
      const token = localStorage.getItem('jwt_token');
      if (!token) {
        setAuthStatus('unauthenticated');
        return;
      }

      try {
        // Verify token
        const userResponse = await apiClient.get('/admin/me');
        if (userResponse.data && userResponse.data.code === 200) {
          setCurrentUser(userResponse.data.data);
          setAuthStatus('authenticated');
        } else {
          throw new Error('Token verification failed');
        }

        // Fetch store settings
        const settingsResponse = await apiClient.get('/admin/settings');
        if (settingsResponse.data && settingsResponse.data.code === 200) {
          setStoreStatus(settingsResponse.data.data.is_open);
        } else {
          // If settings not found, assume open by default or handle error
          setStoreStatus(true);
        }

      } catch (error) {
        localStorage.removeItem('jwt_token');
        setAuthStatus('unauthenticated');
        // Handle error fetching settings if user is authenticated
        if (currentUser) { // If user was authenticated but settings fetch failed
            message.error('获取店铺营业状态失败');
            setStoreStatus(true); // Default to open
        }
      }
    };

    verifyTokenAndFetchSettings();
  }, []); // 依赖数组改为 []，只在组件挂载时运行一次

  const handleLoginSuccess = (user) => {
    setCurrentUser(user);
    setAuthStatus('authenticated');
    // Re-fetch settings after login
    const fetchSettingsAfterLogin = async () => {
        try {
            const settingsResponse = await apiClient.get('/admin/settings');
            if (settingsResponse.data && settingsResponse.data.code === 200) {
                setStoreStatus(settingsResponse.data.data.is_open);
            } else {
                setStoreStatus(true);
            }
        } catch (error) {
            message.error('获取店铺营业状态失败');
            setStoreStatus(true);
        }
    };
    fetchSettingsAfterLogin();
  };

  const handleLogout = () => {
    localStorage.removeItem('jwt_token');
    setCurrentUser(null);
    setAuthStatus('unauthenticated');
    setStoreStatus(null); // Clear store status on logout
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

  return <MainLayout user={currentUser} onLogout={handleLogout} storeStatus={storeStatus} setStoreStatus={setStoreStatus} />;
};

const MainLayout = ({ user, onLogout, storeStatus, setStoreStatus }) => {
  const [collapsed, setCollapsed] = useState(false);
  const { token: { colorBgContainer, borderRadiusLG } } = theme.useToken();
  const navigate = useNavigate();
  const location = useLocation();
  const { message } = AntApp.useApp(); // Get message instance from AntApp context

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

  const handleStoreStatusToggle = async (checked) => {
    try {
      // Fetch current settings to get other fields
      const currentSettingsResponse = await apiClient.get('/admin/settings');
      if (currentSettingsResponse.data && currentSettingsResponse.data.code === 200) {
        const currentSettings = currentSettingsResponse.data.data;
        const payload = { ...currentSettings, is_open: checked };
        const response = await apiClient.put('/admin/settings', payload);
        if (response.data && response.data.code === 200) {
          setStoreStatus(checked); // Update local state
          message.success(`店铺已${checked ? '营业' : '打烊'}`);
        } else {
          message.error(response.data.message || '更新店铺状态失败');
        }
      } else {
        message.error('无法获取当前店铺设置');
      }
    } catch (error) {
      message.error(error.response?.data?.message || '网络错误，更新店铺状态失败');
    }
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
            <div style={{ display: 'flex', alignItems: 'center' }}>
              {storeStatus !== null && (
                <Space size="middle" style={{ marginRight: '16px' }}>
                  <span>店铺状态:</span>
                  <Switch
                    checkedChildren="营业中"
                    unCheckedChildren="已打烊"
                    checked={storeStatus}
                    onChange={handleStoreStatusToggle}
                  />
                </Space>
              )}
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
