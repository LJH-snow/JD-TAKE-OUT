import React from 'react';
import { useStore } from '../context/StoreContext';
import './StoreClosedOverlay.css';

const StoreClosedOverlay = () => {
  const { isOpen, storeName } = useStore();

  // If the store is open, render nothing.
  if (isOpen) {
    return null;
  }

  return (
    <div className="store-closed-overlay active">
      <div className="overlay-content">
        <div className="icon">🌙</div>
        <h2>{storeName} 已打烊</h2>
        <p>非营业时段，暂不接受新订单。</p>
        <p>我们的营业时间是：周一至周日 10:00 - 22:00</p>
      </div>
    </div>
  );
};

export default StoreClosedOverlay;
