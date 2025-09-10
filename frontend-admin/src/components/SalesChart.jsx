import React, { useState, useEffect } from 'react';
import ReactECharts from 'echarts-for-react';
import { Spin, Alert } from 'antd';
import apiClient from '../api';

const SalesChart = ({ dateRange }) => {
  const [chartOption, setChartOption] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchChartData = async () => {
      if (!dateRange || dateRange.length !== 2) {
        setLoading(false);
        return; // Don't fetch if dateRange is not valid
      }

      try {
        setLoading(true);

        const startStr = dateRange[0].format('YYYY-MM-DD');
        const endStr = dateRange[1].format('YYYY-MM-DD');

        const response = await apiClient.get(`/admin/stats/sales?start=${startStr}&end=${endStr}`);
        
        let data;
        if (response.data && response.data.code === 200) {
            data = response.data.data;
        } else {
            throw new Error(response.data.message || '获取图表数据格式不正确');
        }

        // 后端返回的数据本身就是数组，直接使用
        if (!Array.isArray(data)) {
            throw new Error('返回的图表数据格式不是数组');
        }

        const dates = data.map(item => item.date);
        const amounts = data.map(item => item.revenue);

        setChartOption({
          tooltip: {
            trigger: 'axis',
            backgroundColor: 'rgba(32, 33, 36, 0.8)',
            borderColor: 'rgba(32, 33, 36, 0.9)',
            textStyle: {
              color: '#fff'
            }
          },
          xAxis: {
            type: 'category',
            data: dates,
            boundaryGap: false,
          },
          yAxis: {
            type: 'value',
            name: '销售额 (元)'
          },
          series: [
            {
              name: '销售额',
              data: amounts,
              type: 'line',
              smooth: true,
              itemStyle: { color: '#667eea' },
              areaStyle: {
                color: {
                  type: 'linear',
                  x: 0, y: 0, x2: 0, y2: 1,
                  colorStops: [
                    { offset: 0, color: 'rgba(102, 126, 234, 0.5)' },
                    { offset: 1, color: 'rgba(118, 75, 162, 0.1)' }
                  ]
                }
              }
            }
          ],
          grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
          }
        });
      } catch (e) {
        setError(e.message);
        console.error("获取图表数据失败:", e);
      } finally {
        setLoading(false);
      }
    };

    fetchChartData();
  }, [dateRange]); // Refetch when dateRange changes

  if (loading) {
    return <Spin tip="图表加载中..." style={{ display: 'block', marginTop: '20px' }} />;
  }

  if (error) {
    return <Alert message="图表加载失败" description={`无法加载销售趋势图: ${error}`} type="error" showIcon />;
  }

  return <ReactECharts option={chartOption} style={{ height: '400px' }} notMerge={true} lazyUpdate={true} />;
};

export default SalesChart;
