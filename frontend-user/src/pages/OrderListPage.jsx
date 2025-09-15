import React, { useState, useEffect, useMemo } from 'react';
import { useLocation, Link, useNavigate } from 'react-router-dom';
import { listUserOrders, cancelOrder, confirmOrder, getUserOrderStats, deleteUserOrder } from '../api';
import ReactECharts from 'echarts-for-react';
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

  const handleDelete = async (e) => {
    e.preventDefault();
    if (window.confirm('删除后将无法恢复，确定删除该订单吗？')) {
      try {
        await deleteUserOrder(order.id);
        alert('删除成功');
        onActionSuccess();
      } catch (error) {
        alert(error.response?.data?.message || '删除失败，请稍后再试');
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
        return (
          <>
            <button className="action-btn secondary">再次购买</button>
            <button className="action-btn" onClick={handleDelete}>删除</button>
          </>
        );
      case 6: // 已取消
        return (
          <>
            <button className="action-btn" onClick={handleDelete}>删除</button>
          </>
        );
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
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [stats, setStats] = useState({ total_amount: 0, order_count: 0, daily: [] });
  const [quickRange, setQuickRange] = useState('7d'); // 7d | 30d | month | custom

  // 初始化默认日期为近7天
  useEffect(() => {
    const today = new Date();
    const to = today.toISOString().slice(0, 10);
    const fromDate = new Date();
    fromDate.setDate(today.getDate() - 6);
    const from = fromDate.toISOString().slice(0, 10);
    setDateFrom(from);
    setDateTo(to);
    setQuickRange('7d');
  }, []);

  const applyQuickRange = (type) => {
    const today = new Date();
    const to = today.toISOString().slice(0, 10);
    let from = '';
    if (type === '7d') {
      const d = new Date();
      d.setDate(today.getDate() - 6);
      from = d.toISOString().slice(0, 10);
    } else if (type === '30d') {
      const d = new Date();
      d.setDate(today.getDate() - 29);
      from = d.toISOString().slice(0, 10);
    } else if (type === 'month') {
      const first = new Date(today.getFullYear(), today.getMonth(), 1);
      from = first.toISOString().slice(0, 10);
    }
    setQuickRange(type);
    if (type === 'custom') return; // 自定义模式下由输入框决定
    setDateFrom(from);
    setDateTo(to);
  };

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
        if (dateFrom && dateTo) {
          params.date_from = dateFrom;
          params.date_to = dateTo;
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
  }, [page, pageSize, status, refreshKey, dateFrom, dateTo]);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const params = {};
        if (dateFrom && dateTo) {
          params.date_from = dateFrom;
          params.date_to = dateTo;
        }
        const res = await getUserOrderStats(params);
        if (res?.data?.code === 200) {
          setStats(res.data.data || { total_amount: 0, order_count: 0, daily: [] });
        }
      } catch (e) {
        // 忽略统计错误，避免影响主流程
      }
    };
    fetchStats();
  }, [dateFrom, dateTo, refreshKey]);

  const chartOption = useMemo(() => {
    const dates = (stats.daily || []).map(d => d.date);
    const orderCounts = (stats.daily || []).map(d => d.order_count);
    const amounts = (stats.daily || []).map(d => Number(d.amount || 0).toFixed(2));
    return {
      tooltip: {
        trigger: 'axis',
      },
      grid: { left: 8, right: 8, top: 30, bottom: 40, containLabel: true },
      legend: { data: ['订单数', '金额'], bottom: 0 },
      xAxis: {
        type: 'category',
        data: dates,
        axisLabel: { rotate: dates.length > 7 ? 30 : 0 },
      },
      yAxis: [
        { type: 'value', name: '订单数', minInterval: 1 },
        { type: 'value', name: '金额(¥)' },
      ],
      dataZoom: [
        { type: 'inside', start: 0, end: 100 },
        { type: 'slider', start: 0, end: 100, height: 16 },
      ],
      series: [
        {
          name: '订单数',
          type: 'bar',
          data: orderCounts,
          barMaxWidth: 24,
          itemStyle: { color: '#91cc75' },
        },
        {
          name: '金额',
          type: 'line',
          yAxisIndex: 1,
          smooth: true,
          data: amounts,
          itemStyle: { color: '#5470c6' },
          symbolSize: 6,
        },
      ],
    };
  }, [stats]);

  const totalPages = Math.ceil(total / pageSize);

  return (
    <div className="order-list-page">
      <header className="list-header">
        <Link to="/profile" className="back-link">&lt;</Link>
        <h1>我的订单</h1>
      </header>
      <OrderStatusTabs currentStatus={status} />
      <div className="filters">
        <div className="quick-ranges">
          <button className={`qr-btn ${quickRange==='7d'?'active':''}`} onClick={() => applyQuickRange('7d')}>近7天</button>
          <button className={`qr-btn ${quickRange==='30d'?'active':''}`} onClick={() => applyQuickRange('30d')}>近30天</button>
          <button className={`qr-btn ${quickRange==='month'?'active':''}`} onClick={() => applyQuickRange('month')}>本月</button>
          <button className={`qr-btn ${quickRange==='custom'?'active':''}`} onClick={() => setQuickRange('custom')}>自定义</button>
        </div>
        {quickRange === 'custom' && (
          <div className="date-range">
            <input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} />
            <span style={{ margin: '0 8px' }}>至</span>
            <input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} />
            <button onClick={() => { setDateFrom(''); setDateTo(''); }}>清空</button>
          </div>
        )}
        <div className="stats-cards">
          <div className="stat-card">订单数：<strong>{stats.order_count}</strong></div>
          <div className="stat-card">总消费：<strong>¥{Number(stats.total_amount || 0).toFixed(2)}</strong></div>
        </div>
      </div>
      {stats.daily?.length > 0 && (
        <div className="chart-placeholder">
          <h3 style={{ margin: '6px 0 10px' }}>按日统计</h3>
          <ReactECharts option={chartOption} style={{ height: 240, width: '100%' }} notMerge lazyUpdate />
        </div>
      )}
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
