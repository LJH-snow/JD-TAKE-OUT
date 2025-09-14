import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { apiClient } from '../api'; // Import apiClient
import './StoreHeader.css';

const StoreHeader = () => {
  const navigate = useNavigate();
  const { isAuthenticated, user } = useAuth();
  const [storeInfo, setStoreInfo] = useState({
    name: '加载中...',
    announcement: '欢迎光临本店！新鲜食材，用心烹饪，为您提供美味佳肴。',
    description: '',
    phone: '',
    rating: 4.8, // 模拟评分
    monthlySales: 1280, // 模拟月售
    minPrice: 20, // 模拟起送价格
    deliveryFee: 5, // 模拟配送费
    deliveryTime: 25, // 模拟配送时间
    logo: '/images/placeholder.png', // Default placeholder
    coverUrl: '/images/placeholder-cover.png', // Local placeholder cover
    coverVideo: 'https://www.bilibili.com/video/BV1jR4y147f1?t=3.7', // B站视频链接
  });

  useEffect(() => {
    const fetchStoreSettings = async () => {
      try {
        // Let's try /api/v1/store-settings first, as per router.go public routes
        const response = await apiClient.get('/store-settings');
        if (response.data && response.data.code === 200) {
          const fetchedSettings = response.data.data;
          setStoreInfo(prevInfo => ({
            ...prevInfo,
            name: fetchedSettings.name || prevInfo.name,
            announcement: fetchedSettings.announcement || prevInfo.announcement,
            description: fetchedSettings.description || prevInfo.description,
            phone: fetchedSettings.phone || prevInfo.phone,
            // 使用后端数据，如果为空则使用模拟数据
            rating: fetchedSettings.rating || 4.8,
            monthlySales: fetchedSettings.monthly_sales || 1280,
            minPrice: fetchedSettings.min_price || 20,
            deliveryFee: fetchedSettings.delivery_fee || 5,
            deliveryTime: fetchedSettings.delivery_time || 25,
            logo: fetchedSettings.logo || '/images/placeholder.png', // Use fetched logo, fallback to placeholder
            // coverUrl might also come from settings, but not in current model
          }));
        }
      } catch (error) {
        console.error("Failed to fetch store settings:", error);
        // Fallback to default hardcoded values or show error
      }
    };

    fetchStoreSettings();
  }, []);

  const handleGoToProfile = () => {
    if (isAuthenticated) {
      navigate('/profile');
    } else {
      navigate('/login'); // Redirect to login if not logged in
    }
  };

  return (
    <div className="store-header-container">
      <iframe 
        className="store-cover" 
        src="//player.bilibili.com/player.html?isOutside=true&aid=336966605&bvid=BV1jR4y147f1&cid=449317399&p=1&autoplay=0&muted=1"
        scrolling="no" 
        border="0" 
        frameBorder="no" 
        frameSpacing="0" 
        allowFullScreen="true"
        allow="autoplay; fullscreen"
        style={{width: '100%', height: '150px'}}
        title="商家介绍视频"
      />
      
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
          {/* Removed old profile button */}
        </div>
      </div>
    </div>
  );
};

export default StoreHeader;
