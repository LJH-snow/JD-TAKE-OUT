import React, { useState, useEffect } from 'react';
import { Card, Col, Row, Statistic, Spin, Alert, Typography, Progress } from 'antd';
import {
  ShoppingCartOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
  CloseCircleOutlined,
  DollarCircleOutlined,
} from '@ant-design/icons';
import dayjs from 'dayjs';
import apiClient from '../api';

const { Title } = Typography;

const EmployeeDashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchTodayStats = async () => {
      try {
        setLoading(true);
        const response = await apiClient.get('/employee/stats/orders/today');
        if (response.data && response.data.code === 200) {
          setStats(response.data.data);
        } else {
          throw new Error(response.data.message || '获取数据失败');
        }
      } catch (e) {
        setError(e.message);
        console.error("获取今日统计数据失败:", e);
      } finally {
        setLoading(false);
      }
    };

    fetchTodayStats();
    
    // 每30秒刷新一次数据
    const interval = setInterval(fetchTodayStats, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '400px' }}>
        <Spin size="large" tip="加载今日数据中..." />
      </div>
    );
  }

  if (error) {
    return (
      <Alert
        message="数据加载失败"
        description={error}
        type="error"
        showIcon
        style={{ margin: '20px 0' }}
      />
    );
  }

  return (
    <div>
      <Title level={2} style={{ marginBottom: 24 }}>
        📊 今日工作概览 - {dayjs().format('YYYY年MM月DD日')}
      </Title>
      
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="今日订单总数"
              value={stats?.total_orders || 0}
              prefix={<ShoppingCartOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="已完成订单"
              value={stats?.completed_orders || 0}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="待处理订单"
              value={stats?.pending_orders || 0}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="已取消订单"
              value={stats?.cancelled_orders || 0}
              prefix={<CloseCircleOutlined />}
              valueStyle={{ color: '#ff4d4f' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginTop: 16 }}>
        <Col xs={24} lg={12}>
          <Card title="今日营业额">
            <Statistic
              value={stats?.total_revenue || 0}
              precision={2}
              prefix={<DollarCircleOutlined />}
              suffix="元"
              valueStyle={{ color: '#52c41a', fontSize: '24px' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} lg={12}>
          <Card title="订单完成率">
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <Progress
                type="circle"
                percent={Math.round(stats?.completion_rate || 0)}
                format={percent => `${percent}%`}
                strokeColor={{
                  '0%': '#108ee9',
                  '100%': '#87d068',
                }}
                style={{ marginRight: 16 }}
              />
              <div>
                <div style={{ fontSize: '16px', fontWeight: 'bold' }}>
                  {Math.round(stats?.completion_rate || 0)}%
                </div>
                <div style={{ color: '#666', fontSize: '12px' }}>
                  完成率
                </div>
              </div>
            </div>
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginTop: 16 }}>
        <Col span={24}>
          <Card title="📋 工作提醒" size="small">
            <div style={{ padding: '16px 0' }}>
              {stats?.pending_orders > 0 ? (
                <Alert
                  message={`您有 ${stats.pending_orders} 个订单待处理`}
                  description="请及时查看订单管理页面，处理待接单的订单。"
                  type="warning"
                  showIcon
                  style={{ marginBottom: 8 }}
                />
              ) : (
                <Alert
                  message="暂无待处理订单"
                  description="当前所有订单都已处理完成，保持良好工作状态！"
                  type="success"
                  showIcon
                  style={{ marginBottom: 8 }}
                />
              )}
              
              <div style={{ 
                background: '#f6f6f6', 
                padding: '12px', 
                borderRadius: '6px',
                fontSize: '12px',
                color: '#666'
              }}>
                💡 小贴士：数据每30秒自动刷新，您也可以刷新页面获取最新数据
              </div>
            </div>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default EmployeeDashboard;