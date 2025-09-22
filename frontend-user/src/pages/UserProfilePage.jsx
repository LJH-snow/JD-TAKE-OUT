import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext'; // 引入 useAuth
import './UserProfilePage.css';

// 导入新创建的卡片组件
import UserProfileCard from '../components/UserProfileCard';
import MyOrdersCard from '../components/MyOrdersCard';
import FeatureExpansionCard from '../components/FeatureExpansionCard';

const UserProfilePage = () => {
  const { user, isLoading } = useAuth(); // 从全局 Context 获取用户数据和加载状态

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

      {/* 用户信息卡片，传递 user 对象和加载状态 */}
      <UserProfileCard user={user} isLoading={isLoading} />

      {/* 我的订单卡片 */}
      <MyOrdersCard />

      {/* 功能拓展卡片 */}
      <FeatureExpansionCard />

    </div>
  );
};

export default UserProfilePage;
