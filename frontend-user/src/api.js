import axios from 'axios';

const apiClient = axios.create({
  baseURL: '/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

export const fetchStoreSettings = () => apiClient.get('/store-settings');

export const fetchMenu = () => apiClient.get('/menu'); // 获取完整菜单

// 以下接口在新的联动设计中不再使用，暂时保留
export const fetchCategories = () => apiClient.get('/categories');

export const fetchDishesByCategory = (categoryId) => apiClient.get(`/dishes?categoryId=${categoryId}`);

export default apiClient;
