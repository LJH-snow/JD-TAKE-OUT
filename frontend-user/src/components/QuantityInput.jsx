import React from 'react';
import './QuantityInput.css';

const QuantityInput = ({ value, onChange }) => {
  const handleDecrement = () => {
    if (value > 0) {
      onChange(value - 1);
    }
  };

  const handleIncrement = () => {
    onChange(value + 1);
  };

  return (
    <div className="quantity-input">
      <button onClick={handleDecrement} disabled={value <= 0}>-</button>
      <span>{value}</span>
      <button onClick={handleIncrement}>+</button>
    </div>
  );
};

export default QuantityInput;
