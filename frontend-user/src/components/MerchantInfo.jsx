import React, { useState, useEffect } from 'react';
import { Image, Skeleton, Space, Divider } from 'antd-mobile';
import { PhoneFill, LocationOutline, InformationCircleOutline } from 'antd-mobile-icons';
import { fetchStoreSettings } from '../api';
import './MerchantInfo.css';

const MerchantInfo = () => {
  const [settings, setSettings] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadSettings = async () => {
      try {
        setLoading(true);
        const res = await fetchStoreSettings();
        if (res.data && res.data.data) {
          setSettings(res.data.data);
        }
      } catch (error) {
        console.error("Failed to fetch store settings:", error);
      } finally {
        setLoading(false);
      }
    };
    loadSettings();
  }, []);

  if (loading) {
    return (
      <div className="merchant-info-container">
        <Skeleton.Title animated />
        <Skeleton.Paragraph lineCount={3} animated />
      </div>
    );
  }

  if (!settings) {
    return null; // Or show an error message
  }

  return (
    <div className="merchant-info-container">
      <div className="merchant-header">
        <Image src={settings.logo} width={64} height={64} fit="cover" className="merchant-logo" />
        <div className="merchant-header-main">
          <div className="merchant-name">{settings.name || 'JD外卖'}</div>
          <div className="merchant-details">
            <span>配送约1.5km</span>
            <span>|</span>
            <span>配送费 ¥6</span>
            <span>|</span>
            <span>预计12分钟</span>
          </div>
        </div>
        <a href={`tel:${settings.phone}`} className="merchant-phone-icon">
          <PhoneFill fontSize={24} />
        </a>
      </div>
      <Divider />
      <div className="merchant-body">
        <div className="info-line">
          <LocationOutline />
          <span>{settings.address}</span>
        </div>
        <div className="info-line">
          <InformationCircleOutline />
          <span>{settings.description}</span>
        </div>
      </div>
    </div>
  );
};

export default MerchantInfo;
