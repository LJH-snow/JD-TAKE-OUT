import React, { useState, useEffect } from 'react';
import './FlavorSelectionModal.css';

const FlavorSelectionModal = ({ dish, isVisible, onClose, onAddToCart }) => {
  const [selections, setSelections] = useState({});

  // 模拟的口味数据，当实际菜品没有 flavors 字段时使用
  const MOCK_FLAVORS = [
    { name: '辣度', options: ['不辣', '微辣', '中辣', '特辣'] },
    { name: '忌口', options: ['不要葱', '不要蒜', '不要香菜'] },
  ];

  const flavors = dish?.flavors || MOCK_FLAVORS;

  useEffect(() => {
    if (dish) {
      const defaultSelections = {};
      flavors.forEach(group => {
        let optionsList = [];
        if (group.options) { // 处理模拟数据
          optionsList = group.options;
        } else if (group.value) { // 处理真实API数据
          try {
            optionsList = JSON.parse(group.value.replace(/'/g, '"'));
          } catch (e) { /* a */ }
        }
        if (optionsList.length > 0) {
          defaultSelections[group.name] = optionsList[0];
        }
      });
      setSelections(defaultSelections);
    }
  }, [dish, flavors]);

  if (!isVisible || !dish) {
    return null;
  }

  const handleOptionClick = (groupName, option) => {
    setSelections(prev => ({ ...prev, [groupName]: option }));
  };

  const handleAddToCartClick = () => {
    const flavorsString = Object.values(selections).join(', ');
    onAddToCart(dish, flavorsString);
  };

  return (
    <>
      <div className="flavor-modal-backdrop" onClick={onClose}></div>
      <div className="flavor-modal-container">
        <h3 className="dish-title">{dish.name}</h3>
        <div className="flavor-groups">
          {flavors.map(flavorGroup => {
            let optionsList = [];
            // **关键修复：同时兼容 options 和 value 字段**
            if (flavorGroup.options) {
              optionsList = flavorGroup.options;
            } else if (flavorGroup.value) {
              try {
                // 后端返回的可能是带单引号的字符串，先替换成双引号再解析
                optionsList = JSON.parse(flavorGroup.value.replace(/'/g, '"'));
              } catch (e) {
                console.error("Failed to parse flavor value:", flavorGroup.value, e);
              }
            }

            return (
              <div key={flavorGroup.name} className="flavor-group">
                <h4>{flavorGroup.name}</h4>
                <div className="options">
                  {optionsList.map(option => (
                    <button 
                      key={option} 
                      className={`option-button ${selections[flavorGroup.name] === option ? 'selected' : ''}`}
                      onClick={() => handleOptionClick(flavorGroup.name, option)}
                    >
                      {option}
                    </button>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
        <div className="modal-footer">
          <p className="final-price">¥{dish.price.toFixed(2)}</p>
          <button className="add-to-cart-button" onClick={handleAddToCartClick}>加入购物车</button>
        </div>
      </div>
    </>
  );
};

export default FlavorSelectionModal;