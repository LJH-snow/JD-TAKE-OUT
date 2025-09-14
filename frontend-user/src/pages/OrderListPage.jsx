import React, { useState, useEffect } from 'react';
import { useLocation, Link, useNavigate } from 'react-router-dom';
import { listUserOrders, cancelOrder, confirmOrder } from '../api'; // 假设api.js会添加cancel和confirm函数
import './OrderListPage.css';

// 辅助函数：从 URL 查询字符串中获取参数
function useQuery() {
  return new URLSearchParams(useLocation().search);
}

const OrderStatusTabs = ({ currentStatus }) => {
  const navigate = useNavigate();
  const statuses = [
    { name: '全部', status: '' },
    { name: '待付款', status: '1' },
    { name: '待发货', status: '2' },
    { name: '待收货', status: '4' },
    { name: '待评价', status: '5' },
    { name: '退款/售后', status: '6' },
  ];

  const handleTabClick = (status) => {
    navigate(`/orders?status=${status}`);
  };

  return (
    <div className="status-tabs">
      {statuses.map(s => (
        <button 
          key={s.name} 
          className={`tab-item ${(!currentStatus && s.status === '') || currentStatus === s.status ? 'active' : ''}`}
          onClick={() => handleTabClick(s.status)}
        >
          {s.name}
        </button>
      ))}
    </div>
  );
};

const OrderCard = ({ order, onActionSuccess }) => {

  const handleCancel = async (e) => {
    e.preventDefault(); // 阻止Link的跳转
    if (window.confirm('您确定要取消这个订单吗？')) {
      try {
        await cancelOrder(order.id);
        alert('订单已取消');
        onActionSuccess(); // 通知父组件刷新列表
      } catch (error) {
        alert('取消订单失败，请稍后再试');
      }
    }
  };

  const handleConfirm = async (e) => {
    e.preventDefault();
    if (window.confirm('请确认您已收到商品。')) {
      try {
        await confirmOrder(order.id);
        alert('操作成功！');
        onActionSuccess();
      } catch (error) {
        alert('确认收货失败，请稍后再试');
      }
    }
  };

  const getStatusText = (statusCode) => {
    const statusMap = { 1: '待付款', 2: '待接单', 3: '已接单', 4: '派送中', 5: '已完成', 6: '已取消' };
    return statusMap[statusCode] || '未知状态';
  };

  const renderActionButtons = () => {
    switch (order.status) {
      case 1: // 待付款
        return (
          <>
            <button className="action-btn secondary" onClick={handleCancel}>取消订单</button>
            <button className="action-btn primary">去支付</button>
          </>
        );
      case 3: // 已接单
      case 4: // 派送中
        return <button className="action-btn primary" onClick={handleConfirm}>确认收货</button>;
      case 5: // 已完成
        return <button className="action-btn secondary">再次购买</button>;
      default:
        return null;
    }
  };

  return (
    <Link to={`/orders/${order.id}`} className="order-card-link">
      <div className="order-card-header">
        <span className="shop-name">本店</span>
        <span className="order-status">{getStatusText(order.status)}</span>
      </div>
      <div className="order-card-body">
        {order.order_details?.slice(0, 1).map(detail => (
          <div key={detail.id} className="item-summary">
            <img 
              src={detail.image ? (detail.image.startsWith('http') ? detail.image : `http://localhost:8090${detail.image}`) : 'https://via.placeholder.com/80'} 
              alt={detail.name} 
              className="item-thumbnail" 
            />
            <p className="item-name-brief">{detail.name} 等{order.order_details.length}件商品</p>
          </div>
        ))}
      </div>
      <div className="order-card-footer">
        <span className="total-amount">合计 ¥{order.amount.toFixed(2)}</span>
        <div className="action-buttons">
          {renderActionButtons()}
        </div>
      </div>
    </Link>
  );
};

const OrderListPage = () => {
  const query = useQuery();
  const status = query.get('status') || '';

  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [page, setPage] = useState(1);
  const [pageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [refreshKey, setRefreshKey] = useState(0); // 用于强制刷新

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        setError('');
        const params = { page, pageSize };
        if (status) {
          // 根据新的正确逻辑进行状态映射
          if (status === '2') { // 前端的“待发货”
            params.status = [2, 3]; // 对应后端的“待接单”和“已接单”
          } else {
            params.status = [status]; // 确保始终传递数组
          }
        }

        const response = await listUserOrders(params);
        if (response.data && response.data.code === 200) {
          setOrders(response.data.data.items || []);
          setTotal(response.data.data.total || 0);
        } else {
          setError(response.data.message || '获取订单列表失败');
        }
      } catch (err) {
        setError(err.response?.data?.message || '加载数据失败，请稍后再试');
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [page, pageSize, status, refreshKey]);

  const totalPages = Math.ceil(total / pageSize);

  return (
    <div className="order-list-page">
      <header className="list-header">
        <Link to="/profile" className="back-link">&lt;</Link>
        <h1>我的订单</h1>
      </header>
      <OrderStatusTabs currentStatus={status} />
      <div className="orders-container">
        {loading && <p>加载中...</p>}
        {error && <p className="error-message">错误: {error}</p>}
        {!loading && !error && orders.length === 0 && <p>没有找到相关订单。</p>}
        {!loading && !error && orders.map(order => (
          <OrderCard key={order.id} order={order} onActionSuccess={() => setRefreshKey(k => k + 1)} />
        ))}
      </div>
      {totalPages > 1 && (
        <div className="pagination">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}>上一页</button>
          <span>第 {page} / {totalPages} 页</span>
          <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages}>下一页</button>
        </div>
      )}
    </div>
  );
};

export default OrderListPage;
