import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { App as AntApp } from 'antd';
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
import DishDetailPage from './pages/DishDetailPage';
import SetmealDetailPage from './pages/SetmealDetailPage';
import { useAuth } from './context/AuthContext';
import { getMe } from './api';

function App() {
  const { token, logout, login, setIsLoading } = useAuth();

  useEffect(() => {
    const fetchUserOnLoad = async () => {
      // Only fetch if a token exists
      if (token) {
        try {
          const response = await getMe();
          if (response.data && response.data.code === 200) {
            // Update user context with fresh data
            login(response.data.data, token);
          } else {
            // If getMe fails (e.g., invalid token), log the user out
            logout();
          }
        } catch (error) {
          console.error("Failed to fetch user on app load, logging out.", error);
          logout();
        }
      }
      // In either case, we are done with the initial loading process
      setIsLoading(false);
    };

    fetchUserOnLoad();
  }, []); // Run only once on initial app load

  return (
    <AntApp>
      <Router>
        <Routes>
          <Route path="/" element={<StorePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/dishes/:id" element={<DishDetailPage />} />
          <Route path="/setmeals/:id" element={<SetmealDetailPage />} />

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
    </AntApp>
  );
}

export default App;