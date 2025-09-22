import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { apiClient } from '../api';
import './StoreHeader.css';

const StoreHeader = () => {
  const { isAuthenticated, user, isLoading } = useAuth();
  const [storeInfo, setStoreInfo] = useState({
    name: '加载中...',
    announcement: '欢迎光临本店！新鲜食材，用心烹饪，为您提供美味佳肴。',
    description: '',
    phone: '',
    rating: 4.8,
    monthlySales: 1280,
    minPrice: 20,
    deliveryFee: 5,
    deliveryTime: 25,
    logo: '/images/placeholder.png',
  });

  useEffect(() => {
    const fetchStoreSettings = async () => {
      try {
        const response = await apiClient.get('/store-settings');
        if (response.data && response.data.code === 200) {
          const fetchedSettings = response.data.data;
          const logoUrl = fetchedSettings.logo || '/images/placeholder.png';
          
          setStoreInfo(prevInfo => ({
            ...prevInfo,
            name: fetchedSettings.name || 'JD外卖',
            logo: logoUrl,
          }));
        }
      } catch (error) {
        console.error("Failed to fetch store settings:", error);
      }
    };
    fetchStoreSettings();
  }, []);

  const getAvatarSrc = (user) => {
    if (user && user.avatar) {
      return user.avatar;
    }
    if (user && user.sex === '1') {
      return '/images/avatars/default_male.png';
    }
    if (user && user.sex === '0') {
      return '/images/avatars/default_female.png';
    }
    return '/images/avatars/default.png';
  };

  return (
    <div className="store-header-container">
      <video 
        className="store-cover"
        src="/videos/143420-782373959.mp4"
        autoPlay
        loop
        muted
        playsInline  // Important for iOS devices
      ></video>

      <div className="user-status-area">
        {isLoading ? (
          <span className="user-greeting">加载中...</span>
        ) : isAuthenticated ? (
          <span className="user-greeting">欢迎 {user?.name || user?.phone}</span>
        ) : (
          <span className="user-greeting">请登录购餐</span>
        )}
        <Link to={isLoading ? '#' : (isAuthenticated ? '/profile' : '/login')} className="profile-circle-button">
          {isLoading ? (
            <div className="avatar-placeholder" /> 
          ) : (
            <img src={getAvatarSrc(user)} alt="User Avatar" />
          )}
        </Link>
      </div>

      <div className="store-info-card">
        <img src={storeInfo.logo} alt="Logo" className="store-logo" />
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
        </div>
      </div>
    </div>
  );
};

export default StoreHeader;
