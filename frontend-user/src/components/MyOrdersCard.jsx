import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
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
        // 注意：此API后端尚未实现，此处为前端预备代码
        // const response = await apiClient.get('/api/user/orders/status-counts');
        // if (response.data && response.data.code === 200) {
        //   setOrderCounts(response.data.data);
        // }

        // --- 使用模拟数据 --- (后端API就绪后请删除此部分)
        const mockData = {
          pendingPayment: 2, // 待付款
          pendingShipment: 0, // 待发货
          delivering: 1, // 待收货
          pendingReview: 3, // 待评价
          refund: 0, // 退款/售后
        };
        setOrderCounts(mockData);
        // --- 模拟数据结束 ---

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
