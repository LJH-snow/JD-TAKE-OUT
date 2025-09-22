import React, { useState, useEffect, useMemo } from 'react';
import { Form, Input, Button, Space, message, Switch, Image, Upload } from 'antd';
import { PlusOutlined } from '@ant-design/icons'; // Import PlusOutlined for the upload button
import apiClient from '../api'; // Import apiClient to get the token

const StoreSettingsForm = ({ initialValues, onFormSubmit, onCancel }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  const transformedInitialValues = useMemo(() => {
    if (initialValues && initialValues.logo) { // Only process if initialValues and logo exist
      const imageUrl = initialValues.logo.startsWith('http') ? initialValues.logo : `http://localhost:8090${initialValues.logo}`;
      const fileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
      return {
        ...initialValues,
        logo: [{
          uid: imageUrl, // Use URL as uid for uniqueness
          name: fileName,
          status: 'done',
          url: imageUrl
        }],
        is_open: initialValues.is_open === undefined ? true : initialValues.is_open,
      };
    }
    // Always return an object with logo as an empty array if no valid initial logo
    return { ...initialValues, is_open: true, logo: [] };
  }, [initialValues]);

  useEffect(() => {
    if (!initialValues) { // Only reset if it's a new form
      form.resetFields();
      form.setFieldsValue({ is_open: true, logo: [] }); // Default to open and empty logo
    }
  }, [initialValues, form]);

  const handleSubmit = async (values) => {
    setLoading(true);
    try {
      // Extract the logo URL from the fileList if it's an Upload component's value
      const logoUrl = Array.isArray(values.logo) && values.logo.length > 0 && values.logo[0].response && values.logo[0].response.code === 200
        ? values.logo[0].response.data.url
        : (typeof values.logo === 'string' ? values.logo : ''); // Fallback for existing string URL

      await onFormSubmit({ ...values, logo: logoUrl });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={transformedInitialValues}>
      <Form.Item
        name="name"
        label="店铺名称"
        rules={[{ required: true, message: '请输入店铺名称' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="address"
        label="店铺地址"
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="phone"
        label="联系电话"
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="description"
        label="店铺描述"
      >
        <Input.TextArea rows={3} />
      </Form.Item>
      <Form.Item
        name="logo"
        label="Logo图片"
        valuePropName="fileList"
        getValueFromEvent={(e) => {
          if (Array.isArray(e)) {
            return e;
          }
          return e && e.fileList;
        }}
        rules={[{ required: true, message: '请上传店铺Logo!' }]}
      >
        <Upload
          name="file"
          action="http://localhost:8090/api/v1/upload?type=logo" // Backend upload endpoint
          listType="picture-card"
          maxCount={1}
          showUploadList={{ showPreviewIcon: true, showRemoveIcon: true }} // Explicitly show preview and remove icons
          headers={{
            Authorization: `Bearer ${localStorage.getItem('jwt_token')}`, // Include JWT token
          }}
          beforeUpload={(file) => {
            const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/gif' || file.type === 'image/webp';
            if (!isJpgOrPng) {
              message.error('只能上传 JPG/PNG/GIF/WEBP 格式的图片!');
            }
            const isLt5M = file.size / 1024 / 1024 < 5;
            if (!isLt5M) {
              message.error('图片大小不能超过 5MB!');
            }
            return isJpgOrPng && isLt5M;
          }}
          onChange={({ fileList }) => {
            // Always update the form field with the fileList array
            form.setFieldsValue({ logo: fileList });
          }}
          onRemove={() => {
            form.setFieldsValue({ logo: [] }); // Clear logo on remove
            return true;
          }}
          fileList={initialValues?.logo ? [{
            uid: initialValues.logo, // Use URL as uid for uniqueness
            name: initialValues.logo.substring(initialValues.logo.lastIndexOf('/') + 1),
            status: 'done',
            url: initialValues.logo // Use the relative path directly
          }] : []}
        >
          <div>
            <PlusOutlined />
            <div style={{ marginTop: 8 }}>上传</div>
          </div>
        </Upload>
      </Form.Item>
      {/* Remove the separate Image preview as Upload component handles it */}
      {/* <Form.Item label="当前Logo预览">
            <Image
              src={initialValues?.logo || 'https://via.placeholder.com/100?text=No+Logo'}
              width={100}
              alt="店铺Logo"
            />
          </Form.Item> */}
      <Form.Item
        name="is_open"
        label="店铺营业状态"
        valuePropName="checked"
      >
        <Switch checkedChildren="营业中" unCheckedChildren="已打烊" />
      </Form.Item>
      <Form.Item style={{ textAlign: 'right' }}>
        <Space>
          <Button onClick={onCancel} disabled={loading}>取消</Button>
          <Button type="primary" htmlType="submit" loading={loading}>保存设置</Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

export default StoreSettingsForm;