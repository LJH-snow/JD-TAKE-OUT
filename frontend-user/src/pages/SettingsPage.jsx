import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import './SettingsPage.css';

const SettingsPage = () => {
  const navigate = useNavigate();
  const auth = useAuth();

  const handleLogout = () => {
    auth.logout();
    navigate('/login', { replace: true });
  };

  return (
    <div className="settings-page">
      <header className="settings-header">
        <Link to="/profile" className="back-button">&lt;</Link>
        <h1>设置</h1>
      </header>
      <div className="settings-section">
        <Link to="/settings/account-security" className="settings-item">
          <span>账号安全</span>
          <span>&gt;</span>
        </Link>
        <Link to="/settings/privacy" className="settings-item">
          <span>隐私设置</span>
          <span>&gt;</span>
        </Link>
        <Link to="/settings/about" className="settings-item">
          <span>关于我们</span>
          <span>&gt;</span>
        </Link>
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