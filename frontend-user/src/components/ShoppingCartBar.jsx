
import React, { useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import './ShoppingCartBar.css';

const ShoppingCartBar = ({ isVisible, cartItems = [], onShowDetails }) => {
  const navigate = useNavigate();

  const { totalCount, totalPrice } = useMemo(() => {
    return cartItems.reduce((acc, item) => {
      if (item && typeof item.amount === 'number') {
        acc.totalCount += item.number;
        acc.totalPrice += item.amount * item.number;
      }
      return acc;
    }, { totalCount: 0, totalPrice: 0 });
  }, [cartItems]);

  const minPrice = 20;
  const deliveryFee = 5;

  const isCheckoutDisabled = totalPrice < minPrice || totalCount === 0;

  const handleCheckout = () => {
    navigate('/checkout');
  };

  return (
    <div className={`shopping-cart-bar-container ${isVisible ? '' : 'hidden'}`}>
      <div className="cart-clickable-area" onClick={onShowDetails}>
        <div className="cart-icon-wrapper">
          <div className="cart-icon">
            🛒
            {totalCount > 0 && <span className="cart-item-count">{totalCount}</span>}
          </div>
        </div>
        <div className="cart-info">
          {totalCount > 0 ? (
            <p className="total-price">¥{totalPrice.toFixed(2)}</p>
          ) : (
            <p className="empty-cart-text">未选购商品</p>
          )}
          <p className="delivery-fee">
            <span>免配送费</span>
            <del>¥{deliveryFee.toFixed(2)}</del>
          </p>
        </div>
      </div>
      <div className="checkout-button-wrapper">
        <button 
          className="checkout-button" 
          disabled={isCheckoutDisabled}
          onClick={handleCheckout}
        >
          {isCheckoutDisabled && totalCount > 0
            ? `还差¥${(minPrice - totalPrice).toFixed(2)}`
            : '去结算'}
        </button>
      </div>
    </div>
  );
};

export default ShoppingCartBar;
