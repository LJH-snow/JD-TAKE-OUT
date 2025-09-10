import React, { useEffect } from 'react';
import { Form, Input, Button, Select, InputNumber, Switch, Space } from 'antd';

const { Option } = Select;

const CategoryForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();

  useEffect(() => {
    if (initialValues) {
      form.setFieldsValue(initialValues);
    } else {
      form.resetFields();
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    // antd Switch 返回的是 boolean, 需要转换为 0 或 1
    const processedValues = {
      ...values,
      status: values.status ? 1 : 0,
    };
    await onFormSubmit(processedValues);
    form.resetFields();
  };

  return (
    <Form
      form={form}
      layout="vertical"
      onFinish={handleSubmit}
      initialValues={{
        status: true, // 默认为启用
        sort: 0,
        type: 1, // 默认为菜品分类
        ...initialValues,
        status: initialValues ? initialValues.status === 1 : true,
      }}
    >
      <Form.Item
        name="name"
        label="分类名称"
        rules={[{ required: true, message: '请输入分类名称' }]}
      >
        <Input placeholder="例如：热菜、凉菜" />
      </Form.Item>

      <Form.Item
        name="type"
        label="分类类型"
        rules={[{ required: true, message: '请选择分类类型' }]}
      >
        <Select placeholder="请选择分类类型">
          <Option value={1}>菜品分类</Option>
          <Option value={2}>套餐分类</Option>
        </Select>
      </Form.Item>

      <Form.Item
        name="sort"
        label="排序权重"
        rules={[{ required: true, message: '请输入排序权重' }]}
        help="数字越小，排序越靠前"
      >
        <InputNumber min={0} style={{ width: '100%' }} />
      </Form.Item>

      <Form.Item
        name="status"
        label="状态"
        valuePropName="checked"
      >
        <Switch checkedChildren="启用" unCheckedChildren="禁用" />
      </Form.Item>

      <Form.Item style={{ textAlign: 'right', marginBottom: 0 }}>
        <Space>
          <Button onClick={onCancel}>取消</Button>
          <Button type="primary" htmlType="submit">
            确认
          </Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

export default CategoryForm;
