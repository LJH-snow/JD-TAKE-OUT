
import React, { useEffect, useState } from 'react';
import { useLocation, Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getMe } from '../api';

const ProtectedRoute = () => {
  const auth = useAuth();
  const location = useLocation();
  const [isTokenValid, setIsTokenValid] = useState(true); // 默认为 true，避免闪烁
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const verifyToken = async () => {
      if (!auth.token) {
        setIsTokenValid(false);
        setIsLoading(false);
        return;
      }

      try {
        await getMe(); // 尝试调用受保护的 API
        setIsTokenValid(true);
      } catch (error) {
        if (error.response && error.response.status === 401) {
          // 如果是 401 错误，说明令牌无效
          auth.logout(); // 清除无效的令牌和用户状态
          setIsTokenValid(false);
        }
      } finally {
        setIsLoading(false);
      }
    };

    verifyToken();
  }, [auth]); // 依赖 auth 对象，以便在 logout 后能重新评估

  if (isLoading) {
    // 在验证期间，可以显示一个加载指示器
    return <div>正在验证身份...</div>;
  }

  if (!isTokenValid || !auth.isAuthenticated) {
    // 如果令牌无效或用户未认证，则重定向到登录页
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // 如果身份验证通过，则渲染子路由
  return <Outlet />;
};

export default ProtectedRoute;
