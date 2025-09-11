import React from 'react';
import { Avatar } from 'antd-mobile';
import { UserOutline } from 'antd-mobile-icons';
import './AppHeader.css';
import { useLocation } from 'react-router-dom';

const AppHeader = () => {
  const location = useLocation();
  const isHomePage = location.pathname === '/';

  return (
    <div className={`header-content ${!isHomePage ? 'hidden' : ''}`}> {/* Add hidden class */}
      <div className="header-left">
        {isHomePage && (
          <>
            <Avatar src={null} icon={<UserOutline />} />
            <span className="header-title">个人中心</span>
          </>
        )}
      </div>
      <div className="header-right">
        {/* Status icons can be added here if needed */}
      </div>
    </div>
  );
};

export default AppHeader;
