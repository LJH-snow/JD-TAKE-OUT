import React from 'react';
import { useNavigate } from 'react-router-dom';
import './SettingsPage.css';

const SettingsPage = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Clear user token from local storage
    localStorage.removeItem('token');
    // Redirect to login page
    navigate('/login');
  };

  return (
    <div className="settings-page">
      <h1>设置</h1>
      <div className="settings-section">
        <div className="settings-item">
          <span>账号安全</span>
          <span>&gt;</span>
        </div>
        <div className="settings-item">
          <span>隐私设置</span>
          <span>&gt;</span>
        </div>
        <div className="settings-item">
          <span>关于我们</span>
          <span>&gt;</span>
        </div>
      </div>
      <div className="logout-section">
        <button onClick={handleLogout} className="logout-button">
          退出登录
        </button>
      </div>
    </div>
  );
};

export default SettingsPage;
