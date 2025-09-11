import React from 'react';

const RiderIcon = () => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="100"
      height="100"
      viewBox="0 0 100 100"
    >
      {/* 骑手身体 */}
      <circle cx="50" cy="50" r="10" fill="#F0C14B" />
            {/* 骑手头部 */}
      <circle cx="50" cy="40" r="8" fill="#F5BB00" />
      {/* 骑车的轮子 */}
      <circle cx="30" cy="70" r="15" fill="none" stroke="#333" strokeWidth="4" />
      <circle cx="70" cy="70" r="15" fill="none" stroke="#333" strokeWidth="4" />
      {/* 骑车 */}
      <rect x="15" y="60" width="70" height="10" fill="#333" />
      {/* 骑手背包 */}
      <rect x="45" y="30" width="10" height="10" fill="#F0C14B" />
      {/* 骑手的手 */}
      <line x1="50" y1="47" x2="60" y2="47" stroke="#F5BB00" strokeWidth="3" />
      <line x1="50" y1="47" x2="40" y2="47" stroke="#F5BB00" strokeWidth="3" />
      {/* 骑手的腿 */}
      <line x1="50" y1="55" x2="35" y2="65" stroke="#F5BB00" strokeWidth="3" />
      <line x1="50" y1="55" x2="65" y2="65" stroke="#F5BB00" strokeWidth="3" />
    </svg>
  );
};
export default RiderIcon;
