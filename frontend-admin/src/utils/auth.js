// JWT token 解析工具
export const parseJWTToken = (token) => {
  try {
    if (!token) return null;
    
    // JWT token 格式: header.payload.signature
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    
    // 解析 payload (base64 编码)
    const payload = parts[1];
    const decodedPayload = atob(payload);
    const claims = JSON.parse(decodedPayload);
    
    return claims;
  } catch (error) {
    console.error('Failed to parse JWT token:', error);
    return null;
  }
};

// 根据用户角色获取正确的API端点
export const getApiEndpoint = (basePath, role = null) => {
  // 如果没有提供角色，尝试从token中获取
  if (!role) {
    const token = localStorage.getItem('jwt_token');
    const claims = parseJWTToken(token);
    role = claims?.role;
  }
  
  // 根据角色决定使用admin还是employee端点
  if (role === 'admin') {
    return `/admin${basePath}`;
  } else {
    return `/employee${basePath}`;
  }
};

// 获取用户信息的端点
export const getUserInfoEndpoint = (role = null) => {
  return getApiEndpoint('/me', role);
};