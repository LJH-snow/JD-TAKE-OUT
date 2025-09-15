import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { getMe, updateUserProfile, uploadAvatar } from '../api';
import { useAuth } from '../context/AuthContext';
import './ProfileEditPage.css';

const ProfileEditPage = () => {
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [sex, setSex] = useState('1');
  const [avatarPreview, setAvatarPreview] = useState(null);
  const [avatarFile, setAvatarFile] = useState(null);

  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  const auth = useAuth();

  useEffect(() => {
    if (auth.user) {
      const user = auth.user;
      setName(user.name || '');
      setPhone(user.phone || '');
      setSex(user.sex || '1');

      if (user.avatar) {
        // Prepend backend base URL if the avatar URL is relative
        const avatarUrl = user.avatar.startsWith('http') ? user.avatar : `http://localhost:8090${user.avatar}`;
        setAvatarPreview(avatarUrl);
      } else if (user.sex === '1') {
        setAvatarPreview('/images/avatars/default_male.png');
      } else if (user.sex === '0') {
        setAvatarPreview('/images/avatars/default_female.png');
      } else {
        setAvatarPreview('/images/avatars/default.png');
      }
    }
    setLoading(false);
  }, [auth.user]);

  const handleAvatarClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setAvatarFile(file);
      setAvatarPreview(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    let newAvatarUrl = auth.user.avatar; // Start with the current avatar URL

    try {
      // Step 1: If a new file is selected, upload it first.
      if (avatarFile) {
        const uploadResponse = await uploadAvatar(avatarFile);
        if (uploadResponse.data && uploadResponse.data.code === 200) {
          newAvatarUrl = uploadResponse.data.data.url; // Get the real, persistent URL from the backend
        } else {
          throw new Error(uploadResponse.data.message || '头像上传失败');
        }
      }

      // Step 2: Update user profile with name, sex, and potentially new avatar URL.
      const updatedData = { 
        name,
        sex,
        avatar: newAvatarUrl,
      };

      const profileResponse = await updateUserProfile(updatedData);
      if (profileResponse.data && profileResponse.data.code === 200) {
        setSuccess('信息更新成功！');
        
        // Step 3: Update the global auth context with the latest data.
        auth.updateUser(updatedData);

        setTimeout(() => navigate('/profile'), 1500);
      } else {
        throw new Error(profileResponse.data.message || '更新用户信息失败');
      }
    } catch (err) {
      setError(err.message || '操作失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="profile-edit-page">加载中...</div>;
  }

  return (
    <div className="profile-edit-page">
      <header className="edit-header">
        <button onClick={() => navigate(-1)} className="back-button">&lt;</button>
        <h1>编辑个人资料</h1>
      </header>
      <form onSubmit={handleSubmit} className="edit-form">
        <div className="form-group avatar-uploader" onClick={handleAvatarClick}>
          <img src={avatarPreview || '/images/avatars/default.png'} alt="Avatar" className="avatar-preview" />
          <input 
            type="file" 
            ref={fileInputRef} 
            onChange={handleFileChange}
            style={{ display: 'none' }} 
            accept="image/*"
          />
          <span>点击更换头像</span>
        </div>

        <div className="form-group">
          <label htmlFor="name">姓名</label>
          <input id="name" type="text" value={name} onChange={(e) => setName(e.target.value)} />
        </div>
        <div className="form-group">
          <label htmlFor="phone">手机号</label>
          <input id="phone" type="text" value={phone} disabled />
          <small>手机号暂不支持修改</small>
        </div>
        <div className="form-group">
          <label>性别</label>
          <div className="gender-group">
            <label><input type="radio" name="sex" value="1" checked={sex === '1'} onChange={(e) => setSex(e.target.value)} /> 男</label>
            <label><input type="radio" name="sex" value="0" checked={sex === '0'} onChange={(e) => setSex(e.target.value)} /> 女</label>
          </div>
        </div>
        
        {error && <p className="error-message">{error}</p>}
        {success && <p className="success-message">{success}</p>}

        <button type="submit" className="save-button" disabled={loading}>
          {loading ? '保存中...' : '保存'}
        </button>
      </form>
    </div>
  );
};

export default ProfileEditPage;
