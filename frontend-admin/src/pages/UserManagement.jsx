import React, { useState, useEffect } from 'react';
import { Table, Button, Input, Space, Card, App, Modal, Form, Select, Tag } from 'antd';
import { SearchOutlined, EditOutlined } from '@ant-design/icons';
import apiClient from '../api';
import UserForm from '../components/UserForm';

const { Option } = Select;

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [form] = Form.useForm();

  const { message } = App.useApp();

  const fetchUsers = async (params = {}) => {
    setLoading(true);
    try {
      const queryParams = {
        page: params.page,
        pageSize: params.pageSize,
        ...params.filters,
      };
      const response = await apiClient.get('/admin/users', { params: queryParams });
      if (response.data && response.data.code === 200) {
        setUsers(response.data.data.items);
        setPagination(prev => ({
          ...prev,
          current: params.page,
          pageSize: params.pageSize,
          total: response.data.data.total,
        }));
      } else {
        message.error(response.data.message || '获取用户列表失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取用户列表');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers({ page: 1, pageSize: 10 });
  }, []);

  const handleTableChange = (newPagination) => {
    const filters = form.getFieldsValue();
    fetchUsers({
      page: newPagination.current,
      pageSize: newPagination.pageSize,
      filters: filters,
    });
  };

  const handleSearch = (values) => {
    fetchUsers({ page: 1, pageSize: pagination.pageSize, filters: values });
  };

  const handleEdit = (record) => {
    setEditingUser(record);
    setIsModalVisible(true);
  };

  const handleFormSubmit = async (values) => {
    setLoading(true);
    try {
      const response = await apiClient.put(`/admin/users/${editingUser.id}`, values);

      if (response.data && response.data.code === 200) {
        message.success('更新成功');
        setIsModalVisible(false);
        fetchUsers({ page: pagination.current, pageSize: pagination.pageSize, filters: form.getFieldsValue() });
      } else {
        message.error(response.data.message || '操作失败');
      }
    } catch (error) {
      message.error(error.response?.data?.message || '网络错误，操作失败');
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '姓名', dataIndex: 'name', key: 'name' },
    { title: '手机号', dataIndex: 'phone', key: 'phone' },
    { title: '性别', dataIndex: 'sex', key: 'sex', render: (sex) => (sex === '1' ? '男' : '女') },
    {
      title: '状态',
      dataIndex: 'is_active',
      key: 'is_active',
      render: (isActive) => (
        <Tag color={isActive ? 'success' : 'error'}>
          {isActive ? '激活' : '禁用'}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          <Button type="primary" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
        </Space>
      ),
    },
  ];

  return (
    <Card title="用户管理">
      <Form form={form} onFinish={handleSearch} layout="inline" style={{ marginBottom: 16 }}>
        <Form.Item name="name" label="姓名"><Input placeholder="姓名" /></Form.Item>
        <Form.Item name="phone" label="手机号"><Input placeholder="手机号" /></Form.Item>
        <Form.Item name="is_active" label="状态">
          <Select placeholder="选择状态" style={{ width: 120 }} allowClear>
            <Option value="true">激活</Option>
            <Option value="false">禁用</Option>
          </Select>
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>搜索</Button>
        </Form.Item>
        <Form.Item>
          <Button onClick={() => form.resetFields()}>重置</Button>
        </Form.Item>
      </Form>
      <Table
        columns={columns}
        dataSource={users}
        rowKey="id"
        pagination={pagination}
        loading={loading}
        onChange={handleTableChange}
        bordered
      />
      <Modal
        title={editingUser ? '编辑用户' : '新增用户'}
        open={isModalVisible}
        onCancel={() => setIsModalVisible(false)}
        footer={null}
        destroyOnClose
      >
        <UserForm 
          initialValues={editingUser}
          onFormSubmit={handleFormSubmit}
          onCancel={() => setIsModalVisible(false)}
        />
      </Modal>
    </Card>
  );
};

export default UserManagement;
