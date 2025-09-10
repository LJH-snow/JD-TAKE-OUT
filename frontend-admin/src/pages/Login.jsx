import React, { useState } from 'react';
import { Form, Input, Button, Card, Typography, App } from 'antd'; // 导入App组件以使用useApp hook
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import apiClient from '../api';

const { Title } = Typography;

const LoginPage = ({ onLoginSuccess }) => {
  // 从 Ant Design 的 App context 中获取 message 实例，这是最可靠的方式
  const { message } = App.useApp();
  const [loading, setLoading] = useState(false);

  const onFinish = async (values) => {
    setLoading(true);
    try {
      const response = await apiClient.post('/auth/login', {
        username: values.username,
        password: values.password,
        user_type: 'admin',
      }, {
        validateStatus: function (status) {
          return status >= 200 && status < 500;
        }
      });

      if (response.status === 200 && response.data.code === 200) {
        const { token, user } = response.data.data;
        localStorage.setItem('jwt_token', token);
        message.success('登录成功!');
        onLoginSuccess(user);
      } else {
        const errorMessage = response.data?.message || '登录失败，请检查用户名和密码。';
        message.error(errorMessage); // 使用从hook获取的message实例
      }
    } catch (error) {
      console.error("登录请求失败:", error);
      message.error('网络错误或服务器无响应，请稍后重试。'); // 使用从hook获取的message实例
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', background: '#f0f2f5' }}>
      <Card style={{ width: 400, boxShadow: '0 4px 8px 0 rgba(0,0,0,0.1)' }}>
        <div style={{ textAlign: 'center', marginBottom: '24px' }}>
            <Title level={2}>JD外卖 - 后台登录</Title>
        </div>
        <Form
          name="login"
          onFinish={onFinish}
          size="large"
        >
          <Form.Item
            name="username"
            rules={[{ required: true, message: '请输入用户名!' }]}
          >
            <Input prefix={<UserOutlined />} placeholder="用户名" />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: '请输入密码!' }]}
          >
            <Input.Password prefix={<LockOutlined />} placeholder="密码" />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading} style={{ width: '100%' }}>
              登 录
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default LoginPage;