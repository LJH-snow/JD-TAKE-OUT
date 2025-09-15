import React, { useState, useEffect, useRef, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import StoreHeader from '../components/StoreHeader';
import ShoppingCartBar from '../components/ShoppingCartBar';
import ShoppingCartDetails from '../components/ShoppingCartDetails';
import FlavorSelectionModal from '../components/FlavorSelectionModal';
import CategoryMenu from '../components/CategoryMenu';
import DishList from '../components/DishList';
import StoreClosedOverlay from '../components/StoreClosedOverlay'; // 引入浮层组件
import { getCategories, getAllDishes, getShoppingCartItems, addShoppingCartItem, updateShoppingCartItem, removeShoppingCartItem, clearShoppingCart } from '../api';
import { useAuth } from '../context/AuthContext';
import { useStore } from '../context/StoreContext';
import { useSmartScroll } from '../hooks/useSmartScroll';
import './StorePage.css';

const StorePage = () => {
  // UI状态
  const [activeCategoryId, setActiveCategoryId] = useState(null);
  const [isCartDetailsVisible, setIsCartDetailsVisible] = useState(false);
  const [isFlavorModalVisible, setIsFlavorModalVisible] = useState(false);
  const [selectedDish, setSelectedDish] = useState(null);

  // 数据状态
  const [categories, setCategories] = useState([]);
  const [menuData, setMenuData] = useState([]);
  const [cartItems, setCartItems] = useState([]);

  // Refs & Hooks
  const dishListRef = useRef(null);
  const isCartBarVisible = useSmartScroll(dishListRef);
  const { isAuthenticated } = useAuth();
  const { isOpen } = useStore();
  const navigate = useNavigate();

  const fetchCartItems = async () => {
    if (!isAuthenticated) {
      setCartItems([]);
      return;
    }
    try {
      const response = await getShoppingCartItems();
      if (response.data && response.data.code === 200) {
        setCartItems(response.data.data || []);
      } else {
        setCartItems([]);
      }
    } catch (error) {
      setCartItems([]);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [categoriesRes, dishesRes] = await Promise.all([getCategories(), getAllDishes()]);
        const fetchedCategories = categoriesRes.data.data || [];
        const allDishes = dishesRes.data?.data?.items || [];
        const validDishes = allDishes.filter(dish => dish && dish.id && typeof dish.price === 'number' && !dish.delete_at);
        const dishesByCategoryId = validDishes.reduce((acc, dish) => {
          const categoryId = dish.category_id;
          if (!acc[categoryId]) acc[categoryId] = [];
          acc[categoryId].push(dish);
          return acc;
        }, {});
        const newMenuData = fetchedCategories
          .map(cat => ({ category: cat, dishes: dishesByCategoryId[cat.id] || [] }))
          .filter(group => group.dishes.length > 0);
        const finalCategories = newMenuData.map(group => group.category);
        setCategories(finalCategories);
        setMenuData(newMenuData);
        if (finalCategories.length > 0) setActiveCategoryId(finalCategories[0].id);
        await fetchCartItems();
      } catch (error) {
        console.error("Failed to fetch initial data:", error);
      }
    };
    fetchData();
  }, [isAuthenticated]);

  const cartQuantityMap = useMemo(() => {
    const map = {};
    cartItems.forEach(item => {
      const key = item.dish_id || item.setmeal_id;
      if (key) {
        map[key] = (map[key] || 0) + item.number;
      }
    });
    return map;
  }, [cartItems]);

  const handleAddToCart = async (dish, selectedFlavorsString = null) => {
    if (!isAuthenticated) {
      if (window.confirm('请先登录再购餐')) {
        navigate('/login');
      }
      return;
    }

    try {
      const payload = {
        dish_id: dish.id,
        number: 1,
        dish_flavor: selectedFlavorsString,
      };
      const response = await addShoppingCartItem(payload);
      if (response.data && response.data.code === 200) {
        await fetchCartItems();
        setIsFlavorModalVisible(false);
      } else {
        alert(response.data.message || "添加购物车失败");
      }
    } catch (error) {
      alert(error.response?.data?.message || "添加购物车失败，请稍后再试");
    }
  };

  const handleUpdateQuantity = async (cartItem, newQuantity) => {
    try {
      if (newQuantity <= 0) {
        const response = await removeShoppingCartItem(cartItem.id);
        if (response.data && response.data.code === 200) {
          await fetchCartItems();
        } else {
          alert(response.data.message || "移除购物车商品失败");
        }
      } else {
        const payload = { id: cartItem.id, number: newQuantity };
        const response = await updateShoppingCartItem(payload);
        if (response.data && response.data.code === 200) {
          await fetchCartItems();
        } else {
          alert(response.data.message || "更新购物车商品数量失败");
        }
      }
    } catch (error) {
      alert(error.response?.data?.message || "更新购物车失败，请稍后再试");
    }
  };

  const handleDecrementFromList = async (dishId) => {
    const variantsInCart = cartItems.filter(item => item.dish_id === dishId || item.setmeal_id === dishId);
    const uniqueFlavors = new Set(variantsInCart.map(item => item.dish_flavor || ''));
    const uniqueVariantsCount = uniqueFlavors.size;

    if (uniqueVariantsCount > 1) {
      alert('不同口味的菜品需在购物车删除');
      setIsCartDetailsVisible(true);
    } else if (uniqueVariantsCount === 1) {
      const singleVariant = variantsInCart[0];
      if (singleVariant) {
        await handleUpdateQuantity(singleVariant, singleVariant.number - 1);
      }
    }
  };

  const handleClearCart = async () => {
    try {
      const response = await clearShoppingCart();
      if (response.data && response.data.code === 200) {
        await fetchCartItems();
        setIsCartDetailsVisible(false);
      } else {
        alert(response.data.message || "清空购物车失败");
      }
    } catch (error) {
      alert(error.response?.data?.message || "清空购物车失败，请稍后再试");
    }
  };

  const handleOpenFlavorModal = (dish) => {
    if (!isAuthenticated) {
      if (window.confirm('请先登录再购餐')) {
        navigate('/login');
      }
      return;
    }
    setSelectedDish(dish);
    setIsFlavorModalVisible(true);
  };

  const handleCategoryClick = (categoryId) => {
    setActiveCategoryId(categoryId);
    const targetElement = document.getElementById(`category-${categoryId}`);
    if (targetElement) targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  useEffect(() => {
    if (!dishListRef.current) return;
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setActiveCategoryId(parseInt(entry.target.dataset.categoryId, 10));
          }
        });
      },
      { root: dishListRef.current, threshold: 0.5 }
    );
    menuData.forEach(group => {
      const element = document.getElementById(`category-${group.category.id}`);
      if (element) observer.observe(element);
    });
    return () => observer.disconnect();
  }, [menuData]);

  return (
    <div className="store-page-container">
      <StoreHeader />
      
      <main className="store-main-content">
        <CategoryMenu 
          categories={categories} 
          activeCategoryId={activeCategoryId}
          onCategoryClick={handleCategoryClick}
        />
        <DishList 
          ref={dishListRef} 
          menuData={menuData} 
          cartQuantityMap={cartQuantityMap}
          onAddToCart={handleAddToCart}
          onDecrement={handleDecrementFromList}
          onSelectFlavor={handleOpenFlavorModal}
          isStoreOpen={isOpen}
        />
      </main>

      <ShoppingCartBar 
        isVisible={isCartBarVisible} 
        cartItems={cartItems}
        onShowDetails={() => setIsCartDetailsVisible(true)} 
        isStoreOpen={isOpen}
      />
      <ShoppingCartDetails 
        isVisible={isCartDetailsVisible} 
        cartItems={cartItems}
        onClose={() => setIsCartDetailsVisible(false)} 
        onUpdateQuantity={handleUpdateQuantity}
        onClearCart={handleClearCart}
      />
      <FlavorSelectionModal
        isVisible={isFlavorModalVisible}
        dish={selectedDish}
        onClose={() => setIsFlavorModalVisible(false)}
        onAddToCart={handleAddToCart}
      />
      <StoreClosedOverlay /> {/* 将浮层组件放在这里 */}
    </div>
  );
};

export default StorePage;
