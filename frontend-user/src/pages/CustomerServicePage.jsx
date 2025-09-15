import React from 'react';
import { Link } from 'react-router-dom';
import './CustomerServicePage.css';

const CustomerServicePage = () => {
  return (
    <div className="customer-service-page">
      <header className="service-header">
        <Link to="/profile" className="back-button">&lt;</Link>
        <h1>客户服务中心</h1>
      </header>
      <main className="service-content">
        <div className="service-card">
          <h2><span role="img" aria-label="chat">💬</span> 在线客服</h2>
          <p>服务时间：工作日 9:00 - 21:00</p>
          <button 
            className="service-button"
            onClick={() => alert('在线客服功能即将上线，敬请期待！')}
          >
            立即咨询
          </button>
        </div>

        <div className="service-card">
          <h2><span role="img" aria-label="phone">📞</span> 客服热线</h2>
          <p>如有任何问题，欢迎随时致电我们。</p>
          <a href="tel:400-123-4567" className="service-button phone-button">
            400-123-4567
          </a>
        </div>

        <div className="service-card">
          <h2><span role="img" aria-label="email">✉️</span> 电子邮箱</h2>
          <p>您也可以通过邮件联系我们，我们会在24小时内回复。</p>
          <a href="mailto:support@jddelivery.com" className="service-button email-button">
            support@jddelivery.com
          </a>
        </div>
      </main>
    </div>
  );
};

export default CustomerServicePage;
