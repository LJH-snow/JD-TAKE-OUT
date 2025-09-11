import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Select, Radio, Space, message } from 'antd';
import apiClient from '../api';

const { Option } = Select;

const EmployeeForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (initialValues) {
      form.setFieldsValue({
        ...initialValues,
        // 密码字段不回填，需要单独处理
        password: '',
      });
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
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={{ status: 1, sex: '1', ...initialValues }}>
      <Form.Item
        name="name"
        label="姓名"
        rules={[{ required: true, message: '请输入员工姓名' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="username"
        label="用户名"
        rules={[{ required: true, message: '请输入用户名' }]}
      >
        <Input disabled={!!initialValues} />{/* 编辑时用户名不可修改 */}
      </Form.Item>
      <Form.Item
        name="password"
        label="密码"
        rules={[{ required: !initialValues, message: '请输入密码' }]} // 新增时必填，编辑时可选
      >
        <Input.Password placeholder={initialValues ? '留空则不修改密码' : '请输入密码'} />
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
        name="id_number"
        label="身份证号"
        rules={[{ required: true, message: '请输入身份证号' }, { len: 18, message: '身份证号必须为18位' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="status"
        label="状态"
        rules={[{ required: true, message: '请选择状态' }]}
      >
        <Select>
          <Option value={1}>启用</Option>
          <Option value={0}>禁用</Option>
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

export default EmployeeForm;
