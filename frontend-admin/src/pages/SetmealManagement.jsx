import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Card, App, Image, Modal } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import apiClient from '../api';
import SetmealForm from '../components/SetmealForm';

const SetmealManagement = () => {
  const [setmeals, setSetmeals] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingSetmeal, setEditingSetmeal] = useState(null);

  const { message, modal } = App.useApp();

  const fetchSetmeals = async (params = {}) => {
    setLoading(true);
    try {
      const queryParams = {
        page: params.page,
        pageSize: params.pageSize,
      };
      const response = await apiClient.get('/admin/setmeals', { params: queryParams });
      if (response.data && response.data.code === 200) {
        setSetmeals(response.data.data.items);
        setPagination(prev => ({
          ...prev,
          current: params.page,
          pageSize: params.pageSize,
          total: response.data.data.total,
        }));
      } else {
        message.error(response.data.message || '获取套餐列表失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取套餐列表');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSetmeals({ page: 1, pageSize: 10 });
  }, []);

  const handleTableChange = (newPagination) => {
    fetchSetmeals({
      page: newPagination.current,
      pageSize: newPagination.pageSize,
    });
  };

  const handleAdd = () => {
    setEditingSetmeal(null);
    setIsModalVisible(true);
  };

  const handleEdit = (record) => {
    setEditingSetmeal(record);
    setIsModalVisible(true);
  };

  const handleDelete = (id) => {
    modal.confirm({
      title: '确认删除',
      content: `您确定要删除ID为 ${id} 的套餐吗？此操作会一并删除套餐内的菜品关联。`,
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        try {
          const response = await apiClient.delete(`/admin/setmeals/${id}`);
          if (response.status === 200 || response.status === 204) {
            message.success('删除成功');
            // 重新获取第一页数据
            fetchSetmeals({ page: 1, pageSize: pagination.pageSize });
          } else {
            // 此处可能永远不会到达，因为axios错误会直接进catch
            message.error(response.data.message || '删除失败');
          }
        } catch (error) {
          // 即使后端返回204，如果axios配置为在空响应时抛错，也会进入这里
          // 我们假设任何非失败状态码（如200, 204）都算成功
          if (error.response && (error.response.status === 200 || error.response.status === 204)) {
            message.success('删除成功');
            fetchSetmeals({ page: 1, pageSize: pagination.pageSize });
          } else {
            message.error(error.response?.data?.message || '网络错误，删除失败');
          }
        }
      },
    });
  };

  const handleFormSubmit = async (values) => {
    setLoading(true);
    try {
      let response;
      if (editingSetmeal) {
        response = await apiClient.put(`/admin/setmeals/${editingSetmeal.id}`, values);
      } else {
        response = await apiClient.post('/admin/setmeals', values);
      }

      if (response.data && (response.data.code === 200 || response.data.code === 201)) {
        message.success(editingSetmeal ? '更新成功' : '新增成功');
        setIsModalVisible(false);
        fetchSetmeals({ page: pagination.current, pageSize: pagination.pageSize });
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
    {
      title: '图片',
      dataIndex: 'image',
      key: 'image',
      render: (text) => <Image src={text} alt="套餐图片" width={60} height={60} style={{ objectFit: 'cover' }} />,
    },
    { title: '套餐名称', dataIndex: 'name', key: 'name' },
    { title: '所属分类', dataIndex: ['category', 'name'], key: 'category' },
    { 
      title: '价格', 
      dataIndex: 'price', 
      key: 'price', 
      render: (text) => `¥${text.toFixed(2)}`
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status) => (status === 1 ? '在售' : '停售'),
    },
    {
      title: '包含菜品',
      dataIndex: 'setmeal_dishes',
      key: 'dishes',
      render: (dishes) => (
        <span>{dishes.map(d => d.name).join(', ')}</span>
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
    <Card title="套餐管理">
      <Space style={{ marginBottom: 16 }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增套餐
        </Button>
      </Space>
      <Table
        columns={columns}
        dataSource={setmeals}
        rowKey="id"
        pagination={pagination}
        loading={loading}
        onChange={handleTableChange}
        bordered
      />
      <Modal
        title={editingSetmeal ? '编辑套餐' : '新增套餐'}
        open={isModalVisible}
        onCancel={() => setIsModalVisible(false)}
        footer={null}
        destroyOnClose
        width={600}
      >
        <SetmealForm 
          initialValues={editingSetmeal}
          onFormSubmit={handleFormSubmit}
          onCancel={() => setIsModalVisible(false)}
        />
      </Modal>
    </Card>
  );
};

export default SetmealManagement;