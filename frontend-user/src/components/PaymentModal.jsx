import React, { useState } from 'react';
import { Modal, Radio, Button, message } from 'antd';
import { submitPayment } from '../api';

const PaymentModal = ({ visible, order, onCancel, onPaymentSuccess }) => {
  const [payMethod, setPayMethod] = useState(1); // 默认微信支付
  const [loading, setLoading] = useState(false);

  const handlePay = async () => {
    if (!order) return;
    setLoading(true);
    const paymentData = {
      order_number: order.order_number || order.number, // Handle both cases
      pay_method: payMethod
    };
    console.log('Submitting payment with data:', paymentData); // Log the data
    try {
      await submitPayment(paymentData);
      message.success('支付成功！');
      onPaymentSuccess();
    } catch (error) {
      message.error('支付失败，请稍后重试');
      console.error('Payment failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      title="选择支付方式"
      visible={visible}
      onCancel={onCancel}
      footer={[
        <Button key="back" onClick={onCancel}>
          取消
        </Button>,
        <Button key="submit" type="primary" loading={loading} onClick={handlePay}>
          确认支付
        </Button>,
      ]}
    >
      <p>订单号: {order?.order_number || order?.number}</p>
      <p>支付金额: <span style={{ color: 'red', fontSize: '18px' }}>¥{order?.amount.toFixed(2)}</span></p>
      <Radio.Group onChange={(e) => setPayMethod(e.target.value)} value={payMethod}>
        <Radio value={1}>微信支付</Radio>
        <Radio value={2}>支付宝</Radio>
      </Radio.Group>
    </Modal>
  );
};

export default PaymentModal;
