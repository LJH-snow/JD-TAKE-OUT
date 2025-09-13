import React, { useState, useEffect } from 'react';
import { Table, Button, Input, Space, Card, App, Image, Modal } from 'antd';
import { PlusOutlined, SearchOutlined } from '@ant-design/icons';
import apiClient from '../api';
import { useCurrentUser } from '../hooks/useCurrentUser';
import DishForm from '../components/DishForm';

const DishManagement = () => {
  const [dishes, setDishes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingDish, setEditingDish] = useState(null);

  const { message, modal } = App.useApp();
  const { currentUser } = useCurrentUser();
  const isAdmin = currentUser?.role === 'admin';

  const fetchDishes = async (params = {}) => {
    setLoading(true);
    try {
      const queryParams = {
        page: params.page,
        limit: params.pageSize,
        name: params.name,
        sortField: params.sortField,
        sortOrder: params.sortOrder,
      };
      const endpoint = isAdmin ? '/admin/dishes' : '/employee/dishes';
      const response = await apiClient.get(endpoint, { params: queryParams });
      if (response.data && response.data.code === 200) {
        setDishes(response.data.data.items);
        setPagination({
          ...pagination,
          current: params.page,
          pageSize: params.pageSize,
          total: response.data.data.total,
        });
      } else {
        message.error(response.data.message || '获取菜品列表失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取菜品列表');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDishes({ page: 1, pageSize: 10 });
  }, []);

  const handleTableChange = (newPagination, filters, sorter) => {
    fetchDishes({
      page: newPagination.current,
      pageSize: newPagination.pageSize,
      name: searchTerm,
      sortField: sorter.field,
      sortOrder: sorter.order,
    });
  };

  const handleSearch = () => {
    fetchDishes({ page: 1, pageSize: pagination.pageSize, name: searchTerm });
  };

  const handleAdd = () => {
    setEditingDish(null);
    setIsModalVisible(true);
  };

  const handleEdit = (record) => {
    setEditingDish(record);
    setIsModalVisible(true);
  };

  const handleDelete = (id) => {
    modal.confirm({
      title: '确认删除',
      content: `您确定要删除ID为 ${id} 的菜品吗？此操作不可撤销。`,
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        try {
          const endpoint = `/admin/dishes/${id}`;
          const response = await apiClient.delete(endpoint);
          if (response.status === 204) {
            message.success('删除成功');
            fetchDishes({ page: 1, pageSize: pagination.pageSize, name: searchTerm });
          } else {
            message.error(response.data.message || '删除失败');
          }
        } catch (error) {
          message.error('网络错误，删除失败');
        }
      },
    });
  };

  const handleFormSubmit = async (values) => {
    setLoading(true);
    try {
      let response;
      if (editingDish) {
        const endpoint = `/admin/dishes/${editingDish.id}`;
        response = await apiClient.put(endpoint, values);
      } else {
        const endpoint = '/admin/dishes';
        response = await apiClient.post(endpoint, values);
      }

      if (response.data && (response.data.code === 200 || response.data.code === 201)) {
        message.success(editingDish ? '更新成功' : '新增成功');
        setIsModalVisible(false);
        fetchDishes({ page: pagination.current, pageSize: pagination.pageSize, name: searchTerm });
      } else {
        message.error(response.data.message || '操作失败');
      }
    } catch (error) {
      message.error('网络错误，操作失败');
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80, sorter: true },
    {
      title: '图片',
      dataIndex: 'image',
      key: 'image',
      render: (text) => <Image src={text} alt="菜品图片" width={60} height={60} style={{ objectFit: 'cover', borderRadius: '4px' }} />,
    },
    { title: '菜品名称', dataIndex: 'name', key: 'name', sorter: true },
    {
      title: '所属分类',
      dataIndex: ['category', 'name'],
      key: 'category',
    },
    { 
      title: '价格', 
      dataIndex: 'price', 
      key: 'price', 
      sorter: true,
      render: (text) => `¥${text.toFixed(2)}`
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status) => (status === 1 ? '在售' : '停售'),
    },
    ...(isAdmin ? [{
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          <Button type="primary" onClick={() => handleEdit(record)}>编辑</Button>
          <Button type="primary" danger onClick={() => handleDelete(record.id)}>删除</Button>
        </Space>
      ),
    }] : []),
  ];

  return (
    <Card title={isAdmin ? "菜品管理" : "菜品查看"}>
      <Space style={{ marginBottom: 16 }}>
        <Input
          placeholder="输入菜品名称搜索"
          prefix={<SearchOutlined />}
          style={{ width: 240 }}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onPressEnter={handleSearch}
        />
        <Button type="primary" onClick={handleSearch}>搜索</Button>
        {isAdmin && (
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
            新增菜品
          </Button>
        )}
      </Space>
      <Table
        columns={columns}
        dataSource={dishes}
        rowKey="id"
        pagination={pagination}
        loading={loading}
        onChange={handleTableChange}
        bordered
      />
      <Modal
        title={editingDish ? '编辑菜品' : '新增菜品'}
        open={isModalVisible}
        onCancel={() => setIsModalVisible(false)}
        footer={null}
        destroyOnClose
      >
        <DishForm 
          initialValues={editingDish}
          onFormSubmit={handleFormSubmit}
          onCancel={() => setIsModalVisible(false)}
        />
      </Modal>
    </Card>
  );
};

export default DishManagement;