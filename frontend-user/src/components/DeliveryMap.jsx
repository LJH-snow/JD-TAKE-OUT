import React from 'react';
import './DeliveryMap.css';

const DeliveryMap = ({ order }) => {
  if (!order || !order.status) {
    return null;
  }

  const { status, estimated_delivery_time } = order;

  // 只在特定状态下显示此模块
  if (![3, 4, 5].includes(status)) {
    return null;
  }

  // 状态3: 已接单 -> 商家备餐中
  if (status === 3) {
    return (
      <div className="delivery-card status-preparing">
        <h3>商家正在备餐中</h3>
        <p>美味正在烹饪，请耐心等待骑手接单</p>
      </div>
    );
  }

  // 状态4: 派送中 -> 显示模拟地图和骑手信息
  if (status === 4) {
    return (
      <div className="delivery-card status-delivering">
        <div className="map-placeholder">
          <div className="route-line"></div>
          <div className="shop-marker">🏪</div>
          <div className="rider-marker">🚴</div>
          <div className="user-marker">🏠</div>
        </div>
        <div className="delivery-info">
          <h3>骑手正在火速配送中</h3>
          <p>预计送达时间: {new Date(estimated_delivery_time).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' })}</p>
        </div>
      </div>
    );
  }

  // 状态5: 已完成 -> 显示送达提示
  if (status === 5) {
    return (
      <div className="delivery-card status-completed">
        <h3>订单已送达</h3>
        <p>感谢您的信任，期待再次光临！</p>
      </div>
    );
  }

  return null;
};

export default DeliveryMap;
