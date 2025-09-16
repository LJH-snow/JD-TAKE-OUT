import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { queryPaymentStatus } from '../api';
import './PaymentResultPage.css';

const PaymentResultPage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [paymentStatus, setPaymentStatus] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // 从URL参数中获取订单ID
    const urlParams = new URLSearchParams(location.search);
    const orderId = urlParams.get('order_id');
    
    if (orderId) {
      checkPaymentStatus(orderId);
    } else {
      setLoading(false);
    }
  }, [location]);

  const checkPaymentStatus = async (orderId) => {
    try {
      const response = await queryPaymentStatus(orderId);
      if (response.data && response.data.code === 200) {
        setPaymentStatus(response.data.data);
      }
    } catch (error) {
      console.error('查询支付状态失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleGoToOrders = () => {
    navigate('/orders');
  };

  const handleGoHome = () => {
    navigate('/');
  };

  if (loading) {
    return (
      <div className="payment-result-page">
        <div className="result-container">
          <div className="loading">
            <div className="spinner"></div>
            <p>正在查询支付状态...</p>
          </div>
        </div>
      </div>
    );
  }

  const isSuccess = paymentStatus?.pay_status === 1;

  return (
    <div className="payment-result-page">
      <div className="result-container">
        <div className={`result-icon ${isSuccess ? 'success' : 'failed'}`}>
          {isSuccess ? '✓' : '✗'}
        </div>
        
        <h2 className="result-title">
          {isSuccess ? '支付成功！' : '支付失败'}
        </h2>
        
        <p className="result-message">
          {isSuccess 
            ? '您的订单已成功支付，我们会尽快为您处理' 
            : '支付过程中出现问题，请重新尝试支付'
          }
        </p>

        {paymentStatus && (
          <div className="order-info">
            <div className="info-item">
              <span className="label">订单号：</span>
              <span className="value">{paymentStatus.order_id}</span>
            </div>
            <div className="info-item">
              <span className="label">支付状态：</span>
              <span className={`value status ${isSuccess ? 'success' : 'failed'}`}>
                {isSuccess ? '已支付' : '未支付'}
              </span>
            </div>
            {paymentStatus.pay_time && (
              <div className="info-item">
                <span className="label">支付时间：</span>
                <span className="value">
                  {new Date(paymentStatus.pay_time).toLocaleString()}
                </span>
              </div>
            )}
          </div>
        )}

        <div className="action-buttons">
          <button className="btn secondary" onClick={handleGoToOrders}>
            查看订单
          </button>
          <button className="btn primary" onClick={handleGoHome}>
            返回首页
          </button>
        </div>
      </div>
    </div>
  );
};

export default PaymentResultPage;

