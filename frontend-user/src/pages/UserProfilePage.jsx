import React, { useState, useEffect } from 'react';
import { getMe } from '../api';
import { Link } from 'react-router-dom';
import './UserProfilePage.css';

// 导入新创建的卡片组件
import UserProfileCard from '../components/UserProfileCard';
import MyOrdersCard from '../components/MyOrdersCard';
import FeatureExpansionCard from '../components/FeatureExpansionCard';

const UserProfilePage = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        setLoading(true);
        const response = await getMe();
        if (response.data && response.data.code === 200) {
          setUser(response.data.data);
        } else {
          setError(response.data.message || '获取用户资料失败');
        }
      } catch (err) {
        setError(err.response?.data?.message || '加载数据失败，请稍后再试');
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, []);

  if (loading) {
    return <div className="user-profile-page-container">加载中...</div>;
  }

  if (error) {
    return <div className="user-profile-page-container error-message">错误: {error}</div>;
  }

  return (
    <div className="user-profile-page-container">
      {/* 顶部导航区 - 严格按照设计文档实现 */}
      <header className="profile-header sticky-header">
        <Link to="/addresses" className="header-icon-link">
          <span role="img" aria-label="addresses">📍</span>
          <p>地址</p>
        </Link>
        <Link to="/settings" className="header-icon-link">
          <span role="img" aria-label="settings">⚙️</span>
          <p>设置</p>
        </Link>
      </header>

      {/* 用户信息卡片 */}
      <UserProfileCard user={user} />

      {/* 我的订单卡片 */}
      <MyOrdersCard />

      {/* 功能拓展卡片 */}
      <FeatureExpansionCard />

    </div>
  );
};

export default UserProfilePage;
