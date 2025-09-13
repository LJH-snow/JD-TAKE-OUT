
import React from 'react';
import './ShoppingCartDetails.css';

const ShoppingCartDetails = ({ isVisible, cartItems = [], onClose, onUpdateQuantity, onClearCart }) => {
  if (!isVisible) {
    return null;
  }

  const totalCount = cartItems.reduce((sum, item) => sum + item.number, 0);

  return (
    <>
      <div className="cart-details-backdrop" onClick={onClose}></div>
      <div className="cart-details-container">
        <div className="cart-details-header">
          <h3>购物车 ({totalCount})</h3>
          <button className="clear-cart-button" onClick={onClearCart}>清空</button>
        </div>
        <div className="cart-items-list">
          {cartItems.length > 0 ? (
            cartItems.map(item => (
              <div key={item.id} className="cart-item">
                <div className="item-info">
                  <p className="item-name">{item.name}</p>
                  {item.dish_flavor && (
                    <p className="item-flavors">{item.dish_flavor}</p>
                  )}
                  <p className="item-price">¥{item.amount.toFixed(2)}</p>
                </div>
                <div className="item-controls">
                  <button onClick={() => onUpdateQuantity(item, item.number - 1)}>-</button>
                  <span>{item.number}</span>
                  <button onClick={() => onUpdateQuantity(item, item.number + 1)}>+</button>
                </div>
              </div>
            ))
          ) : (
            <p className="empty-cart-message">购物车是空的</p>
          )}
        </div>
      </div>
    </>
  );
};

export default ShoppingCartDetails;
