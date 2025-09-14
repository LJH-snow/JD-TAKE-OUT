import React, { useState, useEffect, useMemo } from 'react';
import { Form, Input, InputNumber, Select, Button, message, Space, Upload } from 'antd';
import { PlusOutlined } from '@ant-design/icons'; // Import PlusOutlined for the upload button
import apiClient from '../api';
import { useCurrentUser } from '../hooks/useCurrentUser';

const { Option } = Select;

const DishForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const { currentUser } = useCurrentUser();
  const isAdmin = currentUser?.role === 'admin';

  const transformedInitialValues = useMemo(() => {
    if (initialValues && initialValues.image) { // Only process if initialValues and image exist
      const imageUrl = initialValues.image.startsWith('http') ? initialValues.image : `http://localhost:8090${initialValues.image}`;
      const fileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
      return {
        ...initialValues,
        image: [{
          uid: imageUrl, // Use URL as uid for uniqueness
          name: fileName,
          status: 'done',
          url: imageUrl
        }],
      };
    }
    // Always return an object with image as an empty array if no valid initial image
    return { ...initialValues, status: 1, image: [] };
  }, [initialValues]);

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
    if (!initialValues) { // Only reset if it's a new form
      form.resetFields();
      form.setFieldsValue({ status: 1, image: [] }); // Default to open and empty image
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    try {
      let imageUrl = '';
      
      // 处理新上传的图片
      if (Array.isArray(values.image) && values.image.length > 0) {
        const imageFile = values.image[0];
        
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
      else if (typeof values.image === 'string') {
        imageUrl = values.image;
      }

      await onFormSubmit({ ...values, image: imageUrl });
    } catch (error) {
      // Error is handled by parent
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={transformedInitialValues}>
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
        label="菜品图片"
        valuePropName="fileList"
        getValueFromEvent={(e) => {
          if (Array.isArray(e)) {
            return e;
          }
          return e && e.fileList;
        }}
        rules={[{ required: true, message: '请上传菜品图片!' }]}
      >
        <Upload
          name="file"
          action="http://localhost:8090/api/v1/upload?type=dish" // Backend upload endpoint
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