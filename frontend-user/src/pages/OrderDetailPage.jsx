import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { getOrderDetail, cancelOrder, confirmOrder } from '../api';
import DeliveryMap from '../components/DeliveryMap';
import './OrderDetailPage.css';

const OrderDetailPage = () => {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const fetchOrderDetail = async () => {
    try {
      setLoading(true);
      const response = await getOrderDetail(id);
      if (response.data && response.data.code === 200) {
        setOrder(response.data.data);
      } else {
        setError(response.data.message || '获取订单详情失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '加载数据失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrderDetail();
  }, [id]);

  const handleCancel = async () => {
    if (window.confirm('您确定要取消这个订单吗？')) {
      try {
        await cancelOrder(id);
        alert('订单已取消');
        fetchOrderDetail(); // Refresh order details
      } catch (error) {
        alert('取消订单失败，请稍后再试');
      }
    }
  };

  const handleConfirm = async () => {
    if (window.confirm('请确认您已收到商品。')) {
      try {
        await confirmOrder(id);
        alert('操作成功！');
        fetchOrderDetail(); // Refresh order details
      } catch (error) {
        alert('确认收货失败，请稍后再试');
      }
    }
  };

  const handleGoToPay = () => {
    alert('支付功能正在开发中...');
  };

  const getStatusText = (statusCode) => {
    const statusMap = { 1: '待付款', 2: '待接单', 3: '已接单', 4: '派送中', 5: '已完成', 6: '已取消' };
    return statusMap[statusCode] || '未知状态';
  };

  if (loading) return <div className="order-detail-page"><p>加载中...</p></div>;
  if (error) return <div className="order-detail-page error-message"><p>错误: {error}</p></div>;
  if (!order) return <div className="order-detail-page"><p>未找到订单。</p></div>;

  const subtotal = order.order_details.reduce((sum, item) => sum + item.amount, 0);

  return (
    <div className="order-detail-page">
      <header className="detail-header">
        <Link to="/orders" className="back-link">&lt; 返回列表</Link>
        <h1>订单详情</h1>
      </header>

      <DeliveryMap order={order} />

      <div className="detail-card status-section">
        <h2>{getStatusText(order.status)}</h2>
        {order.status === 4 && order.estimated_delivery_time && (
          <p>预计送达时间: {new Date(order.estimated_delivery_time).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' })}</p>
        )}
        {order.status === 1 && (
          <p>请在下单后30分钟内完成支付，超时订单将自动取消。</p>
        )}
      </div>

      <div className="detail-card address-section">
        <h3>收货信息</h3>
        <p><strong>地址:</strong> {order.address}</p>
        <p><strong>收货人:</strong> {order.consignee} ({order.phone})</p>
      </div>

      <div className="detail-card items-section">
        <h3>商品清单</h3>
        {order.order_details.map(item => (
          <div key={item.id} className="item-row">
            <img src={item.image || 'https://via.placeholder.com/60'} alt={item.name} className="item-image" />
            <div className="item-info">
              <p className="item-name">{item.name}</p>
              <p className="item-quantity">x {item.number}</p>
            </div>
            <p className="item-amount">¥{item.amount.toFixed(2)}</p>
          </div>
        ))}
      </div>

      <div className="detail-card cost-section">
        <h3>费用明细</h3>
        <div className="cost-row"><span>商品总价</span><span>¥{subtotal.toFixed(2)}</span></div>
        <div className="cost-row"><span>打包费</span><span>¥{order.pack_amount.toFixed(2)}</span></div>
        <div className="cost-row"><span>餐具费</span><span>¥{order.tableware_number.toFixed(2)}</span></div>
        <hr />
        <div className="cost-row total">
          <strong>{order.pay_status === 0 ? '应付金额' : '实付金额'}</strong>
          <strong>¥{order.amount.toFixed(2)}</strong>
        </div>
      </div>

      <div className="detail-card order-info-section">
        <h3>订单信息</h3>
        <p><strong>订单编号:</strong> {order.number}</p>
        <p><strong>下单时间:</strong> {new Date(order.order_time).toLocaleString()}</p>
        <p><strong>备注:</strong> {order.remark || '无'}</p>
      </div>

      <footer className="detail-footer-actions">
        {order.status === 4 && <button className="action-button primary" onClick={handleConfirm}>确认收货</button>}
        {order.status === 1 && <button className="action-button primary" onClick={handleGoToPay}>去支付</button>}
        {order.status === 1 && <button className="action-button secondary" onClick={handleCancel}>取消订单</button>}
      </footer>
    </div>
  );
};

export default OrderDetailPage;
