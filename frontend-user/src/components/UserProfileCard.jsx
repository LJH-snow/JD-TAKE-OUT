import React from 'react';
import { Link } from 'react-router-dom';
import './UserProfileCard.css';

// 这是一个展示组件，接收用户信息作为 props
const UserProfileCard = ({ user }) => {
  if (!user) {
    return null; // 如果没有用户信息，则不渲染
  }

  // 根据用户数据决定头像源的辅助函数
  const getAvatarSrc = (user) => {
    // 如果用户有自定义头像，则拼接成完整URL
    if (user.avatar) {
      return user.avatar.startsWith('http') ? user.avatar : `http://localhost:8090${user.avatar}`;
    }
    // 否则，根据性别使用默认头像
    if (user.sex === '1') { // 假设 '1' 代表男性
      return '/images/avatars/default_male.png';
    }
    if (user.sex === '0') { // 假设 '0' 代表女性
      return '/images/avatars/default_female.png';
    }
    // 如果没有设置性别，使用通用默认头像
    return '/images/avatars/default.png';
  };

  return (
    <div className="user-profile-card">
      <Link to="/profile/edit" className="profile-main-link">
        <div className="profile-avatar">
          <img src={getAvatarSrc(user)} alt="User Avatar" />
        </div>
        <div className="profile-info">
          <p className="username">{user.name || '用户名'}</p>
          <span className="edit-prompt">点击编辑个人资料</span>
        </div>
      </Link>

      {/* 
        账户权益模块: 
        根据开发文档，此功能因缺少后端 API 和数据库支持而暂时无法实现。
        在后端支持前，此部分将作为注释保留或显示为静态占位符。
      */}
      <div className="user-benefits-placeholder">
        <p className="benefits-unavailable-note">更多会员权益功能即将开放</p>
      </div>
    </div>
  );
};

export default UserProfileCard;
