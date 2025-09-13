import React, { useState, useEffect } from 'react';
import { Form, Input, InputNumber, Select, Button, message, Space } from 'antd';
import apiClient from '../api';
import { useCurrentUser } from '../hooks/useCurrentUser';

const { Option } = Select;

const DishForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const { currentUser } = useCurrentUser();
  const isAdmin = currentUser?.role === 'admin';

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const endpoint = isAdmin ? '/admin/categories/list?type=1' : '/employee/categories?type=1';
        const response = await apiClient.get(endpoint);
        if (response.data && response.data.code === 200 && Array.isArray(response.data.data)) {
          setCategories(response.data.data);
        } else {
          message.error('获取菜品分类列表失败');
        }
      } catch (error) {
        message.error('网络错误，无法获取菜品分类列表');
      }
    };
    fetchCategories();
  }, []);

  useEffect(() => {
    if (initialValues) {
      form.setFieldsValue(initialValues);
    } else {
      form.resetFields();
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    try {
      await onFormSubmit(values);
    } catch (error) {
      // Error is handled by parent
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={{status: 1, ...initialValues}}>
      <Form.Item
        name="name"
        label="菜品名称"
        rules={[{ required: true, message: '请输入菜品名称' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="category_id"
        label="菜品分类"
        rules={[{ required: true, message: '请选择菜品分类' }]}
      >
        <Select placeholder="选择一个分类">
          {categories.map((cat) => (
            <Option key={cat.id} value={cat.id}>
              {cat.name}
            </Option>
          ))}
        </Select>
      </Form.Item>
      <Form.Item
        name="price"
        label="价格"
        rules={[{ required: true, message: '请输入价格' }]}
      >
        <InputNumber min={0} style={{ width: '100%' }} addonAfter="元" precision={2} />
      </Form.Item>
      <Form.Item
        name="image"
        label="图片链接"
        rules={[{ type: 'url', message: '请输入有效的URL' }]}
      >
        <Input placeholder="请输入图片的URL" />
      </Form.Item>
      <Form.Item
        name="description"
        label="描述"
      >
        <Input.TextArea rows={4} />
      </Form.Item>
      <Form.Item
        name="status"
        label="状态"
        rules={[{ required: true, message: '请选择状态' }]}
      >
        <Select>
          <Option value={1}>在售</Option>
          <Option value={0}>停售</Option>
        </Select>
      </Form.Item>
      <Form.Item>
        <Space>
          <Button type="primary" htmlType="submit" loading={loading}>
            提交
          </Button>
          <Button onClick={onCancel} disabled={loading}>
            取消
          </Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

export default DishForm;