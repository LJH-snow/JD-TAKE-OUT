import React, { useState, useEffect } from 'react';
import { Card, Col, Row, Statistic, Spin, Alert, Typography, DatePicker, Dropdown, Menu, App, Button } from 'antd';
import {
  UserAddOutlined,
  DollarCircleOutlined,
  ShoppingCartOutlined,
  CheckCircleOutlined,
  CalculatorOutlined,
  DownloadOutlined
} from '@ant-design/icons';
import dayjs from 'dayjs';
import apiClient from '../api';
import SalesChart from '../components/SalesChart';
import DishRankingChart from '../components/DishRankingChart';
import CategoryPieChart from '../components/CategoryPieChart';
import EmployeeDashboard from '../components/EmployeeDashboard';
import { useCurrentUser } from '../hooks/useCurrentUser';

const { Title } = Typography;
const { RangePicker } = DatePicker;

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [dateRange, setDateRange] = useState([dayjs().subtract(29, 'days'), dayjs()]);
  const { message } = App.useApp();
  const { currentUser } = useCurrentUser();

  useEffect(() => {
    const fetchStats = async () => {
      if (!currentUser) return;
      
      try {
        setLoading(true);
        
        if (currentUser.role === 'admin') {
          // 管理员获取完整的统计数据
          if (!dateRange || dateRange.length !== 2) return;
          const startDate = dateRange[0].format('YYYY-MM-DD');
          const endDate = dateRange[1].format('YYYY-MM-DD');
          const response = await apiClient.get(`/admin/dashboard/overview?start=${startDate}&end=${endDate}`);
          if (response.data && response.data.code === 200) {
            setStats(response.data.data);
          } else {
            throw new Error(response.data.message || '获取数据格式不正确');
          }
        } else {
          // 员工获取今日订单统计
          const response = await apiClient.get('/employee/stats/orders/today');
          if (response.data && response.data.code === 200) {
            // 将员工数据格式化为与管理员数据兼容的格式
            setStats({
              todayOrders: response.data.data.total_orders || 0,
              todayRevenue: response.data.data.total_revenue || 0,
              // 其他字段设为0或默认值
              totalOrders: 0,
              totalRevenue: 0,
            });
          } else {
            throw new Error(response.data.message || '获取数据格式不正确');
          }
        }
      } catch (e) {
        setError(e.message);
        console.error("获取统计数据失败:", e);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, [dateRange, currentUser]);

  const handleDateRangeChange = (dates) => {
    if (dates) {
      setDateRange(dates);
    }
  };

  const handleExport = async (config) => {
    const { type, format } = config;
    const key = 'exporting';
    message.loading({ content: `正在生成 ${format.toUpperCase()} 文件...`, key });

    try {
      const params = {
        start: dateRange[0].format('YYYY-MM-DD'),
        end: dateRange[1].format('YYYY-MM-DD'),
        format,
      };

      const response = await apiClient.get(`/admin/export/stats/${type}`, {
        params,
        responseType: 'blob',
      });

      const blob = new Blob([response.data], { type: response.headers['content-type'] });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;

      const contentDisposition = response.headers['content-disposition'];
      let filename = `${type}_${params.start}_to_${params.end}.${format}`;
      if (contentDisposition) {
        const filenameMatch = contentDisposition.match(/filename="?(.+)"?/);
        if (filenameMatch && filenameMatch.length > 1) {
          filename = filenameMatch[1];
        }
      }

      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();

      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
      message.success({ content: '文件已开始下载！', key, duration: 2 });

    } catch (error) {
      message.error({ content: '导出失败，请检查网络或联系管理员', key, duration: 2 });
      console.error("Export failed:", error);
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

  // 如果是员工，显示员工专用工作台
  if (currentUser?.role === 'employee') {
    return <EmployeeDashboard />;
  }

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
          <DashboardContent stats={null} dateRange={dateRange} onExport={handleExport} />
        </>
      )}
      {!loading && !error && <DashboardContent stats={stats} dateRange={dateRange} onExport={handleExport} />}
    </div>
  );
};

const ExportMenu = ({ onExport, type }) => (
  <Menu onClick={({ key }) => onExport({ type, format: key })}>
    <Menu.Item key="xlsx">导出为 Excel</Menu.Item>
    <Menu.Item key="csv">导出为 CSV</Menu.Item>
  </Menu>
);

const DashboardContent = ({ stats, dateRange, onExport }) => {
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
                <Card 
                  title="销售趋势"
                  extra={
                    <Dropdown overlay={<ExportMenu onExport={onExport} type="sales" />}>
                      <Button icon={<DownloadOutlined />}>导出数据</Button>
                    </Dropdown>
                  }
                >
                    <SalesChart dateRange={dateRange} />
                </Card>
            </Col>
          </Row>

          <Row gutter={[24, 24]} style={{ marginTop: '24px' }}>
            <Col xs={24} lg={12}>
              <Card 
                title="热销菜品Top10"
                extra={
                  <Dropdown overlay={<ExportMenu onExport={onExport} type="dishes" />}>
                    <Button icon={<DownloadOutlined />}>导出数据</Button>
                  </Dropdown>
                }
              >
                <DishRankingChart dateRange={dateRange} />
              </Card>
            </Col>
            <Col xs={24} lg={12}>
              <Card 
                title="分类销售占比"
                extra={
                  <Dropdown overlay={<ExportMenu onExport={onExport} type="categories" />}>
                    <Button icon={<DownloadOutlined />}>导出数据</Button>
                  </Dropdown>
                }
              >
                <CategoryPieChart dateRange={dateRange} />
              </Card>
            </Col>
          </Row>
        </div>
    )
}

export default Dashboard;