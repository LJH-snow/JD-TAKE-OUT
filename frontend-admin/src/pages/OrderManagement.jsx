import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Button, 
  Input, 
  Space, 
  Card, 
  App, 
  Tag, 
  Modal, 
  Form, 
  Row, 
  Col, 
  Select, 
  DatePicker, 
  Descriptions,
  Dropdown,
  Menu
} from 'antd';
import { SearchOutlined, EyeOutlined, DownloadOutlined } from '@ant-design/icons';
import apiClient from '../api';
import { useCurrentUser } from '../hooks/useCurrentUser';
import dayjs from 'dayjs';

const { Option } = Select;
const { RangePicker } = DatePicker;

const getStatusTag = (status) => {
  switch (status) {
    case 1: return <Tag color="gold">待付款</Tag>;
    case 2: return <Tag color="orange">待接单</Tag>;
    case 3: return <Tag color="blue">已接单</Tag>;
    case 4: return <Tag color="processing">派送中</Tag>;
    case 5: return <Tag color="success">已完成</Tag>;
    case 6: return <Tag color="default">已取消</Tag>;
    default: return <Tag>未知</Tag>;
  }
};

const OrderManagement = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [isDetailModalVisible, setIsDetailModalVisible] = useState(false);
  const [isExportModalVisible, setIsExportModalVisible] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [exportConfig, setExportConfig] = useState({ format: 'xlsx' });
  const [form] = Form.useForm();
  const [exportForm] = Form.useForm();
  const { message, modal } = App.useApp();
  const { currentUser } = useCurrentUser();

  const fetchOrders = async (params = {}) => {
    setLoading(true);
    try {
      const queryParams = {
        page: params.page,
        pageSize: params.pageSize,
        ...params.filters,
      };
      const isAdmin = currentUser?.role === 'admin';
      const endpoint = isAdmin ? '/admin/orders' : '/employee/orders';
      const response = await apiClient.get(endpoint, { params: queryParams });
      if (response.data && response.data.code === 200) {
        setOrders(response.data.data.items);
        setPagination(prev => ({
          ...prev,
          current: params.page,
          pageSize: params.pageSize,
          total: response.data.data.total,
        }));
      } else {
        message.error(response.data.message || '获取订单列表失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取订单列表');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders({ page: 1, pageSize: 10 });
  }, []);

  const handleTableChange = (newPagination) => {
    const filters = form.getFieldsValue();
    fetchOrders({
      page: newPagination.current,
      pageSize: newPagination.pageSize,
      filters: formatFilters(filters),
    });
  };

  const handleSearch = (values) => {
    fetchOrders({ page: 1, pageSize: pagination.pageSize, filters: formatFilters(values) });
  };

  const formatFilters = (values) => {
    const formatted = { ...values };
    if (values.dateRange) {
      formatted.date_from = values.dateRange[0].format('YYYY-MM-DD');
      formatted.date_to = values.dateRange[1].format('YYYY-MM-DD');
    }
    delete formatted.dateRange;
    return formatted;
  };

  const showDetailsModal = async (id) => {
    try {
      const isAdmin = currentUser?.role === 'admin';
      const endpoint = isAdmin ? `/admin/orders/${id}` : `/employee/orders/${id}`;
      const response = await apiClient.get(endpoint);
      if (response.data && response.data.code === 200) {
        setSelectedOrder(response.data.data);
        setIsDetailModalVisible(true);
      } else {
        message.error('获取订单详情失败');
      }
    } catch (error) {
      message.error('网络错误，无法获取订单详情');
    }
  };

  const handleUpdateStatus = (orderId, newStatus) => {
    modal.confirm({
      title: '确认操作',
      content: `您确定要将此订单状态更新为 "${getStatusTag(newStatus).props.children}" 吗？`,
      onOk: async () => {
        try {
          const isAdmin = currentUser?.role === 'admin';
          const endpoint = isAdmin ? `/admin/orders/${orderId}/status` : `/employee/orders/${orderId}/status`;
          await apiClient.put(endpoint, { status: newStatus });
          message.success('状态更新成功');
          fetchOrders({ page: pagination.current, pageSize: pagination.pageSize, filters: formatFilters(form.getFieldsValue()) });
        } catch (error) {
          message.error('状态更新失败');
        }
      },
    });
  };

  const showExportModal = (format) => {
    const filters = form.getFieldsValue();
    let nameParts = ['orders'];

    const statusMap = { 2: '待接单', 3: '已接单', 4: '派送中', 5: '已完成', 6: '已取消' };
    if (filters.status && statusMap[filters.status]) {
      nameParts.push(statusMap[filters.status]);
    }

    if (filters.dateRange && filters.dateRange.length === 2) {
      const startDate = filters.dateRange[0].format('YYYYMMDD');
      const endDate = filters.dateRange[1].format('YYYYMMDD');
      nameParts.push(`${startDate}-${endDate}`);
    } else {
      nameParts.push(dayjs().format('YYYYMMDD'));
    }

    if (filters.phone) {
      nameParts.push(filters.phone);
    } else if (filters.number) {
      nameParts.push(filters.number);
    }

    const defaultFilename = `${nameParts.join('_')}.${format}`;

    setExportConfig({ format });
    exportForm.setFieldsValue({ filename: defaultFilename });
    setIsExportModalVisible(true);
  };

  const handleConfirmExport = async ({ filename }) => {
    setIsExportModalVisible(false);
    const format = exportConfig.format;
    const key = 'exporting';
    message.loading({ content: `正在生成 ${format.toUpperCase()} 文件...`, key });

    try {
      const filters = form.getFieldsValue();
      const params = { ...formatFilters(filters), format };

      const response = await apiClient.get('/admin/orders/export', {
        params,
        responseType: 'blob',
      });

      const blob = new Blob([response.data], { type: response.headers['content-type'] });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;

      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();

      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
      message.success({ content: '文件已开始下载！', key, duration: 2 });

    } catch (error) {
      message.error({ content: '导出失败，请检查网络或联系管理员', key, duration: 2 });
      console.error("Export failed:", error);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '订单号', dataIndex: 'number', key: 'number' },
    { title: '用户', dataIndex: ['user', 'name'], key: 'user' },
    { title: '手机号', dataIndex: 'phone', key: 'phone' },
    { 
      title: '总金额', 
      dataIndex: 'amount', 
      key: 'amount', 
      render: (text) => `¥${text.toFixed(2)}`
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: getStatusTag,
    },
    {
      title: '下单时间',
      dataIndex: 'order_time',
      key: 'order_time',
      render: (text) => dayjs(text).format('YYYY-MM-DD HH:mm'),
    },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          <Button icon={<EyeOutlined />} onClick={() => showDetailsModal(record.id)}>详情</Button>
          {record.status === 2 && <Button type="primary" onClick={() => handleUpdateStatus(record.id, 3)}>接单</Button>}
          {record.status === 3 && <Button type="primary" onClick={() => handleUpdateStatus(record.id, 4)}>派送</Button>}
          {record.status === 4 && <Button type="primary" success onClick={() => handleUpdateStatus(record.id, 5)}>完成</Button>}
        </Space>
      ),
    },
  ];

  const exportMenu = (
    <Menu onClick={({ key }) => showExportModal(key)}>
      <Menu.Item key="xlsx">导出为 Excel (.xlsx)</Menu.Item>
      <Menu.Item key="csv">导出为 CSV (.csv)</Menu.Item>
    </Menu>
  );

  return (
    <Card title="订单管理">
      <Form form={form} onFinish={handleSearch} layout="vertical">
        <Row gutter={16}>
          <Col span={6}><Form.Item name="number" label="订单号"><Input placeholder="输入订单号" /></Form.Item></Col>
          <Col span={6}><Form.Item name="phone" label="用户手机号"><Input placeholder="输入手机号" /></Form.Item></Col>
          <Col span={6}><Form.Item name="status" label="订单状态"><Select placeholder="选择状态" allowClear><Option value={2}>待接单</Option><Option value={3}>已接单</Option><Option value={4}>派送中</Option><Option value={5}>已完成</Option><Option value={6}>已取消</Option></Select></Form.Item></Col>
          <Col span={6}><Form.Item name="dateRange" label="下单日期"><RangePicker style={{ width: '100%' }} /></Form.Item></Col>
        </Row>
        <Row>
          <Col span={24} style={{ textAlign: 'right' }}>
            <Space>
              <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>搜索</Button>
              <Button onClick={() => { form.resetFields(); handleSearch({}); }}>重置</Button>
              {currentUser?.role === 'admin' && (
                <Dropdown overlay={exportMenu}>
                  <Button icon={<DownloadOutlined />}>
                    导出订单
                  </Button>
                </Dropdown>
              )}
            </Space>
          </Col>
        </Row>
      </Form>
      <Table
        columns={columns}
        dataSource={orders}
        rowKey="id"
        pagination={pagination}
        loading={loading}
        onChange={handleTableChange}
        bordered
        style={{ marginTop: 16 }}
      />
      {selectedOrder && (
        <Modal
          title={`订单详情 (ID: ${selectedOrder.id})`}
          open={isDetailModalVisible}
          onCancel={() => setIsDetailModalVisible(false)}
          footer={<Button onClick={() => setIsDetailModalVisible(false)}>关闭</Button>}
          width={800}
        >
          <Descriptions bordered column={2}>
            <Descriptions.Item label="订单号">{selectedOrder.number}</Descriptions.Item>
            <Descriptions.Item label="状态">{getStatusTag(selectedOrder.status)}</Descriptions.Item>
            <Descriptions.Item label="下单用户">{selectedOrder.user?.name || 'N/A'}</Descriptions.Item>
            <Descriptions.Item label="用户手机">{selectedOrder.phone}</Descriptions.Item>
            <Descriptions.Item label="下单时间">{dayjs(selectedOrder.order_time).format('YYYY-MM-DD HH:mm:ss')}</Descriptions.Item>
            <Descriptions.Item label="总金额">¥{selectedOrder.amount.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="收货人">{selectedOrder.consignee}</Descriptions.Item>
            <Descriptions.Item label="收货地址" span={2}>{selectedOrder.address}</Descriptions.Item>
            <Descriptions.Item label="备注">{selectedOrder.remark || '无'}</Descriptions.Item>
          </Descriptions>
          <h4 style={{marginTop: 16}}>菜品明细</h4>
          <Table 
            dataSource={selectedOrder.order_details}
            rowKey="id"
            pagination={false}
            size="small"
            columns={[
              { title: '菜品名称', dataIndex: 'name', key: 'name' },
              { title: '数量', dataIndex: 'number', key: 'number' },
              { title: '单价', dataIndex: 'amount', key: 'amount', render: (val, rec) => `¥${(val/rec.number).toFixed(2)}` },
              { title: '总价', dataIndex: 'amount', key: 'total', render: (val) => `¥${val.toFixed(2)}` },
            ]}
          />
        </Modal>
      )}
      <Modal
        title="导出设置"
        open={isExportModalVisible}
        onCancel={() => setIsExportModalVisible(false)}
        onOk={() => exportForm.submit()}
        okText="确认导出"
        cancelText="取消"
      >
        <Form form={exportForm} onFinish={handleConfirmExport} layout="vertical" initialValues={{ filename: '' }}>
          <Form.Item
            name="filename"
            label="文件名"
            rules={[{ required: true, message: '请输入文件名！' }]}
          >
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  );
};

export default OrderManagement;