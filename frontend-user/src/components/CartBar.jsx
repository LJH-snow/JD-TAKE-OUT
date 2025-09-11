import React from 'react';
import useStore from '../store';
import { Button } from 'antd-mobile';
import qishouImage from './icons/qishou.jpg'; // 导入图片
import './CartBar.css';
import { useNavigate } from 'react-router-dom'; // NEW IMPORT

const CartBar = () => {
  const cart = useStore((state) => state.cart);
  const navigate = useNavigate(); // NEW HOOK

  const totalAmount = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);

  const cartIsEmpty = totalItems === 0;
  const containerClasses = `cart-bar-container ${cartIsEmpty ? 'empty' : ''}`;

  const handleBarClick = () => {
    if (!cartIsEmpty) { // Only navigate if cart is not empty
      navigate('/cart');
    }
  };

  const handleCheckoutClick = (e) => {
    e.stopPropagation(); // Prevent parent div's click event
    if (!cartIsEmpty) { // Only navigate if cart is not empty
      navigate('/checkout');
    }
  };

  return (
    <div className={containerClasses} onClick={handleBarClick}> {/* ADD onClick */}
      <div className="cart-icon-wrapper">
        <img src={qishouImage} alt="骑手" className="cart-rider-icon" />
        {totalItems > 0 && <div className="cart-badge">{totalItems}</div>}
      </div>
      <div className="cart-total-amount">
        {totalAmount > 0 ? `¥${totalAmount.toFixed(2)}` : '购物车为空'}
      </div>
      <div className="cart-checkout-button">
        <Button color="primary" shape="rounded" disabled={cartIsEmpty} onClick={handleCheckoutClick}> {/* ADD onClick */}
          去结算
        </Button>
      </div>
    </div>
  );
};

export default CartBar;
