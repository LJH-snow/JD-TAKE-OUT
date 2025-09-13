import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { getAddressBooks, deleteAddressBook, setDefaultAddressBook } from '../api';
import './AddressListPage.css';

const AddressListPage = () => {
  const [addresses, setAddresses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const fetchAddresses = async () => {
    try {
      setLoading(true);
      setError('');
      const response = await getAddressBooks();
      if (response.data && response.data.code === 200) {
        setAddresses(response.data.data || []);
      } else {
        setError(response.data.message || '获取地址列表失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '加载数据失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAddresses();
  }, []);

  const handleDelete = async (id) => {
    if (window.confirm('确定要删除这个地址吗？')) {
      try {
        const response = await deleteAddressBook(id);
        if (response.data && response.data.code === 200) {
          fetchAddresses(); // Re-fetch addresses after deletion
        } else {
          alert(response.data.message || '删除失败');
        }
      } catch (err) {
        alert(err.response?.data?.message || '删除失败，请稍后再试');
      }
    }
  };

  const handleSetDefault = async (id) => {
    try {
      const response = await setDefaultAddressBook(id);
      if (response.data && response.data.code === 200) {
        fetchAddresses(); // Re-fetch to show updated default address
      } else {
        alert(response.data.message || '设置默认地址失败');
      }
    } catch (err) {
      alert(err.response?.data?.message || '设置失败，请稍后再试');
    }
  };

  if (loading) {
    return <div className="address-list-page">加载中...</div>;
  }

  if (error) {
    return <div className="address-list-page error-message">错误: {error}</div>;
  }

  return (
    <div className="address-list-page">
      <h1>地址管理</h1>
      <div className="address-list">
        {addresses.length === 0 ? (
          <p>您还没有添加任何地址。</p>
        ) : (
          addresses.map(address => (
            <div key={address.id} className={`address-card ${address.is_default ? 'default' : ''}`}>
              <div className="address-info">
                <div className="contact-info">
                  <span className="consignee">{address.consignee}</span>
                  <span className="phone">{address.phone}</span>
                  {address.is_default ? <span className="default-tag">默认</span> : null}
                </div>
                <p className="full-address">{address.formatted_address || `${address.province_name}${address.city_name}${address.district_name}${address.detail}`}</p>
              </div>
              <div className="address-actions">
                <button onClick={() => navigate(`/addresses/edit/${address.id}`)}>编辑</button>
                <button onClick={() => handleDelete(address.id)}>删除</button>
                {!address.is_default && (
                  <button onClick={() => handleSetDefault(address.id)}>设为默认</button>
                )}
              </div>
            </div>
          ))
        )}
      </div>
      <div className="add-address-container">
        <Link to="/addresses/new" className="add-address-btn">+ 新增收货地址</Link>
      </div>
    </div>
  );
};

export default AddressListPage;
