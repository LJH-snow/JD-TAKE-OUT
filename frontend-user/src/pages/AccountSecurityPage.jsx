import React from 'react';
import { Link } from 'react-router-dom';
import './AccountSecurityPage.css';

const AccountSecurityPage = () => {

  const handleChangePassword = () => {
    alert('修改密码功能需要后端API支持，目前为演示状态。');
  };

  const handleManageDevices = () => {
    alert('登录设备管理功能需要后端API支持，目前为演示状态。');
  };

  const handleDeleteAccount = () => {
    if (window.confirm('您确定要注销您的账号吗？此操作不可逆，您的所有数据都将被永久删除。')) {
      alert('账号注销功能需要后端API支持，目前为演示状态。');
    }
  };

  return (
    <div className="account-security-page">
      <header className="security-header">
        <Link to="/settings" className="back-button">&lt;</Link>
        <h1>账号与安全</h1>
      </header>
      <main className="security-content">
        <div className="security-section">
          <div className="security-item" onClick={handleChangePassword}>
            <span>修改密码</span>
            <span>&gt;</span>
          </div>
          <div className="security-item" onClick={handleManageDevices}>
            <span>登录设备管理</span>
            <span>&gt;</span>
          </div>
        </div>
        <div className="security-section">
          <div className="security-item danger-item" onClick={handleDeleteAccount}>
            <span>注销账号</span>
            <span>&gt;</span>
          </div>
        </div>
      </main>
    </div>
  );
};

export default AccountSecurityPage;
