import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Card, App, Tag, Modal } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import apiClient from '../api';
import CategoryForm from '../components/CategoryForm'; // 引入表单组件

const CategoryManagement = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const { message, modal } = App.useApp();

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get('/admin/categories/list');
      if (response.data && response.data.code === 200) {
        setCategories(response.data.data);
      } else {
        message.error(response.data.message || '获取分类列表失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取分类列表');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  const handleAdd = () => {
    setEditingCategory(null);
    setIsModalVisible(true);
  };

  const handleEdit = (record) => {
    setEditingCategory(record);
    setIsModalVisible(true);
  };

  const handleFormSubmit = async (values) => {
    setLoading(true);
    try {
      let response;
      if (editingCategory) {
        response = await apiClient.put(`/admin/categories/${editingCategory.id}`, values);
      } else {
        response = await apiClient.post('/admin/categories', values);
      }

      if (response.data && (response.data.code === 200 || response.data.code === 201)) {
        message.success(editingCategory ? '更新成功' : '新增成功');
        setIsModalVisible(false);
        fetchCategories(); // 重新加载数据
      } else {
        message.error(response.data.message || '操作失败');
      }
    } catch (error) {
      message.error('网络错误，操作失败');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = (id) => {
    modal.confirm({
      title: '确认删除',
      content: '您确定要删除该分类吗？如果分类下有关联菜品，将无法删除。',
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        try {
          const response = await apiClient.delete(`/admin/categories/${id}`);
          if (response.status === 204) {
            message.success('删除成功');
            fetchCategories(); // 重新加载数据
          } else {
            // Antd http client a默认会对非2xx状态码抛出错误，所以这里可能不会执行
            message.error(response.data.message || '删除失败');
          }
        } catch (error) {
          message.error(error.response?.data?.message || '网络错误，删除失败');
        }
      },
    });
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '分类名称', dataIndex: 'name', key: 'name' },
    {
      title: '类型',
      dataIndex: 'type',
      key: 'type',
      render: (type) => (
        <Tag color={type === 1 ? 'blue' : 'green'}>
          {type === 1 ? '菜品分类' : '套餐分类'}
        </Tag>
      ),
    },
    { title: '排序', dataIndex: 'sort', key: 'sort' },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status) => (
        <Tag color={status === 1 ? 'success' : 'error'}>
          {status === 1 ? '启用' : '禁用'}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          <Button type="primary" onClick={() => handleEdit(record)}>编辑</Button>
          <Button type="primary" danger onClick={() => handleDelete(record.id)}>删除</Button>
        </Space>
      ),
    },
  ];

  return (
    <Card title="分类管理">
      <Space style={{ marginBottom: 16 }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增分类
        </Button>
      </Space>
      <Table
        columns={columns}
        dataSource={categories}
        rowKey="id"
        loading={loading}
        bordered
      />
      <Modal
        title={editingCategory ? '编辑分类' : '新增分类'}
        open={isModalVisible}
        onCancel={() => setIsModalVisible(false)}
        footer={null}
        destroyOnClose
      >
        <CategoryForm 
          initialValues={editingCategory}
          onFormSubmit={handleFormSubmit}
          onCancel={() => setIsModalVisible(false)}
        />
      </Modal>
    </Card>
  );
};

export default CategoryManagement;
