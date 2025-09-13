import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getAddressBookByID, addAddressBook, updateAddressBook } from '../api';
import './AddressEditPage.css';

const AddressEditPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditing = !!id;

  const [formData, setFormData] = useState({
    consignee: '',
    phone: '',
    sex: '1',
    detail: '',
    label: '',
    is_default: 0,
    province_name: '',
    city_name: '',
    district_name: '',
    longitude: null,
    latitude: null,
    formatted_address: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [map, setMap] = useState(null);
  const [marker, setMarker] = useState(null);
  const mapContainer = React.useRef(null);

  useEffect(() => {
    let mapInstance, markerInstance, geocoder;

    const initialize = () => {
      if (window.AMap && mapContainer.current) {
        mapInstance = new window.AMap.Map(mapContainer.current, {
          zoom: 15,
          center: [116.397428, 39.90923], // Default to Beijing
        });
        setMap(mapInstance);

        markerInstance = new window.AMap.Marker({
          position: mapInstance.getCenter(),
        });
        mapInstance.add(markerInstance);
        setMarker(markerInstance);

        window.AMap.plugin(['AMap.Geolocation', 'AMap.PlaceSearch', 'AMap.Geocoder'], () => {
          geocoder = new window.AMap.Geocoder();

          const geolocation = new window.AMap.Geolocation({
            enableHighAccuracy: true,
            timeout: 10000,
            buttonPosition: 'RB',
            buttonOffset: new window.AMap.Pixel(10, 20),
            zoomToAccuracy: true, 
          });
          mapInstance.addControl(geolocation);

          const placeSearch = new window.AMap.PlaceSearch({
            map: mapInstance,
            panel: 'search-result-panel',
            autoFitView: true,
          });

          const updateAddress = (lnglat, formattedAddress, addressComponent) => {
            setFormData(prev => ({
              ...prev,
              longitude: lnglat.lng,
              latitude: lnglat.lat,
              province_name: addressComponent.province,
              city_name: addressComponent.city,
              district_name: addressComponent.district,
              formatted_address: formattedAddress,
            }));
          };

          const geocodePosition = (lnglat) => {
            markerInstance.setPosition(lnglat);
            mapInstance.setCenter(lnglat);
            geocoder.getAddress(lnglat, (status, result) => {
              if (status === 'complete' && result.info === 'OK') {
                updateAddress(lnglat, result.regeocode.formattedAddress, result.regeocode.addressComponent);
              }
            });
          };

          if (isEditing) {
            const fetchAddress = async () => {
              try {
                setLoading(true);
                const response = await getAddressBookByID(id);
                if (response.data && response.data.code === 200) {
                  const address = response.data.data;
                  setFormData(address);
                  geocodePosition([address.longitude, address.latitude]);
                } else {
                  setError(response.data.message || '获取地址信息失败');
                }
              } catch (err) {
                setError(err.response?.data?.message || '加载数据失败');
              } finally {
                setLoading(false);
              }
            };
            fetchAddress();
          } else {
            geolocation.getCurrentPosition((status, result) => {
              if (status === 'complete' && result.info === 'OK') {
                geocodePosition(result.position);
              }
            });
          }

          placeSearch.on('select', (e) => {
            geocodePosition(e.poi.location);
          });

          const searchInput = document.getElementById('search-input');
          searchInput.addEventListener('input', () => {
            placeSearch.search(searchInput.value);
          });

          mapInstance.on('click', (e) => {
            geocodePosition(e.lnglat);
          });
        });
      } else {
        setTimeout(initialize, 100);
      }
    };

    initialize();

    return () => {
      if (mapInstance) {
        mapInstance.destroy();
      }
    };
  }, [id, isEditing]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (checked ? 1 : 0) : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      let response;
      if (isEditing) {
        response = await updateAddressBook(id, formData);
      } else {
        response = await addAddressBook(formData);
      }

      if (response.data && response.data.code === 200) {
        alert(isEditing ? '更新成功' : '添加成功');
        navigate('/addresses');
      } else {
        setError(response.data.message || '操作失败');
      }
    } catch (err) {
      setError(err.response?.data?.message || '请求失败，请稍后再试');
    } finally {
      setLoading(false);
    }
  };

  if (loading && isEditing) {
    return <div className="address-edit-page">加载中...</div>;
  }

  return (
    <div className="address-edit-page">
      <h1>{isEditing ? '编辑地址' : '新增地址'}</h1>
      <form onSubmit={handleSubmit} className="address-form">
        <div className="form-group">
          <label>联系人</label>
          <input type="text" name="consignee" value={formData.consignee} onChange={handleChange} placeholder="姓名" required />
          <div className="sex-group">
            <label><input type="radio" name="sex" value="1" checked={formData.sex === '1'} onChange={handleChange} /> 先生</label>
            <label><input type="radio" name="sex" value="0" checked={formData.sex === '0'} onChange={handleChange} /> 女士</label>
          </div>
        </div>
        <div className="form-group">
          <label>手机号</label>
          <input type="tel" name="phone" value={formData.phone} onChange={handleChange} placeholder="手机号码" required />
        </div>
        <div className="form-group">
          <label>地址</label>
          <div className="search-container">
            <input type="text" id="search-input" placeholder="输入关键字搜索地址" />
            <div id="search-result-panel"></div>
          </div>
          <div ref={mapContainer} className="map-container"></div>
          <input type="text" name="formatted_address" value={formData.formatted_address} onChange={handleChange} placeholder="点击地图选择或手动输入地址" required />
        </div>
        <div className="form-group">
          <label>门牌号</label>
          <input type="text" name="detail" value={formData.detail} onChange={handleChange} placeholder="详细地址，例：1层101室" required />
        </div>
        <div className="form-group">
          <label>标签</label>
          <input type="text" name="label" value={formData.label} onChange={handleChange} placeholder="家/公司/学校" />
        </div>
        <div className="form-group checkbox-group">
          <label>
            <input type="checkbox" name="is_default" checked={formData.is_default === 1} onChange={handleChange} />
            设为默认地址
          </label>
        </div>
        
        {error && <p className="error-message">{error}</p>}

        <button type="submit" className="save-btn" disabled={loading}>
          {loading ? '保存中...' : '保存'}
        </button>
      </form>
    </div>
  );
};

export default AddressEditPage;
