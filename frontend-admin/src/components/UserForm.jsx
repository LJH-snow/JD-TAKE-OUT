import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Select, Radio, Space } from 'antd';

const { Option } = Select;

const UserForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

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
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit}>
      <Form.Item
        name="name"
        label="姓名"
        rules={[{ required: true, message: '请输入用户姓名' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="phone"
        label="手机号"
        rules={[{ required: true, message: '请输入手机号' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="sex"
        label="性别"
        rules={[{ required: true, message: '请选择性别' }]}
      >
        <Radio.Group>
          <Radio value="1">男</Radio>
          <Radio value="0">女</Radio>
        </Radio.Group>
      </Form.Item>
      <Form.Item
        name="is_active"
        label="状态"
        valuePropName="checked"
      >
        <Select>
          <Option value={true}>激活</Option>
          <Option value={false}>禁用</Option>
        </Select>
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

export default UserForm;
