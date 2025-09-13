import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getOrderDetail } from '../api';
import DeliveryMap from '../components/DeliveryMap';
import './OrderDetailPage.css';

const OrderDetailPage = () => {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchOrderDetail = async () => {
      try {
        setLoading(true);
        // const response = await getOrderDetail(id); // 等待API实现
        // mock data for frontend development
        const response = {
          data: {
            code: 200,
            data: {
              id: id,
              number: `SN-20250913-${id}`,
              status: 4, // 假设为派送中
              user_name: '测试用户',
              phone: '13800138000',
              address: '北京市朝阳区建国路88号',
              order_time: new Date().toISOString(),
              estimated_delivery_time: new Date(Date.now() + 30 * 60000).toISOString(),
              amount: 56.00,
              pack_amount: 2.00,
              tableware_number: 1,
              remark: '不要辣，谢谢！',
              order_details: [
                { id: 1, name: '宫保鸡丁', number: 1, amount: 28.00, image: '/images/dishes/dish1.jpg' },
                { id: 2, name: '米饭', number: 2, amount: 4.00, image: '/images/dishes/rice.jpg' },
              ],
            }
          }
        };

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

    fetchOrderDetail();
  }, [id]);

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

      {/* 配送地图/状态组件 */}
      <DeliveryMap order={order} />

      <div className="detail-card status-section">
        <h2>{getStatusText(order.status)}</h2>
        <p>预计送达时间: {new Date(order.estimated_delivery_time).toLocaleTimeString()}</p>
      </div>

      <div className="detail-card address-section">
        <h3>收货信息</h3>
        <p><strong>地址:</strong> {order.address}</p>
        <p><strong>收货人:</strong> {order.user_name} ({order.phone})</p>
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
        <div className="cost-row total"><strong>实付金额</strong><strong>¥{order.amount.toFixed(2)}</strong></div>
      </div>

      <div className="detail-card order-info-section">
        <h3>订单信息</h3>
        <p><strong>订单编号:</strong> {order.number}</p>
        <p><strong>下单时间:</strong> {new Date(order.order_time).toLocaleString()}</p>
        <p><strong>备注:</strong> {order.remark || '无'}</p>
      </div>

      <footer className="detail-footer-actions">
        {order.status === 4 && <button className="action-button primary">确认收货</button>}
        {order.status === 1 && <button className="action-button primary">去支付</button>}
        {order.status === 1 && <button className="action-button secondary">取消订单</button>}
      </footer>
    </div>
  );
};

export default OrderDetailPage;