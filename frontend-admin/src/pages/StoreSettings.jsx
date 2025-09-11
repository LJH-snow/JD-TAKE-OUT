import React, { useState, useEffect } from 'react';
import { Card, Form, Button, Space, App, Spin, Alert } from 'antd';
import apiClient from '../api';
import StoreSettingsForm from '../components/StoreSettingsForm';

const StoreSettings = () => {
  const [settings, setSettings] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { message } = App.useApp();

  const fetchSettings = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get('/admin/settings');
      if (response.data && response.data.code === 200) {
        setSettings(response.data.data);
      } else {
        message.error(response.data.message || '获取店铺设置失败');
        setError(response.data.message || '获取店铺设置失败');
      }
    } catch (err) {
      message.error('网络错误，无法获取店铺设置');
      setError('网络错误，无法获取店铺设置');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleFormSubmit = async (values) => {
    setLoading(true);
    try {
      const response = await apiClient.put('/admin/settings', values);
      if (response.data && response.data.code === 200) {
        message.success('店铺设置更新成功');
        setSettings(response.data.data); // 更新本地状态
      } else {
        message.error(response.data.message || '更新店铺设置失败');
      }
    } catch (err) {
      message.error(err.response?.data?.message || '网络错误，更新店铺设置失败');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <Spin tip="加载店铺设置中..." style={{ display: 'block', marginTop: '50px' }} />;
  }

  if (error) {
    return <Alert message="错误" description={error} type="error" showIcon />;
  }

  return (
    <Card title="店铺设置">
      <StoreSettingsForm 
        initialValues={settings} 
        onFormSubmit={handleFormSubmit} 
        onCancel={() => { /* 取消操作 */ }} 
      />
    </Card>
  );
};

export default StoreSettings;
