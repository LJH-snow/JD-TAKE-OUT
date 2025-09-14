import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getShoppingCartItems, getAddressBooks, submitOrder } from '../api'; // Import new API functions
import './OrderConfirmationPage.css'; // Assuming a CSS file for styling

const OrderConfirmationPage = () => {
  const navigate = useNavigate();
  const [cartItems, setCartItems] = useState([]);
  const [addresses, setAddresses] = useState([]);
  const [selectedAddressId, setSelectedAddressId] = useState(null);
  const [payMethod, setPayMethod] = useState(1); // Default to 1: WeChat Pay (or first option)
  const [remark, setRemark] = useState('');
  const [tablewareNumber, setTablewareNumber] = useState(0); // Default to 0
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [totalAmount, setTotalAmount] = useState(0);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError('');

        // Fetch shopping cart items
        const cartResponse = await getShoppingCartItems();
        if (cartResponse.data && cartResponse.data.code === 200) {
          setCartItems(cartResponse.data.data);
          // Calculate total amount
          const calculatedTotal = cartResponse.data.data.reduce((sum, item) => sum + (item.amount * item.number), 0);
          setTotalAmount(calculatedTotal);
        } else {
          setError(cartResponse.data.message || '获取购物车失败');
          setLoading(false);
          return;
        }

        // Fetch address books
        const addressResponse = await getAddressBooks();
        if (addressResponse.data && addressResponse.data.code === 200) {
          setAddresses(addressResponse.data.data);
          // Set default address if available
          const defaultAddress = addressResponse.data.data.find(addr => addr.is_default === 1);
          if (defaultAddress) {
            setSelectedAddressId(defaultAddress.id);
          } else if (addressResponse.data.data.length > 0) {
            setSelectedAddressId(addressResponse.data.data[0].id); // Select first if no default
          }
        } else {
          setError(addressResponse.data.message || '获取地址簿失败');
        }
      } catch (err) {
        setError(err.response?.data?.message || '加载数据失败，请稍后再试');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleSubmitOrder = async () => {
    if (!selectedAddressId) {
      setError('请选择收货地址');
      return;
    }
    if (cartItems.length === 0) {
      setError('购物车为空，无法提交订单');
      return;
    }

    try {
      setLoading(true);
      setError('');
      const orderData = {
        address_book_id: selectedAddressId,
        pay_method: payMethod,
        remark: remark,
        tableware_number: tablewareNumber,
      };
      const response = await submitOrder(orderData);
      if (response.data && response.data.code === 200) {
        alert('订单提交成功！');
        // Navigate to an order success page or order list
        navigate('/order/success', { state: { orderId: response.data.data.order_id } }); // Assuming a success page
      } else {
        setError(response.data.message || '订单提交失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '提交订单失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="order-confirmation-page">加载中...</div>;
  }

  if (error) {
    return <div className="order-confirmation-page error-message">错误: {error}</div>;
  }

  return (
    <div className="order-confirmation-page">
      <h1>订单确认</h1>

      {/* 订单详情 */}
      <div className="section">
        <h2>商品清单</h2>
        {cartItems.length === 0 ? (
          <p>购物车为空。</p>
        ) : (
          <div className="item-list">
            {cartItems.map(item => (
              <div key={item.id} className="item-card">
                <img 
                  src={item.image ? (item.image.startsWith('http') ? item.image : `http://localhost:8090${item.image}`) : '/default-dish.png'} 
                  alt={item.name} 
                  className="item-image" 
                />
                <div className="item-info">
                  <p className="item-name">{item.name} {item.dish_flavor && `(${item.dish_flavor})`}</p>
                  <p className="item-price">¥{item.amount.toFixed(2)} x {item.number}</p>
                </div>
                <p className="item-subtotal">¥{(item.amount * item.number).toFixed(2)}</p>
              </div>
            ))}
          </div>
        )}
        <div className="total-amount">
          总计: <span>¥{totalAmount.toFixed(2)}</span>
        </div>
      </div>

      {/* 地址选择 */}
      <div className="section">
        <h2>收货地址</h2>
        {addresses.length === 0 ? (
          <p>您还没有添加收货地址，请前往个人中心添加。</p>
        ) : (
          <div className="address-list">
            {addresses.map(address => (
              <label key={address.id} className="address-card">
                <input
                  type="radio"
                  name="address"
                  value={address.id}
                  checked={selectedAddressId === address.id}
                  onChange={() => setSelectedAddressId(address.id)}
                />
                <div className="address-info">
                  <p>{address.consignee} ({address.sex === '1' ? '先生' : '女士'}) {address.phone}</p>
                  <p>{address.provinceName}{address.cityName}{address.districtName}{address.detail}</p>
                  {address.is_default === 1 && <span className="default-tag">默认</span>}
                </div>
              </label>
            ))}
          </div>
        )}
      </div>

      {/* 支付方式 */}
      <div className="section">
        <h2>支付方式</h2>
        <div className="payment-options">
          <label>
            <input
              type="radio"
              name="payMethod"
              value={1}
              checked={payMethod === 1}
              onChange={() => setPayMethod(1)}
            /> 微信支付
          </label>
          <label>
            <input
              type="radio"
              name="payMethod"
              value={2}
              checked={payMethod === 2}
              onChange={() => setPayMethod(2)}
            /> 支付宝
          </label>
        </div>
      </div>

      {/* 备注和餐具数量 */}
      <div className="section">
        <h2>其他</h2>
        <div className="form-group">
          <label htmlFor="remark">备注:</label>
          <textarea
            id="remark"
            value={remark}
            onChange={(e) => setRemark(e.target.value)}
            placeholder="口味偏好、送餐时间等"
          ></textarea>
        </div>
        <div className="form-group">
          <label htmlFor="tablewareNumber">餐具数量:</label>
          <input
            type="number"
            id="tablewareNumber"
            value={tablewareNumber}
            onChange={(e) => setTablewareNumber(parseInt(e.target.value) || 0)}
            min="0"
          />
        </div>
      </div>

      <button onClick={handleSubmitOrder} className="submit-order-button" disabled={loading}>
        {loading ? '提交中...' : '确认并支付'}
      </button>
    </div>
  );
};

export default OrderConfirmationPage;
