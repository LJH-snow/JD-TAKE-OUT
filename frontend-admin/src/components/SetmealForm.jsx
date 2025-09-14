import React, { useState, useEffect, useMemo } from 'react';
import { Form, Input, InputNumber, Select, Button, message, Space, Transfer, Upload } from 'antd'; // Added Upload
import { PlusOutlined } from '@ant-design/icons'; // Added PlusOutlined
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

  const transformedInitialValues = useMemo(() => {
    if (initialValues && initialValues.image) { // Only process if initialValues and image exist
      const initialDishIds = initialValues.setmeal_dishes?.map(d => d.dish_id.toString()) || [];
      const imageUrl = initialValues.image.startsWith('http') ? initialValues.image : `http://localhost:8090${initialValues.image}`;
      const fileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
      return {
        ...initialValues,
        dish_ids: initialDishIds,
        image: [{
          uid: imageUrl, // Use URL as uid for uniqueness
          name: fileName,
          status: 'done',
          url: imageUrl
        }],
      };
    }
    // Always return an object with image as an empty array if no valid initial image
    return { ...initialValues, status: 1, image: [], dish_ids: [] };
  }, [initialValues]);

  // Fetch categories and dishes
  useEffect(() => {
    const fetchData = async () => {
      try {
        const catEndpoint = isAdmin ? '/admin/categories/list?type=2' : '/employee/categories?type=2';
        const dishEndpoint = isAdmin ? '/admin/dishes?limit=1000' : '/employee/dishes?limit=1000';
        
        // 创建实际的 Promise 对象
        const catPromise = apiClient.get(catEndpoint);
        const dishPromise = apiClient.get(dishEndpoint);
        
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

  useEffect(() => {
    if (!initialValues) { // Only reset if it's a new form
      form.resetFields();
      setTargetKeys([]);
      form.setFieldsValue({ status: 1, image: [], dish_ids: [] }); // Default to open and empty image
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    const payload = { ...values, dish_ids: targetKeys.map(Number) };
    try {
      let imageUrl = '';
      
      // 处理新上传的图片
      if (Array.isArray(payload.image) && payload.image.length > 0) {
        const imageFile = payload.image[0];
        
        // 如果是新上传的文件（有response）
        if (imageFile.response && imageFile.response.code === 200) {
          imageUrl = imageFile.response.data.url;
        }
        // 如果是已存在的文件（有url属性）
        else if (imageFile.url) {
          imageUrl = imageFile.url;
        }
      }
      // 如果image是字符串类型（兼容旧数据）
      else if (typeof payload.image === 'string') {
        imageUrl = payload.image;
      }

      await onFormSubmit({ ...payload, image: imageUrl });
    } finally {
      setLoading(false);
    }
  };

  const handleTransferChange = (newTargetKeys) => {
    setTargetKeys(newTargetKeys);
    form.setFieldsValue({ dish_ids: newTargetKeys });
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={transformedInitialValues}>
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
      <Form.Item
        name="image"
        label="套餐图片"
        valuePropName="fileList"
        getValueFromEvent={(e) => {
          if (Array.isArray(e)) {
            return e;
          }
          return e && e.fileList;
        }}
        rules={[{ required: true, message: '请上传套餐图片!' }]}>
        <Upload
          name="file"
          action="http://localhost:8090/api/v1/upload?type=setmeal" // Backend upload endpoint
          listType="picture-card"
          maxCount={1}
          showUploadList={{ showPreviewIcon: true, showRemoveIcon: true }} // Explicitly show preview and remove icons
          headers={{
            Authorization: `Bearer ${localStorage.getItem('jwt_token')}`, // Include JWT token
          }}
          beforeUpload={(file) => {
            const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/gif' || file.type === 'image/webp';
            if (!isJpgOrPng) {
              message.error('只能上传 JPG/PNG/GIF/WEBP 格式的图片!');
            }
            const isLt5M = file.size / 1024 / 1024 < 5; // 5MB limit
            if (!isLt5M) {
              message.error('图片大小不能超过 5MB!');
            }
            return isJpgOrPng && isLt5M;
          }}
          onChange={({ fileList }) => {
            // Always update the form field with the fileList array
            form.setFieldsValue({ image: fileList });
          }}
          onRemove={() => {
            form.setFieldsValue({ image: [] }); // Clear image on remove
            return true;
          }}
        >
          <div>
            <PlusOutlined />
            <div style={{ marginTop: 8 }}>上传</div>
          </div>
        </Upload>
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