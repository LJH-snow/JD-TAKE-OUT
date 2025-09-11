import React from 'react';
import { NavBar } from 'antd-mobile';
import { useNavigate } from 'react-router-dom';

const CheckoutPage = () => {
  const navigate = useNavigate();
  return (
    <div>
      <NavBar onBack={() => navigate(-1)}>结算</NavBar>
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <p>这是结算页面，您可以在这里确认订单并进行支付。</p>
        <p>功能待开发...</p>
      </div>
    </div>
  );
};

export default CheckoutPage;
