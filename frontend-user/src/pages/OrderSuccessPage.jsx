import React from 'react';
import { useLocation, Link } from 'react-router-dom';

const OrderSuccessPage = () => {
  const location = useLocation();
  const orderId = location.state?.orderId;

  return (
    <div style={{ padding: '16px' }}>
      <h1>下单成功</h1>
      <p>您的订单已提交成功！</p>
      {orderId ? (
        <p>
          订单编号：<strong>{orderId}</strong>
        </p>
      ) : (
        <p>未获取到订单编号。</p>
      )}
      <div style={{ marginTop: '16px' }}>
        {orderId && (
          <Link className="button" to={`/orders/${orderId}`}>查看订单详情</Link>
        )}
        <span style={{ marginLeft: '12px' }} />
        <Link className="button" to="/orders">返回我的订单</Link>
      </div>
    </div>
  );
};

export default OrderSuccessPage;


