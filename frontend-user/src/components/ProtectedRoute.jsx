
import React, { useEffect, useRef, useState } from 'react';
import { useLocation, Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getMe } from '../api';

const ProtectedRoute = () => {
  const auth = useAuth();
  const location = useLocation();
  const [isTokenValid, setIsTokenValid] = useState(true); // 默认为 true，避免闪烁
  const [isLoading, setIsLoading] = useState(true);

  const verifiedRef = useRef(false);

  useEffect(() => {
    const verifyToken = async () => {
      if (!auth.token) {
        setIsTokenValid(false);
        setIsLoading(false);
        return;
      }

      try {
        if (verifiedRef.current) {
          setIsTokenValid(true);
          setIsLoading(false);
          return;
        }

        const res = await getMe(); // 尝试调用受保护的 API
        if (res?.data?.code === 200 && res?.data?.data) {
          // 仅在与现有用户信息不同的时候才更新，避免引发无限循环
          const serverUser = res.data.data;
          const currentUser = auth.user || {};
          const changed = (
            serverUser.id !== currentUser.id ||
            serverUser.name !== currentUser.name ||
            serverUser.phone !== currentUser.phone ||
            serverUser.avatar !== currentUser.avatar ||
            serverUser.sex !== currentUser.sex
          );
          if (changed) {
            auth.updateUser(serverUser);
          }
        }
        verifiedRef.current = true;
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
  }, [auth.token]); // 仅在 token 变化时验证，避免因 user 更新导致重复请求

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
