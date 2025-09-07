// 管理员端ECharts图表组件示例代码

// ============= 1. 数据概览卡片组件 =============
import React from 'react';
import { Card, Row, Col, Statistic } from 'antd';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons';

const StatsCards = ({ statsData }) => {
  const cards = [
    {
      title: '今日销售额',
      value: statsData?.todaySales || 0,
      change: statsData?.salesChange || 0,
      prefix: '¥',
      icon: '💰'
    },
    {
      title: '今日订单',
      value: statsData?.todayOrders || 0,
      change: statsData?.ordersChange || 0,
      suffix: '单',
      icon: '📋'
    },
    {
      title: '活跃用户',
      value: statsData?.activeUsers || 0,
      change: statsData?.usersChange || 0,
      suffix: '人',
      icon: '👥'
    },
    {
      title: '平均评分',
      value: statsData?.avgRating || 0,
      change: statsData?.ratingChange || 0,
      precision: 1,
      suffix: '分',
      icon: '⭐'
    }
  ];

  return (
    <Row gutter={16} style={{ marginBottom: 24 }}>
      {cards.map((card, index) => (
        <Col span={6} key={index}>
          <Card>
            <Statistic
              title={
                <span>
                  {card.icon} {card.title}
                </span>
              }
              value={card.value}
              precision={card.precision || 0}
              prefix={card.prefix}
              suffix={card.suffix}
              valueStyle={{
                color: card.change >= 0 ? '#3f8600' : '#cf1322',
                fontSize: '24px',
                fontWeight: 'bold'
              }}
            />
            <div style={{ marginTop: 8 }}>
              <span
                style={{
                  color: card.change >= 0 ? '#3f8600' : '#cf1322',
                  fontSize: '14px'
                }}
              >
                {card.change >= 0 ? <ArrowUpOutlined /> : <ArrowDownOutlined />}
                {Math.abs(card.change)}%
                <span style={{ marginLeft: 8, color: '#666' }}>
                  较昨日
                </span>
              </span>
            </div>
          </Card>
        </Col>
      ))}
    </Row>
  );
};

// ============= 2. 销售趋势图组件 =============
import ReactECharts from 'echarts-for-react';
import { useState, useEffect } from 'react';

const SalesTrendChart = () => {
  const [salesData, setSalesData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState('30d');

  useEffect(() => {
    fetchSalesData(period);
  }, [period]);

  const fetchSalesData = async (period) => {
    setLoading(true);
    try {
      const response = await fetch(`/api/v1/admin/stats/sales?period=${period}`);
      const result = await response.json();
      if (result.code === 200) {
        setSalesData(result.data.daily_sales);
      }
    } catch (error) {
      console.error('获取销售数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const option = {
    title: {
      text: '销售趋势分析',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333'
      }
    },
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(0,0,0,0.8)',
      borderColor: '#777',
      textStyle: {
        color: '#fff'
      },
      formatter: (params) => {
        const data = params[0];
        return `
          <div style="padding: 10px;">
            <div style="margin-bottom: 5px; font-weight: bold;">${data.name}</div>
            <div>💰 销售额: ¥${data.value.toLocaleString()}</div>
            <div>📋 订单数: ${data.data?.order_count || 0}单</div>
            <div>📊 平均订单: ¥${(data.data?.avg_amount || 0).toFixed(2)}</div>
          </div>
        `;
      }
    },
    legend: {
      data: ['销售额', '订单数'],
      top: 35
    },
    xAxis: {
      type: 'category',
      data: salesData.map(item => {
        const date = new Date(item.date);
        return `${date.getMonth() + 1}/${date.getDate()}`;
      }),
      axisLabel: {
        color: '#666',
        fontSize: 12
      },
      axisLine: {
        lineStyle: {
          color: '#e8e8e8'
        }
      }
    },
    yAxis: [
      {
        type: 'value',
        name: '销售额(元)',
        position: 'left',
        axisLabel: {
          color: '#666',
          formatter: '¥{value}'
        },
        axisLine: {
          lineStyle: {
            color: '#1890ff'
          }
        }
      },
      {
        type: 'value',
        name: '订单数',
        position: 'right',
        axisLabel: {
          color: '#666',
          formatter: '{value}单'
        },
        axisLine: {
          lineStyle: {
            color: '#52c41a'
          }
        }
      }
    ],
    series: [
      {
        name: '销售额',
        type: 'line',
        yAxisIndex: 0,
        data: salesData.map(item => ({
          value: item.amount,
          order_count: item.order_count,
          avg_amount: item.avg_amount
        })),
        smooth: true,
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(24, 144, 255, 0.3)' },
              { offset: 1, color: 'rgba(24, 144, 255, 0.05)' }
            ]
          }
        },
        itemStyle: {
          color: '#1890ff'
        },
        lineStyle: {
          width: 3,
          shadowColor: 'rgba(24, 144, 255, 0.3)',
          shadowBlur: 5,
          shadowOffsetY: 3
        }
      },
      {
        name: '订单数',
        type: 'bar',
        yAxisIndex: 1,
        data: salesData.map(item => item.order_count),
        itemStyle: {
          color: '#52c41a',
          opacity: 0.7
        },
        barWidth: 20
      }
    ],
    grid: {
      left: '8%',
      right: '8%',
      bottom: '15%',
      top: '25%',
      containLabel: true
    },
    toolbox: {
      feature: {
        dataZoom: {
          yAxisIndex: 'none'
        },
        restore: {},
        saveAsImage: {}
      },
      right: 20,
      top: 30
    }
  };

  return (
    <Card 
      title="📈 销售趋势分析" 
      extra={
        <div>
          <span style={{ marginRight: 16 }}>时间范围：</span>
          <select 
            value={period} 
            onChange={(e) => setPeriod(e.target.value)}
            style={{ padding: '4px 8px', borderRadius: '4px', border: '1px solid #d9d9d9' }}
          >
            <option value="7d">近7天</option>
            <option value="30d">近30天</option>
            <option value="90d">近3个月</option>
          </select>
        </div>
      }
    >
      {loading ? (
        <div style={{ 
          height: '400px', 
          display: 'flex', 
          justifyContent: 'center', 
          alignItems: 'center',
          color: '#999'
        }}>
          加载中...
        </div>
      ) : (
        <ReactECharts 
          option={option} 
          style={{ height: '400px' }}
          opts={{ renderer: 'canvas' }}
        />
      )}
    </Card>
  );
};

