
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: 'http://localhost:8090/api/v1',
  timeout: 10000,
});

apiClient.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// 响应拦截器
apiClient.interceptors.response.use(
  response => {
    // 如果响应成功，直接返回
    return response;
  },
  error => {
    // 对于所有错误，正常抛出，由调用方处理
    return Promise.reject(error);
  }
);

// --- API 函数定义 ---

/**
 * 用户登录
 * @param {{phone, password}} credentials 
 */
export const loginUser = (credentials) => {
  // **关键修复：使用正确的 /auth/login 路由**
  return apiClient.post('/auth/login', credentials);
};

/**
 * 用户注册
 * @param {{name, phone, password, sex}} userData
 */
export const registerUser = (userData) => {
  // **关键修复：使用正确的 /auth/register 路由**
  return apiClient.post('/auth/register', userData);
};

export const getCategories = () => {
  return apiClient.get('/categories');
};

export const getAllDishes = () => {
  return apiClient.get('/dishes');
};

export const getDishesByCategoryId = (categoryId) => {
  return apiClient.get(`/dishes?category_id=${categoryId}`);
};

/**
 * 获取用户购物车内容
 */
export const getShoppingCartItems = () => {
  return apiClient.get('/user/shoppingCart');
};

/**
 * 获取用户地址簿列表
 */
export const getAddressBooks = () => {
  return apiClient.get('/user/addressBook');
};

/**
 * 删除地址
 * @param {number} id
 */
export const deleteAddressBook = (id) => {
  return apiClient.delete(`/user/addressBook/${id}`);
};

/**
 * 设置默认地址
 * @param {number} id
 */
export const setDefaultAddressBook = (id) => {
  return apiClient.put(`/user/addressBook/default/${id}`);
};

/**
 * 获取单个地址
 * @param {number} id
 */
export const getAddressBookByID = (id) => {
  return apiClient.get(`/user/addressBook/${id}`);
};

/**
 * 添加地址
 * @param {object} addressData
 */
export const addAddressBook = (addressData) => {
  return apiClient.post('/user/addressBook', addressData);
};

/**
 * 更新地址
 * @param {number} id
 * @param {object} addressData
 */
export const updateAddressBook = (id, addressData) => {
  return apiClient.put(`/user/addressBook/${id}`, addressData);
};

/**
 * 提交订单
 * @param {{address_book_id, pay_method, remark, tableware_number}} orderData
 */
export const submitOrder = (orderData) => {
  return apiClient.post('/user/orders', orderData);
};

/**
 * 添加商品到购物车
 * @param {{dish_id, setmeal_id, dish_flavor, number}} itemData
 */
export const addShoppingCartItem = (itemData) => {
  return apiClient.post('/user/shoppingCart', itemData);
};

/**
 * 更新购物车商品数量
 * @param {{id, number}} itemData
 */
export const updateShoppingCartItem = (itemData) => {
  return apiClient.put('/user/shoppingCart', itemData);
};

/**
 * 从购物车移除商品
 * @param {number} id
 */
export const removeShoppingCartItem = (id) => {
  return apiClient.delete(`/user/shoppingCart/${id}`);
};

/**
 * 清空购物车
 */
export const clearShoppingCart = () => {
  return apiClient.delete('/user/shoppingCart/clear');
};

/**
 * 获取当前用户信息
 */
export const getMe = () => {
  return apiClient.get('/user/me');
};

/**
 * 获取用户订单列表
 * @param {{page, pageSize, status, number, date_from, date_to}} params
 */
export const listUserOrders = (params) => {
  return apiClient.get('/user/orders', { params });
};

/**
 * 获取单个订单详情
 * @param {string} id
 */
export const getOrderDetail = (id) => {
  return apiClient.get(`/user/orders/${id}`);
};

/**
 * 取消订单
 * @param {string} id
 */
export const cancelOrder = (id) => {
  return apiClient.post(`/user/orders/${id}/cancel`);
};

/**
 * 确认收货
 * @param {string} id
 */
export const confirmOrder = (id) => {
  return apiClient.post(`/user/orders/${id}/confirm`);
};

/**
 * 更新当前用户信息
 * @param {{name, sex}} userData 
 */
export const updateUserProfile = (userData) => {
  return apiClient.put('/user/profile', userData);
};

/**
 * 上传头像文件
 * @param {File} file 
 */
export const uploadAvatar = (file) => {
  const formData = new FormData();
  formData.append('file', file);

  return apiClient.post('/upload?type=avatar', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};
