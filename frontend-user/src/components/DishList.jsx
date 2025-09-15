import React, { forwardRef } from 'react';
import './DishList.css';

const DishList = forwardRef(({ menuData = [], cartQuantityMap = {}, onAddToCart, onDecrement, onSelectFlavor, isStoreOpen }, ref) => {

  const handleAddClick = (dish) => {
    if (dish.flavors && dish.flavors.length > 0) {
      onSelectFlavor(dish);
    } else {
      onAddToCart(dish);
    }
  };

  return (
    <div className="dish-list-container" ref={ref}>
      {menuData.length === 0 ? (
        <p>加载中...</p>
      ) : (
        menuData.map(group => (
          group && group.category && (
            <div 
              key={group.category.id} 
              id={`category-${group.category.id}`} 
              className="dish-group"
              data-category-id={group.category.id}
            >
              <h3 className="category-title">{group.category.name}</h3>
              <ul>
                {group.dishes && group.dishes.map(dish => {
                  const quantity = cartQuantityMap[dish.id] || 0;
                  return (
                    <li key={dish.id} className="dish-item">
                      <img 
                        src={dish.image ? (dish.image.startsWith('http') ? dish.image : `http://localhost:8090${dish.image}`) : '/default-dish.png'} 
                        alt={dish.name} 
                        className="dish-image" 
                      />
                      <div className="dish-details">
                        <h4 className="dish-name">{dish.name}</h4>
                        <p className="dish-description">{dish.description}</p>
                        <p className="dish-price">¥{dish.price ? dish.price.toFixed(2) : '0.00'}</p>
                      </div>
                      <div className="dish-controls">
                        {quantity > 0 && (
                          <>
                            <button className="quantity-button" onClick={() => onDecrement(dish.id)} disabled={!isStoreOpen}>-</button>
                            <span className="quantity-display">{quantity}</span>
                          </>
                        )}
                        <button className="quantity-button add" onClick={() => handleAddClick(dish)} disabled={!isStoreOpen}>+</button>
                      </div>
                    </li>
                  );
                })}
              </ul>
            </div>
          )
        ))
      )}
    </div>
  );
});

export default DishList;