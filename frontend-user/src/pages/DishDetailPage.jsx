import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getDishById, addShoppingCartItem } from '../api';
import { useAuth } from '../context/AuthContext';
import { Spin, Card, Image, Typography, Tag, Button, Row, Col, message } from 'antd';
import FlavorSelectionModal from '../components/FlavorSelectionModal';
import './DetailPage.css';

const { Title, Text, Paragraph } = Typography;

const DishDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  const [dish, setDish] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isFlavorModalVisible, setIsFlavorModalVisible] = useState(false);

  useEffect(() => {
    const fetchDish = async () => {
      try {
        setLoading(true);
        const response = await getDishById(id);
        if (response.data && response.data.code === 200) {
          setDish(response.data.data);
        } else {
          throw new Error(response.data.message || '无法加载菜品信息');
        }
      } catch (err) {
        setError(err.message);
        message.error(`加载失败: ${err.message}`);
      } finally {
        setLoading(false);
      }
    };

    fetchDish();
  }, [id]);

  // 用于处理带口味的菜品添加（由弹窗调用）
  const handleAddToCartWithFlavors = async (dish, flavorsString) => {
    if (!isAuthenticated) {
      if (window.confirm('请先登录再操作')) navigate('/login');
      return;
    }
    try {
      const payload = { dish_id: dish.id, number: 1, dish_flavor: flavorsString };
      const response = await addShoppingCartItem(payload);
      if (response.data && response.data.code === 200) {
        message.success('添加成功，正在返回...');
        setIsFlavorModalVisible(false);
        setTimeout(() => navigate('/'), 800);
      } else {
        message.error(response.data.message || "添加失败");
      }
    } catch (err) {
      message.error(err.response?.data?.message || "操作失败");
    }
  };

  // 用于处理无口味的菜品或套餐
  const handleSimpleAddToCart = async () => {
    if (!isAuthenticated) {
      if (window.confirm('请先登录再操作')) navigate('/login');
      return;
    }
    try {
      const payload = { dish_id: dish.id, number: 1 };
      const response = await addShoppingCartItem(payload);
      if (response.data && response.data.code === 200) {
        message.success('添加成功，正在返回...');
        setTimeout(() => navigate('/'), 800);
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
    return <div className="detail-page-container error">无法加载菜品详情。请稍后重试。</div>;
  }

  if (!dish) {
    return null;
  }

  const hasFlavors = dish.flavors && dish.flavors.length > 0;

  return (
    <>
      <div className="detail-page-container">
        <Card className="detail-card">
          <Row gutter={[24, 24]}>
            <Col xs={24} md={10}>
              <Image
                width="100%"
                src={dish.image}
                alt={dish.name}
              />
            </Col>
            <Col xs={24} md={14}>
              <Title level={2}>{dish.name}</Title>
              <Paragraph>{dish.description || '暂无详细描述。'}</Paragraph>
              <div className="price-line">
                <Text strong className="price">¥{dish.price.toFixed(2)}</Text>
              </div>
              {hasFlavors && (
                <div className="flavors-section">
                  <Title level={5}>口味选择</Title>
                  {dish.flavors.map(flavor => (
                    <div key={flavor.id}>
                      <Text>{flavor.name}: </Text>
                      {JSON.parse(flavor.value).map(val => <Tag key={val}>{val}</Tag>)}
                    </div>
                  ))}
                </div>
              )}
              <div className="actions-section">
                  <Button 
                    type="primary" 
                    size="large" 
                    onClick={hasFlavors ? () => setIsFlavorModalVisible(true) : handleSimpleAddToCart}
                  >
                    加入购物车
                  </Button>
                  <Button size="large" onClick={() => navigate(-1)}>返回</Button>
              </div>
            </Col>
          </Row>
        </Card>
      </div>
      <FlavorSelectionModal
        isVisible={isFlavorModalVisible}
        dish={dish}
        onClose={() => setIsFlavorModalVisible(false)}
        onAddToCart={handleAddToCartWithFlavors}
      />
    </>
  );
};

export default DishDetailPage;