import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getSetmealById, addShoppingCartItem } from '../api';
import { useAuth } from '../context/AuthContext';
import { Spin, Card, Image, Typography, Button, Row, Col, List, message } from 'antd';
import './DetailPage.css'; // 复用详情页的CSS

const { Title, Text, Paragraph } = Typography;

const SetmealDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  const [setmeal, setSetmeal] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchSetmeal = async () => {
      try {
        setLoading(true);
        const response = await getSetmealById(id);
        if (response.data && response.data.code === 200) {
          setSetmeal(response.data.data);
        } else {
          throw new Error(response.data.message || '无法加载套餐信息');
        }
      } catch (err) {
        setError(err.message);
        message.error(`加载失败: ${err.message}`);
      } finally {
        setLoading(false);
      }
    };

    fetchSetmeal();
  }, [id]);

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      if (window.confirm('请先登录再操作')) {
        navigate('/login');
      }
      return;
    }
    try {
      const payload = { setmeal_id: setmeal.id, number: 1 };
      const response = await addShoppingCartItem(payload);
      if (response.data && response.data.code === 200) {
        message.success('添加成功，正在返回...');
        setTimeout(() => navigate('/'), 800); // 延迟后跳转
      } else {
        message.error(response.data.message || "添加失败");
      }
    } catch (err) {
      message.error(err.response?.data?.message || "操作失败");
    }
  };

  if (loading) {
    return <div className="detail-page-container loading"><Spin size="large" /></div>;
  }

  if (error) {
    return <div className="detail-page-container error">无法加载套餐详情。请稍后重试。</div>;
  }

  if (!setmeal) {
    return null;
  }

  return (
    <div className="detail-page-container">
      <Card className="detail-card">
        <Row gutter={[24, 24]}>
          <Col xs={24} md={10}>
            <Image
              width="100%"
              src={setmeal.image}
              alt={setmeal.name}
            />
          </Col>
          <Col xs={24} md={14}>
            <Title level={2}>{setmeal.name}</Title>
            <Paragraph>{setmeal.description || '暂无详细描述。'}</Paragraph>
            <div className="price-line">
              <Text strong className="price">¥{setmeal.price.toFixed(2)}</Text>
            </div>
            
            {setmeal.setmeal_dishes && setmeal.setmeal_dishes.length > 0 && (
              <div className="dishes-section">
                <Title level={5}>套餐包含</Title>
                <List
                  dataSource={setmeal.setmeal_dishes}
                  renderItem={item => (
                    <List.Item>
                      <Text>{item.name} x{item.copies}</Text>
                    </List.Item>
                  )}
                />
              </div>
            )}

            <div className="actions-section">
                <Button type="primary" size="large" onClick={handleAddToCart}>加入购物车</Button>
                <Button size="large" onClick={() => navigate(-1)}>返回</Button>
            </div>
          </Col>
        </Row>
      </Card>
    </div>
  );
};

export default SetmealDetailPage;
