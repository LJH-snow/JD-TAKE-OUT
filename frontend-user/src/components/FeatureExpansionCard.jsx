import React from 'react';
import { Link } from 'react-router-dom';
import './FeatureExpansionCard.css';

const Icon = ({ name }) => <i className={`icon-${name}`}></i>;

const FeatureExpansionCard = () => {
  // 根据开发文档，部分功能依赖后端，此处只展示可实现或作为占位符的功能
  const features = [
    { name: '联系客服', icon: 'customer-service', link: '/support/contact' },
    { name: '常见问题', icon: 'faq', link: '/support/faq' },
    { name: '我的红包', icon: 'coupon', link: '/coupons', disabled: true },
    { name: '积分商城', icon: 'points', link: '/points-mall', disabled: true },
  ];

  return (
    <div className="feature-expansion-card">
      <div className="feature-grid">
        {features.map(feature => (
          <Link 
            to={feature.link} 
            key={feature.name} 
            className={`feature-item ${feature.disabled ? 'disabled' : ''}`}
            onClick={(e) => feature.disabled && e.preventDefault()}
          >
            <div className="feature-icon"><Icon name={feature.icon} /></div>
            <p className="feature-name">{feature.name}</p>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default FeatureExpansionCard;
