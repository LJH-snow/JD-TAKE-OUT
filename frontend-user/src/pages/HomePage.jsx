import React from 'react';
import MerchantInfo from '../components/MerchantInfo';
import DishList from '../components/DishList';
import './HomePage.css';

const HomePage = () => {
  return (
    <div className="homepage-container">
      <MerchantInfo />
      <div className="dish-list-wrapper">
        <DishList />
      </div>
    </div>
  );
};

export default HomePage;
