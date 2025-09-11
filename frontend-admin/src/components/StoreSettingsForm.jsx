import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Space, message, Switch, Image } from 'antd';

const StoreSettingsForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (initialValues) {
      form.setFieldsValue({
        ...initialValues,
        is_open: initialValues.is_open === undefined ? true : initialValues.is_open, // Ensure is_open is boolean
      });
    } else {
      form.resetFields();
      form.setFieldsValue({ is_open: true }); // Default to open
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    try {
      await onFormSubmit(values);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={initialValues}>
      <Form.Item
        name="name"
        label="店铺名称"
        rules={[{ required: true, message: '请输入店铺名称' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="address"
        label="店铺地址"
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="phone"
        label="联系电话"
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="description"
        label="店铺描述"
      >
        <Input.TextArea rows={3} />
      </Form.Item>
      <Form.Item
        name="logo"
        label="Logo图片URL"
      >
        <Input />
      </Form.Item>
      <Form.Item label="当前Logo预览">
        <Image 
          src={initialValues?.logo || 'https://via.placeholder.com/100?text=No+Logo'} 
          width={100} 
          alt="店铺Logo"
        />
      </Form.Item>
      <Form.Item
        name="is_open"
        label="店铺营业状态"
        valuePropName="checked"
      >
        <Switch checkedChildren="营业中" unCheckedChildren="已打烊" />
      </Form.Item>
      <Form.Item style={{ textAlign: 'right' }}>
        <Space>
          <Button onClick={onCancel} disabled={loading}>取消</Button>
          <Button type="primary" htmlType="submit" loading={loading}>保存设置</Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

export default StoreSettingsForm;