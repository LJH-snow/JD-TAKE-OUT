
import React from 'react';
import './CategoryMenu.css';

const CategoryMenu = ({ categories = [], activeCategoryId, onCategoryClick }) => {
  return (
    <nav className="category-menu-container">
      <ul>
        {categories.map(category => (
          <li 
            key={category.id} 
            className={category.id === activeCategoryId ? 'active' : ''}
            onClick={() => onCategoryClick(category.id)}
          >
            {category.name}
          </li>
        ))}
      </ul>
    </nav>
  );
};

export default CategoryMenu;
