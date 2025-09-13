
import React from 'react';
import { useLocation, Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const ProtectedRoute = () => {
  const auth = useAuth();
  const location = useLocation();

  if (!auth.isAuthenticated) {
    // 如果用户未认证，则重定向到登录页
    // state: { from: location } 保存了用户想访问的原始页面路径
    // 登录成功后可以再跳回来
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // 如果已认证，则渲染子路由
  return <Outlet />;
};

export default ProtectedRoute;
