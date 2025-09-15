import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import StorePage from './pages/StorePage';
import OrderConfirmationPage from './pages/OrderConfirmationPage';
import UserProfilePage from './pages/UserProfilePage';
import AddressListPage from './pages/AddressListPage';
import AddressEditPage from './pages/AddressEditPage';
import ProfileEditPage from './pages/ProfileEditPage';
import ProtectedRoute from './components/ProtectedRoute';
import './App.css';

import OrderListPage from './pages/OrderListPage';
import OrderDetailPage from './pages/OrderDetailPage';
import SettingsPage from './pages/SettingsPage';
import CustomerServicePage from './pages/CustomerServicePage';
import FaqPage from './pages/FaqPage';
import AccountSecurityPage from './pages/AccountSecurityPage';
import PrivacySettingsPage from './pages/PrivacySettingsPage';
import AboutUsPage from './pages/AboutUsPage';
import OrderSuccessPage from './pages/OrderSuccessPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<StorePage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />

        {/* 受保护的路由 */}
        <Route element={<ProtectedRoute />}>
          <Route path="/checkout" element={<OrderConfirmationPage />} />
          <Route path="/profile" element={<UserProfilePage />} />
          <Route path="/addresses" element={<AddressListPage />} />
          <Route path="/addresses/edit/:id" element={<AddressEditPage />} />
          <Route path="/addresses/new" element={<AddressEditPage />} />
          <Route path="/profile/edit" element={<ProfileEditPage />} />
          <Route path="/orders" element={<OrderListPage />} />
          <Route path="/orders/:id" element={<OrderDetailPage />} />
          <Route path="/order/success" element={<OrderSuccessPage />} />
          
          <Route path="/settings" element={<SettingsPage />} />
          <Route path="/settings/account-security" element={<AccountSecurityPage />} />
          <Route path="/settings/privacy" element={<PrivacySettingsPage />} />
          <Route path="/settings/about" element={<AboutUsPage />} />

          <Route path="/support/contact" element={<CustomerServicePage />} />
          <Route path="/support/faq" element={<FaqPage />} />
        </Route>

      </Routes>
    </Router>
  );
}

export default App;
