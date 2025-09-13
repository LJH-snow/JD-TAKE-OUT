import { useState, useEffect } from 'react';
import apiClient from '../api';
import { parseJWTToken, getUserInfoEndpoint } from '../utils/auth';

export const useCurrentUser = () => {
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCurrentUser = async () => {
      try {
        setLoading(true);
        
        // 从token中获取用户角色，决定使用哪个API端点
        const token = localStorage.getItem('jwt_token');
        if (!token) {
          throw new Error('未找到认证token');
        }
        
        const claims = parseJWTToken(token);
        if (!claims || !claims.role) {
          throw new Error('无效的认证token');
        }
        
        // 根据角色获取正确的API端点
        const endpoint = getUserInfoEndpoint(claims.role);
        const response = await apiClient.get(endpoint);
        
        if (response.data && response.data.code === 200) {
          setCurrentUser(response.data.data);
          setError(null);
        } else {
          throw new Error('获取用户信息失败');
        }
      } catch (error) {
        console.error('获取用户信息失败:', error);
        setError(error.message);
        setCurrentUser(null);
      } finally {
        setLoading(false);
      }
    };

    fetchCurrentUser();
  }, []);

  return { currentUser, loading, error };
};