import React, { createContext, useContext, useReducer, useMemo } from 'react';

// 1. 创建 Context
const CartContext = createContext();

// 2. 定义 Reducer 来处理购物车逻辑
const cartReducer = (state, action) => {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      let updatedItems;
      if (existingItem) {
        updatedItems = state.items.map(item =>
          item.id === action.payload.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      } else {
        updatedItems = [...state.items, { ...action.payload, quantity: 1 }];
      }
      return { ...state, items: updatedItems };
    }
    case 'REMOVE_ITEM': {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      let updatedItems;
      if (existingItem.quantity === 1) {
        updatedItems = state.items.filter(item => item.id !== action.payload.id);
      } else {
        updatedItems = state.items.map(item =>
          item.id === action.payload.id ? { ...item, quantity: item.quantity - 1 } : item
        );
      }
      return { ...state, items: updatedItems };
    }
    case 'CLEAR_ITEM': {
        return {
            ...state,
            items: state.items.filter(item => item.id !== action.payload.id),
        };
    }
    case 'CLEAR_CART':
      return { ...state, items: [] };
    default:
      return state;
  }
};

// 3. 创建 Provider 组件
export const CartProvider = ({ children }) => {
  const [state, dispatch] = useReducer(cartReducer, { items: [] });

  const addItem = item => dispatch({ type: 'ADD_ITEM', payload: item });
  const removeItem = item => dispatch({ type: 'REMOVE_ITEM', payload: item });
  const clearItem = item => dispatch({ type: 'CLEAR_ITEM', payload: item });
  const clearCart = () => dispatch({ type: 'CLEAR_CART' });

  // 使用 useMemo 优化性能，避免不必要的重计算
  const cartValue = useMemo(() => {
    const totalItems = state.items.reduce((sum, item) => sum + item.quantity, 0);
    const totalPrice = state.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return {
      ...state,
      addItem,
      removeItem,
      clearItem,
      clearCart,
      totalItems,
      totalPrice,
    };
  }, [state]);

  return (
    <CartContext.Provider value={cartValue}>
      {children}
    </CartContext.Provider>
  );
};

// 4. 创建自定义 Hook，方便在组件中使用
export const useCart = () => {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
};
