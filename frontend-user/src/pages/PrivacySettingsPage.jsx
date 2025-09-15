import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import './PrivacySettingsPage.css';

// Mock Switch component for demonstration
const Switch = ({ checked, onChange }) => (
  <label className="switch">
    <input type="checkbox" checked={checked} onChange={onChange} />
    <span className="slider round"></span>
  </label>
);

const PrivacySettingsPage = () => {
  const [isPersonalized, setIsPersonalized] = useState(true);

  const handleDownloadData = () => {
    alert('数据下载功能正在开发中。');
  };

  const handleDeleteAccount = () => {
    if (window.confirm('您确定要注销您的账号吗？此操作不可逆，您的所有数据都将被永久删除。')) {
      alert('账号注销功能需要后端API支持，目前为演示状态。');
      // In a real app, you would call a backend API here
      // e.g., deleteAccount().then(() => navigate('/login'));
    }
  };

  return (
    <div className="privacy-settings-page">
      <header className="privacy-header">
        <Link to="/settings" className="back-button">&lt;</Link>
        <h1>隐私设置</h1>
      </header>
      <main className="privacy-content">
        <div className="privacy-section">
          <div className="privacy-item">
            <div>
              <h4>个性化内容推荐</h4>
              <p>根据您的浏览和购买历史，为您推荐更感兴趣的菜品。</p>
            </div>
            <Switch checked={isPersonalized} onChange={() => setIsPersonalized(!isPersonalized)} />
          </div>
        </div>

        <div className="privacy-section">
          <div className="privacy-item" onClick={() => alert('管理应用权限请在您的手机系统设置中操作。')}>
            <h4>应用权限管理</h4>
            <span>&gt;</span>
          </div>
        </div>

        <div className="privacy-section">
          <div className="privacy-item" onClick={handleDownloadData}>
            <h4>下载我的数据</h4>
            <span>&gt;</span>
          </div>
          <div className="privacy-item" onClick={handleDeleteAccount}>
            <h4>注销账号</h4>
            <span>&gt;</span>
          </div>
        </div>

        <div className="privacy-section">
           <div className="privacy-item">
            <a href="#" onClick={(e) => e.preventDefault()} style={{ textDecoration: 'none', color: 'inherit', width: '100%' }}>
              隐私政策全文
            </a>
            <span>&gt;</span>
          </div>
        </div>
      </main>
    </div>
  );
};

export default PrivacySettingsPage;
