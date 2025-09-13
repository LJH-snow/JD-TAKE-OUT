import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext'; // ADD THIS LINE
import './StoreHeader.css';

const StoreHeader = () => {
  const navigate = useNavigate();
  const { isAuthenticated, user } = useAuth(); // ADD THIS LINE

  // 这些数据未来将从API获取
  const storeInfo = {
    name: '快马中餐厅',
    announcement: '新店开业，全场8折！配送范围5公里内。',
    description: '本店主营新派川菜，麻辣鲜香，回味无穷。',
    phone: '18812345678',
    rating: 4.8,
    monthlySales: 600,
    minPrice: 20,
    deliveryFee: 5,
    deliveryTime: 30,
    logoUrl: 'https://via.placeholder.com/80', // Placeholder logo
    coverUrl: 'https://via.placeholder.com/400x150', // Placeholder cover
  };

  const handleGoToProfile = () => {
    if (isAuthenticated) {
      navigate('/profile');
    } else {
      navigate('/login'); // Redirect to login if not logged in
    }
  };

  return (
    <div className="store-header-container">
      <img src={storeInfo.coverUrl} alt="Cover" className="store-cover" />
      
      {/* New user status and profile button area */}
      <div className="user-status-area">
        {isAuthenticated ? (
          <span className="user-greeting">欢迎 {user?.name || user?.username || user?.phone}，祝您用餐愉快</span>
        ) : (
          <span className="user-greeting">请登录购餐</span>
        )}
        <button className="profile-circle-button" onClick={handleGoToProfile}>
          {isAuthenticated ? (user?.name ? user.name.charAt(0) : '👤') : '👤'} {/* Display first letter of name or a default icon */}
        </button>
      </div>

      <div className="store-info-card">
        <img src={storeInfo.logoUrl} alt="Logo" className="store-logo" />
        <div className="store-details">
          <h1 className="store-name">{storeInfo.name}</h1>
          <p className="store-meta">
            <span>评分 {storeInfo.rating}</span>
            <span>月售 {storeInfo.monthlySales}+</span>
            <span>起送 ¥{storeInfo.minPrice}</span>
            <span>配送 ¥{storeInfo.deliveryFee}</span>
            <span>约 {storeInfo.deliveryTime}分钟</span>
          </p>
          <p className="store-announcement">公告：{storeInfo.announcement}</p>
          <p className="store-description">简介：{storeInfo.description}</p>
        </div>
        <div className="store-actions">
          <button className="favorite-button">收藏</button>
          <a href={`tel:${storeInfo.phone}`} className="phone-button">📞</a>
          {/* Removed old profile button */}
        </div>
      </div>
    </div>
  );
};

export default StoreHeader;
