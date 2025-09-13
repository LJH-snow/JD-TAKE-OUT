import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { getMe, updateUserProfile } from '../api';
import './ProfileEditPage.css';

const ProfileEditPage = () => {
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [sex, setSex] = useState('');
  const [avatarPreview, setAvatarPreview] = useState(null);
  const [avatarFile, setAvatarFile] = useState(null);

  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const fileInputRef = useRef(null);

  useEffect(() => {
    const fetchCurrentUser = async () => {
      try {
        const response = await getMe();
        if (response.data && response.data.code === 200) {
          const user = response.data.data;
          setName(user.name || '');
          setPhone(user.phone || '');
          setSex(user.sex || '');
          setAvatarPreview(user.avatar); // Set initial avatar
        } else {
          setError('获取用户信息失败');
        }
      } catch (err) {
        setError('加载用户信息失败，请稍后重试');
      } finally {
        setLoading(false);
      }
    };
    fetchCurrentUser();
  }, []);

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

    // In a real app, you would upload the avatarFile first if it exists
    if (avatarFile) {
      console.log('Uploading new avatar file:', avatarFile);
      // const uploadResponse = await uploadAvatar(avatarFile); // API call to upload
      // if (uploadResponse.data.code === 200) {
      //   updatedData.avatar = uploadResponse.data.data.url; // Get new URL
      // } else {
      //   setError('头像上传失败');
      //   return;
      // }
    }

    const updatedData = { name, sex };

    try {
      const response = await updateUserProfile(updatedData);
      if (response.data && response.data.code === 200) {
        setSuccess('信息更新成功！');
        setTimeout(() => navigate('/profile'), 1500);
      } else {
        setError(response.data.message || '更新失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '请求失败，请稍后再试');
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
            <label><input type="radio" name="sex" value="" checked={sex === ''} onChange={(e) => setSex(e.target.value)} /> 保密</label>
          </div>
        </div>
        
        {error && <p className="error-message">{error}</p>}
        {success && <p className="success-message">{success}</p>}

        <button type="submit" className="save-button">保存</button>
      </form>
    </div>
  );
};

export default ProfileEditPage;
