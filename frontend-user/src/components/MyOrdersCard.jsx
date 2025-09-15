import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getUserOrderCounts } from '../api/index';
import './MyOrdersCard.css';

// 假设的图标组件，实际项目中应替换为真实的图标库（如 antd/icons）
const Icon = ({ name }) => <i className={`icon-${name}`}></i>;

const MyOrdersCard = () => {
  // 将订单状态的 count 初始化为 0
  const [orderCounts, setOrderCounts] = useState({
    pendingPayment: 0, // 待付款
    pendingShipment: 0, // 待发货
    delivering: 0, // 待收货
    pendingReview: 0, // 待评价
    refund: 0, // 退款/售后
  });

  useEffect(() => {
    const fetchOrderStatusCounts = async () => {
      try {
        const res = await getUserOrderCounts();
        if (res?.data?.code === 200 && res?.data?.data) {
          const d = res.data.data;
          setOrderCounts({
            pendingPayment: d.pending || 0,
            pendingShipment: d.waiting || 0,
            delivering: d.delivering || 0,
            pendingReview: d.completed || 0,
            refund: d.refunded || 0,
          });
        }
      } catch (error) {
        console.error("获取订单状态数量失败:", error);
      }
    };

    fetchOrderStatusCounts();
  }, []);

  const orderStatuses = [
    { name: '待付款', icon: '💰', link: '/orders?status=1', count: orderCounts.pendingPayment },
    { name: '待发货', icon: '📦', link: '/orders?status=2', count: orderCounts.pendingShipment },
    { name: '待收货', icon: '🚚', link: '/orders?status=4', count: orderCounts.delivering },
    { name: '待评价', icon: '✍️', link: '/orders?status=5', count: orderCounts.pendingReview },
    { name: '退款/售后', icon: '↩️', link: '/orders?status=6', count: orderCounts.refund },
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
