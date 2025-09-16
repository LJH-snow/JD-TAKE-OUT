import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Form, Input, Button, message, Card } from 'antd';
import apiClient from '../api';

const ChangePasswordPage = () => {
  const navigate = useNavigate();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  const onFinish = async (values) => {
    setLoading(true);
    try {
      await apiClient.put('/employee/password', { 
        old_password: values.oldPassword, 
        new_password: values.newPassword 
      });
      message.success('密码修改成功，请重新登录！');
      localStorage.removeItem('jwt_token');
      navigate('/login');
    } catch (error) {
      message.error(error.response?.data?.message || '密码修改失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card title="修改密码">
        <Form
          form={form}
          name="change_password"
          onFinish={onFinish}
          layout="vertical"
          style={{ maxWidth: 400, margin: 'auto' }}
        >
          <Form.Item
            name="oldPassword"
            label="当前密码"
            rules={[{ required: true, message: '请输入当前密码！' }]}
          >
            <Input.Password />
          </Form.Item>

          <Form.Item
            name="newPassword"
            label="新密码"
            rules={[
              { required: true, message: '请输入新密码！' },
              { min: 6, message: '密码长度不能少于6位！' },
            ]}
            hasFeedback
          >
            <Input.Password />
          </Form.Item>

          <Form.Item
            name="confirmPassword"
            label="确认新密码"
            dependencies={['newPassword']}
            hasFeedback
            rules={[
              { required: true, message: '请确认您的新密码！' },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue('newPassword') === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(new Error('两次输入的密码不匹配！'));
                },
              }),
            ]}
          >
            <Input.Password />
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading} block>
              确认修改
            </Button>
          </Form.Item>
        </Form>
    </Card>
  );
};

export default ChangePasswordPage;
