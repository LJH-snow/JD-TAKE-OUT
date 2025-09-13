import React from 'react';
import { Card, Typography, Button, Tag } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import './DishCard.css';

const { Title, Text, Paragraph } = Typography;

const DishCard = ({ dish, onAddToCart }) => {
  const { name, description, image, price, status } = dish;

  const handleAddClick = (e) => {
    e.stopPropagation(); // 防止点击按钮时触发卡片点击事件
    onAddToCart(dish);
  };

  return (
    <Card
      hoverable
      className="dish-card"
      bodyStyle={{ padding: 0 }}
    >
      <div className="dish-card-content">
        <img
          alt={name}
          src={image || '/default-dish.png'}
          className="dish-image"
        />
        <div className="dish-details">
          <Title level={5} className="dish-name">{name}</Title>
          <Paragraph className="dish-description" ellipsis={{ rows: 2 }}>
            {description || '暂无描述'}
          </Paragraph>
          <div className="dish-meta">
            <Text className="dish-sales">月售 100+</Text>
          </div>
          <div className="dish-footer">
            <Text className="dish-price">￥<span className="price-number">{price.toFixed(2)}</span></Text>
            {status === 1 ? (
              <Button
                type="primary"
                shape="circle"
                icon={<PlusOutlined />}
                onClick={handleAddClick}
              />
            ) : (
              <Tag>已售罄</Tag>
            )}
          </div>
        </div>
      </div>
    </Card>
  );
};

export default DishCard;
