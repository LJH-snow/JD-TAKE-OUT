import React, { useState, useEffect } from 'react';
import ReactECharts from 'echarts-for-react';
import { Spin, Alert } from 'antd';
import apiClient from '../api';

const DishRankingChart = ({ dateRange }) => {
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

        const response = await apiClient.get(`/admin/stats/dishes?start=${startStr}&end=${endStr}&limit=10`);
        
        let data;
        if (response.data && response.data.code === 200) {
            data = response.data.data;
        } else {
            throw new Error(response.data.message || '获取菜品排行数据格式不正确');
        }

        if (!Array.isArray(data)) {
            throw new Error('返回的菜品排行数据格式不是数组');
        }

        // ECharts横向柱状图，通常希望最大值在顶部，所以需要反转数组
        const reversedData = [...data].reverse();

        const dishNames = reversedData.map(item => item.name);
        const salesCounts = reversedData.map(item => item.quantity);

                setChartOption({
          title: {
            text: '热销菜品 Top 10',
            left: 'center',
            textStyle: { color: '#333', fontWeight: 'bold' }
          },
          tooltip: {
            trigger: 'axis',
            axisPointer: {
              type: 'shadow'
            },
            formatter: '{b}: {c}份'
          },
          xAxis: {
            type: 'value',
            boundaryGap: [0, 0.01]
          },
          yAxis: {
            type: 'category',
            data: dishNames,
            axisLabel: {
                interval: 0,
                rotate: 0
            }
          },
          series: [
            {
              name: '销量',
              type: 'bar',
              data: salesCounts,
              itemStyle: {
                borderRadius: [0, 5, 5, 0],
                color: {
                  type: 'linear',
                  x: 0, y: 0, x2: 1, y2: 0,
                  colorStops: [
                    { offset: 0, color: '#2af598' },
                    { offset: 1, color: '#009efd' }
                  ]
                }
              },
              label: {
                show: true,
                position: 'right',
                formatter: '{c}'
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
        console.error("获取菜品排行数据失败:", e);
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
    return <Alert message="图表加载失败" description={`无法加载菜品排行图: ${error}`} type="error" showIcon />;
  }

  return <ReactECharts option={chartOption} style={{ height: '400px' }} notMerge={true} />;
};

export default DishRankingChart;
