import React from 'react';
import { Modal, Button, List, Avatar, Typography, Empty } from 'antd';
import { DeleteOutlined, PlusOutlined, MinusOutlined } from '@ant-design/icons';
import { useCart } from '../context/CartContext';
import './ShoppingCartModal.css';

const { Text } = Typography;

const ShoppingCartModal = ({ visible, onClose }) => {
  const { items, addItem, removeItem, clearCart, totalPrice } = useCart();

  return (
    <Modal
      title="购物车"
      visible={visible}
      onCancel={onClose}
      footer={null}
      bodyStyle={{ padding: 0 }}
      className="shopping-cart-modal"
    >
      <div className="cart-modal-header">
        <Button type="text" icon={<DeleteOutlined />} onClick={clearCart}>
          清空购物车
        </Button>
      </div>
      <div className="cart-modal-body">
        {items.length > 0 ? (
          <List
            dataSource={items}
            renderItem={item => (
              <List.Item>
                <List.Item.Meta
                  avatar={<Avatar shape="square" size={48} src={item.image || '/default-dish.png'} />}
                  title={<Text className="item-name">{item.name}</Text>}
                  description={<Text className="item-price">￥{item.price.toFixed(2)}</Text>}
                />
                <div className="item-controls">
                  <Button
                    type="text"
                    shape="circle"
                    icon={<MinusOutlined />}
                    onClick={() => removeItem(item)}
                    size="small"
                  />
                  <Text className="item-quantity">{item.quantity}</Text>
                  <Button
                    type="primary"
                    shape="circle"
                    icon={<PlusOutlined />}
                    onClick={() => addItem(item)}
                    size="small"
                  />
                </div>
              </List.Item>
            )}
          />
        ) : (
          <Empty description="购物车是空的" />
        )}
      </div>
      <div className="cart-modal-footer">
        <Text>总计：</Text>
        <Text className="total-price">￥{totalPrice.toFixed(2)}</Text>
      </div>
    </Modal>
  );
};

export default ShoppingCartModal;