// ============= 3. 热销菜品排行榜组件 =============
const HotDishesRanking = () => {
  const [dishData, setDishData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDishData();
  }, []);

  const fetchDishData = async () => {
    try {
      const response = await fetch('/api/v1/admin/stats/dishes?limit=10');
      const result = await response.json();
      if (result.code === 200) {
        setDishData(result.data.top_dishes);
      }
    } catch (error) {
      console.error('获取菜品数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const option = {
    title: {
      text: '热销菜品TOP10',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params) => {
        const data = params[0];
        return `
          <div style="padding: 10px;">
            <div style="font-weight: bold; margin-bottom: 5px;">${data.name}</div>
            <div>🔥 销量: ${data.value}份</div>
            <div>💰 销售额: ¥${data.data?.revenue || 0}</div>
            <div>🏷️ 分类: ${data.data?.category || ''}</div>
          </div>
        `;
      }
    },
    grid: {
      left: '20%',
      right: '10%',
      top: '15%',
      bottom: '10%'
    },
    xAxis: {
      type: 'value',
      name: '销量(份)',
      axisLabel: {
        formatter: '{value}份'
      }
    },
    yAxis: {
      type: 'category',
      data: dishData.map(item => item.name),
      axisLabel: {
        fontSize: 12,
        color: '#666'
      }
    },
    series: [{
      name: '销量',
      type: 'bar',
      data: dishData.map(item => ({
        value: item.sales_count,
        revenue: item.revenue,
        category: item.category
      })),
      itemStyle: {
        color: (params) => {
          const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#feca57', 
                         '#ff9ff3', '#54a0ff', '#5f27cd', '#c0392b', '#27ae60'];
          return colors[params.dataIndex % colors.length];
        },
        borderRadius: [0, 4, 4, 0]
      },
      label: {
        show: true,
        position: 'right',
        formatter: '{c}份',
        color: '#666'
      },
      barWidth: 20
    }]
  };

  return (
    <Card title="🥘 热销菜品排行榜">
      {loading ? (
        <div style={{ height: '400px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          加载中...
        </div>
      ) : (
        <ReactECharts 
          option={option} 
          style={{ height: '400px' }}
        />
      )}
    </Card>
  );
};

// ============= 4. 分类销售占比饼图组件 =============
const CategoryPieChart = () => {
  const [categoryData, setCategoryData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCategoryData();
  }, []);

  const fetchCategoryData = async () => {
    try {
      const response = await fetch('/api/v1/admin/stats/categories');
      const result = await response.json();
      if (result.code === 200) {
        setCategoryData(result.data.category_stats);
      }
    } catch (error) {
      console.error('获取分类数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const option = {
    title: {
      text: '菜品分类销售占比',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        return `
          <div style="padding: 10px;">
            <div style="font-weight: bold; margin-bottom: 5px;">${params.name}</div>
            <div>💰 销售额: ¥${params.value.toLocaleString()}</div>
            <div>📊 占比: ${params.percent.toFixed(1)}%</div>
          </div>
        `;
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: 'middle',
      textStyle: {
        fontSize: 14
      }
    },
    series: [{
      name: '销售额',
      type: 'pie',
      radius: ['45%', '75%'],
      center: ['65%', '50%'],
      data: categoryData.map(item => ({
        name: item.category,
        value: item.amount
      })),
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      },
      label: {
        show: true,
        formatter: '{b}\n{d}%',
        fontSize: 12,
        color: '#666'
      },
      labelLine: {
        show: true,
        length: 15,
        length2: 8
      }
    }],
    color: ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#feca57', '#ff9ff3']
  };

  return (
    <Card title="🍽️ 分类销售占比">
      {loading ? (
        <div style={{ height: '350px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          加载中...
        </div>
      ) : (
        <ReactECharts 
          option={option} 
          style={{ height: '350px' }}
        />
      )}
    </Card>
  );
};

// ============= 5. 订单时段分布雷达图组件 =============
const OrderTimeRadarChart = () => {
  const [timeData, setTimeData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTimeData();
  }, []);

  const fetchTimeData = async () => {
    try {
      const response = await fetch('/api/v1/admin/stats/orders/hourly');
      const result = await response.json();
      if (result.code === 200) {
        setTimeData(result.data.hourly_stats);
      }
    } catch (error) {
      console.error('获取时段数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const option = {
    title: {
      text: '24小时订单分布',
      left: 'center',
      textStyle: {
        fontSize: 18,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        return `${params.name}: ${params.value}单`;
      }
    },
    radar: {
      indicator: Array.from({ length: 24 }, (_, i) => ({
        name: `${i}:00`,
        max: Math.max(...timeData.map(item => item.order_count)) || 100
      })),
      center: ['50%', '55%'],
      radius: '70%',
      startAngle: 90,
      splitNumber: 4,
      shape: 'circle',
      axisLabel: {
        fontSize: 12,
        color: '#666'
      },
      splitArea: {
        areaStyle: {
          color: ['rgba(114, 172, 209, 0.1)', 'rgba(114, 172, 209, 0.05)']
        }
      }
    },
    series: [{
      name: '订单数',
      type: 'radar',
      data: [{
        value: timeData.map(item => item.order_count),
        name: '订单分布',
        areaStyle: {
          color: 'rgba(24, 144, 255, 0.2)'
        },
        lineStyle: {
          color: '#1890ff',
          width: 2
        },
        itemStyle: {
          color: '#1890ff'
        }
      }]
    }]
  };

  return (
    <Card title="⏰ 订单时段分布">
      {loading ? (
        <div style={{ height: '350px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          加载中...
        </div>
      ) : (
        <ReactECharts 
          option={option} 
          style={{ height: '350px' }}
        />
      )}
    </Card>
  );
};

// ============= 6. 主仪表板组件 =============
const AdminDashboard = () => {
  const [statsData, setStatsData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await fetch('/api/v1/admin/dashboard');
      const result = await response.json();
      if (result.code === 200) {
        setStatsData(result.data);
      }
    } catch (error) {
      console.error('获取仪表板数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '24px', background: '#f5f5f5', minHeight: '100vh' }}>
      <h1 style={{ marginBottom: '24px', fontSize: '24px', fontWeight: 'bold' }}>
        📊 数据分析中心
      </h1>
      
      {/* 统计卡片 */}
      <StatsCards statsData={statsData} />
      
      {/* 图表区域 */}
      <Row gutter={16}>
        {/* 销售趋势图 */}
        <Col span={16}>
          <SalesTrendChart />
        </Col>
        
        {/* 热销菜品排行 */}
        <Col span={8}>
          <HotDishesRanking />
        </Col>
      </Row>
      
      <Row gutter={16} style={{ marginTop: '16px' }}>
        {/* 分类占比图 */}
        <Col span={12}>
          <CategoryPieChart />
        </Col>
        
        {/* 时段分布图 */}
        <Col span={12}>
          <OrderTimeRadarChart />
        </Col>
      </Row>
    </div>
  );
};

export default AdminDashboard;