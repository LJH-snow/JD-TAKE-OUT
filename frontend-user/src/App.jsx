import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ConfigProvider } from 'antd-mobile';
import zhCN from 'antd-mobile/es/locales/zh-CN';
import AppHeader from './components/AppHeader';
import CartBar from './components/CartBar';
import HomePage from './pages/HomePage';
import './App.css';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';

function App() {
  return (
    <ConfigProvider locale={zhCN}>
      <BrowserRouter>
        <div className="app-container">
          <header className="app-header">
            <AppHeader />
          </header>
          <main className="app-main-content">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/cart" element={<CartPage />} />
              <Route path="/checkout" element={<CheckoutPage />} />
            </Routes>
          </main>
          <footer className="app-footer">
            <CartBar />
          </footer>
        </div>
      </BrowserRouter>
    </ConfigProvider>
  );
}
export default App;