import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getShoppingCartItems, getAddressBooks, submitOrder } from '../api';
import TablewarePicker from '../components/TablewarePicker';
import PaymentModal from '../components/PaymentModal';
import './OrderConfirmationPage.css';

const mapTablewareNumberToString = (number) => {
  if (number === 0) return '无需餐具';
  if (number === -1) return '商家一句餐量提供';
  if (number > 0 && number <= 10) return `${number}份`;
  if (number > 10) return '10份以上';
  return '需要餐具';
};

const mapStringToTablewareNumber = (str) => {
  if (str === '无需餐具') return 0;
  if (str === '需要餐具,商家依据餐量提供') return -1;
  if (str.includes('份')) {
    const num = parseInt(str, 10);
    if (!isNaN(num)) return num;
  }
  if (str === '10份以上') return 11;
  return -1; // Default
};

const OrderConfirmationPage = () => {
  const navigate = useNavigate();
  const [cartItems, setCartItems] = useState([]);
  const [addresses, setAddresses] = useState([]);
  const [selectedAddressId, setSelectedAddressId] = useState(null);
  const [payMethod, setPayMethod] = useState(1);
  const [remark, setRemark] = useState('');
  const [tableware, setTableware] = useState('需要餐具,商家依据餐量提供');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [totalAmount, setTotalAmount] = useState(0);
  const [isPaymentModalVisible, setPaymentModalVisible] = useState(false);
  const [newOrder, setNewOrder] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError('');

        const cartResponse = await getShoppingCartItems();
        if (cartResponse.data && cartResponse.data.code === 200) {
          setCartItems(cartResponse.data.data);
          const calculatedTotal = cartResponse.data.data.reduce((sum, item) => sum + (item.amount * item.number), 0);
          setTotalAmount(calculatedTotal);
        } else {
          setError(cartResponse.data.message || '获取购物车失败');
          setLoading(false);
          return;
        }

        const addressResponse = await getAddressBooks();
        if (addressResponse.data && addressResponse.data.code === 200) {
          setAddresses(addressResponse.data.data);
          const defaultAddress = addressResponse.data.data.find(addr => addr.is_default === 1);
          if (defaultAddress) {
            setSelectedAddressId(defaultAddress.id);
          } else if (addressResponse.data.data.length > 0) {
            setSelectedAddressId(addressResponse.data.data[0].id);
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
        tableware_number: mapStringToTablewareNumber(tableware),
      };
      const response = await submitOrder(orderData);
      if (response.data && response.data.code === 200) {
        setNewOrder(response.data.data);
        setPaymentModalVisible(true);
      } else {
        setError(response.data.message || '订单提交失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '提交订单失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  const handlePaymentSuccess = () => {
    setPaymentModalVisible(false);
    navigate(`/orders/${newOrder.order_id}`);
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
          <TablewarePicker value={tableware} onChange={setTableware} />
        </div>
      </div>

      <button onClick={handleSubmitOrder} className="submit-order-button" disabled={loading}>
        {loading ? '提交中...' : '提交订单'}
      </button>

      {newOrder && (
        <PaymentModal
          visible={isPaymentModalVisible}
          order={newOrder}
          onCancel={() => setPaymentModalVisible(false)}
          onPaymentSuccess={handlePaymentSuccess}
        />
      )}
    </div>
  );
};

export default OrderConfirmationPage;