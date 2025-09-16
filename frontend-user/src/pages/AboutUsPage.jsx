import React from 'react';
import { Link } from 'react-router-dom';
import './AboutUsPage.css';

const AboutUsPage = () => {
  return (
    <div className="about-us-page">
      <header className="about-header">
        <Link to="/settings" className="back-button">&lt;</Link>
        <h1>关于我们</h1>
      </header>
      <main className="about-content">
        <div className="logo-container">
          <img src="/images/logos/JDwaimai.png" alt="App Logo" className="app-logo" />
          <h2>JD外卖</h2>
          <p className="app-version">Version 1.0.0</p>
        </div>
        <div className="about-section">
          <h3>品牌故事</h3>
          <p>
            “JD外卖”致力于为用户提供最便捷、最可靠的本地餐饮配送服务。我们相信，美食不仅是味蕾的享受，更是连接人与文化的纽带。我们的使命是“快马加鞭，美食必达”，让您足不出户，尽享天下美味。
          </p>
        </div>
        <div className="about-section links-section">
          <a href="#" onClick={(e) => e.preventDefault()}>用户服务协议</a>
          <a href="#" onClick={(e) => e.preventDefault()}>隐私政策</a>
        </div>
      </main>
      <footer className="about-footer">
        <p>© 2025 JD-Delivery Inc. All Rights Reserved.</p>
      </footer>
    </div>
  );
};

export default AboutUsPage;
