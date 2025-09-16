import React, { useState } from 'react';
import { Modal, Radio, Input, Button } from 'antd';

const CancelOrderModal = ({ visible, onCancel, onConfirm }) => {
  const [reason, setReason] = useState('');
  const [customReason, setCustomReason] = useState('');

  const reasons = [
    '不想买了',
    '信息填写错误，重新下单',
    '商家缺货',
    '其他原因',
  ];

  const handleOk = () => {
    const finalReason = reason === '其他原因' ? customReason : reason;
    if (!finalReason) {
      alert('请选择或输入取消原因');
      return;
    }
    onConfirm(finalReason);
  };

  return (
    <Modal
      title="取消订单"
      visible={visible}
      onCancel={onCancel}
      onOk={handleOk}
      okText="确认取消"
      cancelText="暂不取消"
    >
      <p>请选择取消订单的原因：</p>
      <Radio.Group onChange={(e) => setReason(e.target.value)} value={reason}>
        {reasons.map(r => <Radio key={r} value={r}>{r}</Radio>)}
      </Radio.Group>
      {reason === '其他原因' && (
        <Input.TextArea
          rows={3}
          value={customReason}
          onChange={(e) => setCustomReason(e.target.value)}
          placeholder="请输入具体原因"
          style={{ marginTop: 16 }}
        />
      )}
    </Modal>
  );
};

export default CancelOrderModal;
