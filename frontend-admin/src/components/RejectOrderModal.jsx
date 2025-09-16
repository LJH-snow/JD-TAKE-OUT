import React, { useState } from 'react';
import { Modal, Input } from 'antd';

const RejectOrderModal = ({ visible, onCancel, onConfirm }) => {
  const [reason, setReason] = useState('');

  const handleOk = () => {
    if (!reason) {
      alert('请输入拒单原因');
      return;
    }
    onConfirm(reason);
  };

  return (
    <Modal
      title="拒单原因"
      visible={visible}
      onCancel={onCancel}
      onOk={handleOk}
      okText="确认拒单"
      cancelText="取消"
    >
      <Input.TextArea
        rows={4}
        value={reason}
        onChange={(e) => setReason(e.target.value)}
        placeholder="请输入拒单原因"
      />
    </Modal>
  );
};

export default RejectOrderModal;
