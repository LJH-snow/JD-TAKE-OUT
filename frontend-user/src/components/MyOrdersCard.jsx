import React from 'react';
import { Link } from 'react-router-dom';
import './MyOrdersCard.css';

// 假设的图标组件，实际项目中应替换为真实的图标库（如 antd/icons）
const Icon = ({ name }) => <i className={`icon-${name}`}></i>;

const MyOrdersCard = () => {
  // 根据开发文档，角标数量需要API支持，暂时为静态展示
  const orderStatuses = [
    { name: '待付款', icon: '💰', link: '/orders?status=1', count: 0 },
    { name: '待发货', icon: '📦', link: '/orders?status=2', count: 0 },
    { name: '待收货', icon: '🚚', link: '/orders?status=4', count: 0 },
    { name: '待评价', icon: '✍️', link: '/orders?status=5', count: 0 },
    { name: '退款/售后', icon: '↩️', link: '/orders?status=6', count: 0 },
  ];

  return (
    <div className="my-orders-card">
      <div className="card-header">
        <h3 className="card-title">我的订单</h3>
        <Link to="/orders" className="see-all-link">查看全部订单 &gt;</Link>
      </div>
      <div className="order-status-grid">
        {orderStatuses.map(status => (
          <Link to={status.link} key={status.name} className="status-item">
            {status.count > 0 && <span className="badge">{status.count}</span>}
            <div className="status-icon">{status.icon}</div>
            <p className="status-name">{status.name}</p>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default MyOrdersCard;
