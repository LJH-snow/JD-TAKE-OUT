import React, { useState, useEffect } from 'react';
import { Card, Col, Row, Statistic, Spin, Alert, Typography, DatePicker } from 'antd';
import {
  UserAddOutlined,
  DollarCircleOutlined,
  ShoppingCartOutlined,
  CheckCircleOutlined,
  CalculatorOutlined
} from '@ant-design/icons';
import dayjs from 'dayjs';
import apiClient from '../api';
import SalesChart from '../components/SalesChart';
import DishRankingChart from '../components/DishRankingChart';
import CategoryPieChart from '../components/CategoryPieChart';

const { Title } = Typography;
const { RangePicker } = DatePicker;

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [dateRange, setDateRange] = useState([dayjs().subtract(29, 'days'), dayjs()]);

  useEffect(() => {
    const fetchStats = async () => {
      if (!dateRange || dateRange.length !== 2) return;
      try {
        setLoading(true);
        const startDate = dateRange[0].format('YYYY-MM-DD');
        const endDate = dateRange[1].format('YYYY-MM-DD');
        const response = await apiClient.get(`/admin/dashboard/overview?start=${startDate}&end=${endDate}`);
        if (response.data && response.data.code === 200) {
          setStats(response.data.data);
        } else {
          throw new Error(response.data.message || '获取数据格式不正确');
        }
      } catch (e) {
        setError(e.message);
        console.error("获取统计数据失败:", e);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, [dateRange]);

  const handleDateRangeChange = (dates) => {
    if (dates) {
      setDateRange(dates);
    }
  };

  const disabledDate = (current) => {
    return current && current > dayjs().endOf('day');
  };

  const rangePresets = [
    { label: '今日', value: [dayjs(), dayjs()] },
    { label: '近7天', value: [dayjs().subtract(6, 'days'), dayjs()] },
    { label: '近30天', value: [dayjs().subtract(29, 'days'), dayjs()] },
    { label: '本月', value: [dayjs().startOf('month'), dayjs().endOf('month')] },
    { label: '近半年', value: [dayjs().subtract(6, 'months'), dayjs()] },
  ];

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <Title level={4} style={{ margin: 0 }}>数据看板</Title>
        <RangePicker 
          presets={rangePresets} 
          onChange={handleDateRangeChange} 
          defaultValue={dateRange} 
          disabledDate={disabledDate}
        />
      </div>
      {loading && <Spin tip="加载中..." size="large" style={{ display: 'block', marginTop: '50px' }} />}
      {!loading && error && (
        <>
          <Alert message="API请求错误" description={`无法加载仪表盘数据: ${error}。`} type="warning" showIcon style={{marginBottom: '16px'}}/>
          <DashboardContent stats={null} dateRange={dateRange} />
        </>
      )}
      {!loading && !error && <DashboardContent stats={stats} dateRange={dateRange} />}
    </div>
  );
};

const DashboardContent = ({ stats, dateRange }) => {
    return (
        <div>
          {stats && (
            <Row gutter={[16, 16]}>
              <Col xs={24} sm={12} lg={8} xl={4}>
                <Card className="stats-card card-revenue">
                  <DollarCircleOutlined className="stats-card-icon" />
                  <Statistic
                    title={`营业额 (${stats.date_range})`}
                    value={stats.total_revenue}
                    precision={2}
                    prefix="¥"
                  />
                </Card>
              </Col>
              <Col xs={24} sm={12} lg={8} xl={5}>
                <Card className="stats-card card-orders">
                  <ShoppingCartOutlined className="stats-card-icon" />
                  <Statistic
                    title="有效订单"
                    value={stats.valid_orders}
                    suffix="单"
                  />
                </Card>
              </Col>
              <Col xs={24} sm={12} lg={8} xl={5}>
                <Card className="stats-card card-completion">
                  <CheckCircleOutlined className="stats-card-icon" />
                  <Statistic
                    title="订单完成率"
                    value={stats.completion_rate}
                    precision={2}
                    suffix="%"
                  />
                </Card>
              </Col>
              <Col xs={24} sm={12} lg={8} xl={5}>
                <Card className="stats-card card-price">
                  <CalculatorOutlined className="stats-card-icon" />
                  <Statistic
                    title="平均单价"
                    value={stats.average_price}
                    precision={2}
                    prefix="¥"
                  />
                </Card>
              </Col>
              <Col xs={24} sm={12} lg={8} xl={5}>
                <Card className="stats-card card-users">
                  <UserAddOutlined className="stats-card-icon" />
                  <Statistic
                    title="新增用户"
                    value={stats.new_users}
                  />
                </Card>
              </Col>
            </Row>
          )}

          <Row style={{ marginTop: '24px' }}>
            <Col span={24}>
                <Card title="销售趋势">
                    <SalesChart dateRange={dateRange} />
                </Card>
            </Col>
          </Row>

          <Row gutter={[24, 24]} style={{ marginTop: '24px' }}>
            <Col xs={24} lg={12}>
              <Card title="热销菜品Top10">
                <DishRankingChart dateRange={dateRange} />
              </Card>
            </Col>
            <Col xs={24} lg={12}>
              <Card title="分类销售占比">
                <CategoryPieChart dateRange={dateRange} />
              </Card>
            </Col>
          </Row>
        </div>
    )
}

export default Dashboard;
