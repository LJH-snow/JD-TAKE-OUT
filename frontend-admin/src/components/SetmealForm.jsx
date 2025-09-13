import React, { useState, useEffect } from 'react';
import { Form, Input, InputNumber, Select, Button, message, Space, Transfer } from 'antd';
import apiClient from '../api';
import { useCurrentUser } from '../hooks/useCurrentUser';

const { Option } = Select;

const SetmealForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [categories, setCategories] = useState([]);
  const [allDishes, setAllDishes] = useState([]);
  const [targetKeys, setTargetKeys] = useState([]);
  const [loading, setLoading] = useState(false);
  const { currentUser } = useCurrentUser();
  const isAdmin = currentUser?.role === 'admin';

  // Fetch categories and dishes
  useEffect(() => {
    const fetchData = async () => {
      try {
        const catEndpoint = isAdmin ? '/admin/categories/list?type=2' : '/employee/categories?type=2';
        const dishEndpoint = isAdmin ? '/admin/dishes?limit=1000' : '/employee/dishes?limit=1000';
        const catPromise = apiClient.get(catEndpoint); // 套餐分类
        const dishPromise = apiClient.get(dishEndpoint); // 获取所有菜品
        const [catResponse, dishResponse] = await Promise.all([catPromise, dishPromise]);

        if (catResponse.data?.code === 200) {
          setCategories(catResponse.data.data);
        } else {
          message.error('获取套餐分类失败');
        }

        if (dishResponse.data?.code === 200) {
          const dishData = dishResponse.data.data.items.map(dish => ({ ...dish, key: dish.id.toString() }));
          setAllDishes(dishData);
        } else {
          message.error('获取菜品列表失败');
        }

      } catch (error) {
        message.error('网络错误，无法获取初始数据');
      }
    };
    fetchData();
  }, []);

  // Set initial form values when editing
  useEffect(() => {
    if (initialValues) {
      const initialDishIds = initialValues.setmeal_dishes?.map(d => d.dish_id.toString()) || [];
      setTargetKeys(initialDishIds);
      form.setFieldsValue({ 
        ...initialValues,
        dish_ids: initialDishIds
      });
    } else {
      form.resetFields();
      setTargetKeys([]);
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    const payload = { ...values, dish_ids: targetKeys.map(Number) };
    try {
      await onFormSubmit(payload);
    } finally {
      setLoading(false);
    }
  };

  const handleTransferChange = (newTargetKeys) => {
    setTargetKeys(newTargetKeys);
    form.setFieldsValue({ dish_ids: newTargetKeys });
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={{ status: 1, ...initialValues }}>
      <Form.Item name="name" label="套餐名称" rules={[{ required: true }]}>
        <Input />
      </Form.Item>
      <Form.Item name="category_id" label="套餐分类" rules={[{ required: true }]}>
        <Select placeholder="选择一个分类">
          {categories.map((cat) => (
            <Option key={cat.id} value={cat.id}>{cat.name}</Option>
          ))}
        </Select>
      </Form.Item>
      <Form.Item name="price" label="价格" rules={[{ required: true }]}>
        <InputNumber min={0} style={{ width: '100%' }} addonAfter="元" precision={2} />
      </Form.Item>
      <Form.Item name="dish_ids" label="包含菜品" rules={[{ required: true, message: '请至少选择一个菜品' }]}>
        <Transfer
          dataSource={allDishes}
          targetKeys={targetKeys}
          onChange={handleTransferChange}
          render={item => item.name}
          listStyle={{
            width: 250,
            height: 300,
          }}
          titles={['所有菜品', '已选菜品']}
        />
      </Form.Item>
      <Form.Item name="image" label="图片链接">
        <Input placeholder="请输入图片的URL" />
      </Form.Item>
      <Form.Item name="description" label="描述">
        <Input.TextArea rows={2} />
      </Form.Item>
      <Form.Item name="status" label="状态" rules={[{ required: true }]}>
        <Select><Option value={1}>在售</Option><Option value={0}>停售</Option></Select>
      </Form.Item>
      <Form.Item style={{ textAlign: 'right' }}>
        <Space>
          <Button onClick={onCancel} disabled={loading}>取消</Button>
          <Button type="primary" htmlType="submit" loading={loading}>提交</Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

export default SetmealForm;
