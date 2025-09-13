import React, { useState } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { loginUser } from '../api';
import './LoginPage.css';

const LoginPage = () => {
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const auth = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  // 获取重定向的来源路径，默认为首页
  const from = location.state?.from?.pathname || "/";

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await loginUser({ phone, password, user_type: 'user' });
      if (response.data && response.data.code === 200) { // 后端成功响应码为 200
        const { user, token } = response.data.data;
        auth.login(user, token);
        navigate(from, { replace: true }); // 跳转回之前的页面
      } else {
        setError(response.data.message || '登录失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '请求失败，请稍后再试');
    }
  };

  return (
    <div className="login-page">
      <div className="form-container">
        <h2>用户登录</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <input 
              type="text" 
              placeholder="请输入手机号" 
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required 
            />
          </div>
          <div className="form-group">
            <input 
              type="password" 
              placeholder="请输入密码" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required 
            />
          </div>
          {error && <p className="error-message">{error}</p>}
          <button type="submit" className="login-button">登录</button>
        </form>
        <div className="form-footer">
          <a>忘记密码?</a>
          <Link to="/register">立即注册</Link>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;