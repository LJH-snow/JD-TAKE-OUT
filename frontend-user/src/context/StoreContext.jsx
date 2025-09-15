import React, { createContext, useState, useContext, useEffect } from 'react';
import { apiClient } from '../api';

const StoreContext = createContext(null);

export const StoreProvider = ({ children }) => {
  const [isOpen, setIsOpen] = useState(true); // Default to true to avoid flash of closed state
  const [storeName, setStoreName] = useState('店铺加载中...');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStoreStatus = async () => {
      try {
        const response = await apiClient.get('/store-settings');
        if (response.data && response.data.code === 200) {
          setIsOpen(response.data.data.is_open);
          setStoreName(response.data.data.name);
        } else {
          // In case of API error, assume store is closed for safety
          setIsOpen(false);
        }
      } catch (error) {
        console.error("Failed to fetch store settings:", error);
        setIsOpen(false); // Assume closed on network error
      } finally {
        setLoading(false);
      }
    };

    fetchStoreStatus();
  }, []);

  const storeValue = {
    isOpen,
    storeName,
    loading,
  };

  return (
    <StoreContext.Provider value={storeValue}>
      {children}
    </StoreContext.Provider>
  );
};

export const useStore = () => {
  return useContext(StoreContext);
};
