import React from 'react';
import { NavBar, List, Image, Stepper, Button, Toast, Dialog, Space } from 'antd-mobile';
import { DeleteOutline } from 'antd-mobile-icons';
import useStore from '../store';
import { useNavigate } from 'react-router-dom';
import './CartPage.css';

const CartPage = () => {
  const navigate = useNavigate();
  // Correct useStore usage
  const cart = useStore((state) => state.cart);
  const updateQuantity = useStore((state) => state.updateQuantity);
  const removeFromCart = useStore((state) => state.removeFromCart);
  const clearCart = useStore((state) => state.clearCart);

  const totalAmount = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const handleQuantityChange = (cartItemId, quantity) => {
    if (quantity === 0) {
      Dialog.confirm({
        content: '确定要从购物车中移除此商品吗？',
        onConfirm: async () => {
          try { // Added try-catch
            removeFromCart(cartItemId);
            Toast.show({ icon: 'success', content: '商品已移除' });
          } catch (error) {
            console.error("Error removing item:", error);
            Toast.show({ icon: 'fail', content: '移除失败' });
          }
        },
      });
    } else {
      updateQuantity(cartItemId, quantity);
    }
  };

  const handleClearCart = () => {
    Dialog.confirm({
      content: '确定要清空购物车吗？',
      onConfirm: async () => {
        try { // Added try-catch
          clearCart();
          Toast.show({ icon: 'success', content: '购物车已清空' });
          navigate('/'); // Navigate back to home after clearing
        } catch (error) {
          console.error("Error clearing cart:", error);
          Toast.show({ icon: 'fail', content: '清空失败' });
        }
      },
    });
  };

  const handleCheckout = () => {
    if (cart.length === 0) {
      Toast.show({ icon: 'fail', content: '购物车为空，无法结算' });
      return;
    }
    navigate('/checkout');
  };

  return (
    <div className="cart-page-container">
      <NavBar onBack={() => navigate(-1)}>购物车</NavBar>

      {cart.length === 0 ? (
        <div className="empty-cart-message">
          <p>购物车是空的，快去点餐吧！</p>
          <Button color="primary" onClick={() => navigate('/')}>去点餐</Button>
        </div>
      ) : (
        <div className="cart-content">
          <div className="cart-header">
            <h3>我的购物车 ({cart.length}件商品)</h3>
            <Button size="small" onClick={handleClearCart}><DeleteOutline /> 清空购物车</Button>
          </div>
          <List className="cart-item-list">
            {cart.map((item) => (
              <List.Item
                key={item.cartItemId || item.id} // Fallback to item.id if cartItemId is problematic
                prefix={<Image src={item.image} width={60} height={60} fit="cover" style={{ borderRadius: 4 }} />}
                description={
                  <>
                    <div className="cart-item-flavors">
                      {/* Corrected: Use || {} to handle undefined/null selectedFlavors */}
                      {Object.keys(item.selectedFlavors || {}).length > 0 &&
                        Object.entries(item.selectedFlavors || {}).map(([key, value]) => (
                          <span key={key}>{value} </span>
                        ))}
                    </div>
                    <div className="cart-item-price">¥{item.price.toFixed(2)}</div>
                  </>
                }
                extra={
                  <Stepper
                    value={item.quantity}
                    onChange={(val) => handleQuantityChange(item.cartItemId, val)}
                    min={0} // Added min={0}
                  />
                }
              >
                <div className="cart-item-name">{item.name}</div>
              </List.Item>
            ))}
          </List>

          
        </div>
      )}
    </div>
  );
};

export default CartPage;
