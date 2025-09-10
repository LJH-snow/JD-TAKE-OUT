import React, { useState, useEffect } from 'react';
import ReactECharts from 'echarts-for-react';
import { Spin, Alert } from 'antd';
import apiClient from '../api';

const CategoryPieChart = ({ dateRange }) => {
  const [chartOption, setChartOption] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchChartData = async () => {
      if (!dateRange || dateRange.length !== 2) {
        setLoading(false);
        return;
      }

      try {
        setLoading(true);
        const startStr = dateRange[0].format('YYYY-MM-DD');
        const endStr = dateRange[1].format('YYYY-MM-DD');

        const response = await apiClient.get(`/admin/stats/categories?start=${startStr}&end=${endStr}`);
        
        let data;
        if (response.data && response.data.code === 200) {
            data = response.data.data;
        } else {
            throw new Error(response.data.message || '获取分类统计数据格式不正确');
        }

        if (!Array.isArray(data)) {
            throw new Error('返回的分类统计数据格式不是数组');
        }

        const pieData = data.map(item => ({
          name: item.category,
          value: item.revenue.toFixed(2)
        }));

        setChartOption({
          title: {
            text: '分类销售占比',
            left: 'center',
            textStyle: { color: '#333', fontWeight: 'bold' }
          },
          tooltip: {
            trigger: 'item',
            formatter: '{b} <br/>销售额: ¥{c} ({d}%)'
          },
          legend: {
            orient: 'vertical',
            left: 'left',
          },
          series: [
            {
              name: '分类销售额',
              type: 'pie',
              radius: ['40%', '70%'],
              avoidLabelOverlap: false,
              data: pieData,
              emphasis: {
                itemStyle: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
              },
              label: {
                show: false,
                position: 'center'
              },
              labelLine: {
                show: false
              },
            }
          ],
          color: ['#667eea', '#38ef7d', '#fc4a1a', '#2af598', '#f7b733', '#11998e']
        });
      } catch (e) {
        setError(e.message);
        console.error("获取分类统计数据失败:", e);
      } finally {
        setLoading(false);
      }
    };

    fetchChartData();
  }, [dateRange]);

  if (loading) {
    return <Spin tip="图表加载中..." style={{ display: 'block', marginTop: '20px' }} />;
  }

  if (error) {
    return <Alert message="图表加载失败" description={`无法加载分类销售占比图: ${error}`} type="error" showIcon />;
  }

  return <ReactECharts option={chartOption} style={{ height: '400px' }} notMerge={true} />;
};

export default CategoryPieChart;
