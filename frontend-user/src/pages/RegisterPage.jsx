
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { registerUser } from '../api';
import './LoginPage.css'; // 复用登录页面的样式

const RegisterPage = () => {
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [sex, setSex] = useState('1'); // 默认值为 '1' (男)
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const auth = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      setError('两次输入的密码不一致');
      return;
    }
    setError('');
    try {
      const response = await registerUser({ name, phone, password, sex });
      if (response.data && response.data.code === 200) {
        alert('注册成功！请登录。');
        navigate('/login', { replace: true });
      } else {
        setError(response.data.message || '注册失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '请求失败，请稍后再试');
    }
  };

  return (
    <div className="login-page">
      <div className="form-container">
        <h2>用户注册</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <input type="text" placeholder="请输入姓名" value={name} onChange={(e) => setName(e.target.value)} required />
          </div>
          <div className="form-group">
            <input type="text" placeholder="请输入手机号" value={phone} onChange={(e) => setPhone(e.target.value)} required />
          </div>
          <div className="form-group gender-group">
            <label><input type="radio" name="sex" value="1" checked={sex === '1'} onChange={(e) => setSex(e.target.value)} /> 男</label>
            <label><input type="radio" name="sex" value="0" checked={sex === '0'} onChange={(e) => setSex(e.target.value)} /> 女</label>
            <label><input type="radio" name="sex" value="" checked={sex === ''} onChange={(e) => setSex(e.target.value)} /> 保密</label>
          </div>
          <div className="form-group">
            <input type="password" placeholder="请输入密码" value={password} onChange={(e) => setPassword(e.target.value)} required />
          </div>
          <div className="form-group">
            <input type="password" placeholder="请再次输入密码" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} required />
          </div>
          {error && <p className="error-message">{error}</p>}
          <button type="submit" className="login-button">注册</button>
        </form>
        <div className="form-footer">
          <Link to="/login">已有账号？立即登录</Link>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;
 RegisterPage;
