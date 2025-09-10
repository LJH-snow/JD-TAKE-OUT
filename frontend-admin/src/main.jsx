import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { App as AntApp } from 'antd'; // 导入 Ant Design 的 App 组件
import App from './App.jsx';
import './index.css';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <AntApp>  {/* 使用 AntApp 包裹我们的主应用 */}
        <App />
      </AntApp>
    </BrowserRouter>
  </StrictMode>,
);
