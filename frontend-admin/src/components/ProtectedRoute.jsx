import React from 'react';
import { Navigate } from 'react-router-dom';
import { Result, Button } from 'antd';

const ProtectedRoute = ({ children, requiredRole, userRole, onGoHome }) => {
  // If no role is required, allow access
  if (!requiredRole) {
    return children;
  }

  // If user role matches required role, allow access
  if (userRole === requiredRole) {
    return children;
  }

  // If admin is required but user is not admin, show access denied
  if (requiredRole === 'admin' && userRole !== 'admin') {
    return (
      <Result
        status="403"
        title="403"
        subTitle="抱歉，您没有权限访问此页面。"
        extra={
          <Button type="primary" onClick={onGoHome}>
            返回首页
          </Button>
        }
      />
    );
  }

  // Default: redirect to home
  return <Navigate to="/" replace />;
};

export default ProtectedRoute;