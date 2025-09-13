import React, { useState, useEffect, useRef, useMemo } from 'react';
import StoreHeader from '../components/StoreHeader';
import ShoppingCartBar from '../components/ShoppingCartBar';
import ShoppingCartDetails from '../components/ShoppingCartDetails';
import FlavorSelectionModal from '../components/FlavorSelectionModal';
import CategoryMenu from '../components/CategoryMenu';
import DishList from '../components/DishList';
import { getCategories, getAllDishes, getShoppingCartItems, addShoppingCartItem, updateShoppingCartItem, removeShoppingCartItem, clearShoppingCart } from '../api'; // Import new API functions
import { useAuth } from '../context/AuthContext';
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
  const [cartItems, setCartItems] = useState([]); // This will now be synced with backend

  // Refs
  const dishListRef = useRef(null);
  const isCartBarVisible = useSmartScroll(dishListRef);
  const { isAuthenticated } = useAuth();

  // Helper to fetch cart items from backend and update state
  const fetchCartItems = async () => {
    try {
      const response = await getShoppingCartItems();
      if (response.data && response.data.code === 200) {
        setCartItems(response.data.data);
      } else {
        console.error("Failed to fetch cart items:", response.data.message);
        setCartItems([]); // Clear cart on error
      }
    } catch (error) {
      console.error("Error fetching cart items:", error);
      setCartItems([]); // Clear cart on error
    }
  };

  // Initial fetch of menu data and cart items
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

        // Fetch initial cart items from backend if authenticated
        if (isAuthenticated) {
          await fetchCartItems();
        } else {
          setCartItems([]); // Clear cart if not authenticated
        }

      } catch (error) {
        console.error("Failed to fetch initial data:", error);
      }
    };
    fetchData();
  }, [isAuthenticated]);


  const cartQuantityMap = useMemo(() => {
    const map = {};
    cartItems.forEach(item => {
      // Use dishId or setmealId as key
      const key = item.dish_id || item.setmeal_id;
      if (key) {
        map[key] = (map[key] || 0) + item.number; // Use item.number from backend
      }
    });
    return map;
  }, [cartItems]);

  // --- 购物车核心操作函数 ---
  const handleAddToCart = async (dish, selectedFlavorsString = null) => {
    try {
      const payload = {
        dish_id: dish.id,
        number: 1, // Always add 1 for now
        dish_flavor: selectedFlavorsString,
      };
      const response = await addShoppingCartItem(payload); // Call backend API
      if (response.data && response.data.code === 200) {
        await fetchCartItems(); // Re-fetch cart items to update local state
        setIsFlavorModalVisible(false);
      } else {
        console.error("Failed to add to cart:", response.data.message);
        alert(response.data.message || "添加购物车失败");
      }
    } catch (error) {
      console.error("Error adding to cart:", error);
      alert(error.response?.data?.message || "添加购物车失败，请稍后再试");
    }
  };

  const handleUpdateQuantity = async (cartItem, newQuantity) => {
    try {
      if (newQuantity <= 0) {
        // If quantity is 0 or less, remove the item
        const response = await removeShoppingCartItem(cartItem.id); // Assuming cartItem has an 'id' from backend
        if (response.data && response.data.code === 200) {
          await fetchCartItems(); // Re-fetch cart items
        } else {
          console.error("Failed to remove from cart:", response.data.message);
          alert(response.data.message || "移除购物车商品失败");
        }
      } else {
        // Update quantity
        const payload = {
          id: cartItem.id,
          number: newQuantity,
        };
        const response = await updateShoppingCartItem(payload);
        if (response.data && response.data.code === 200) {
          await fetchCartItems(); // Re-fetch cart items
        } else {
          console.error("Failed to update cart quantity:", response.data.message);
          alert(response.data.message || "更新购物车商品数量失败");
        }
      }
    } catch (error) {
      console.error("Error updating cart quantity:", error);
      alert(error.response?.data?.message || "更新购物车失败，请稍后再试");
    }
  };

  // **关键修改：实现复杂的减号逻辑**
  const handleDecrementFromList = async (dishId) => {
    // Find all cart items related to this dishId (could be dish_id or setmeal_id)
    const variantsInCart = cartItems.filter(item => item.dish_id === dishId || item.setmeal_id === dishId);

    // Get unique flavors for this dishId
    const uniqueFlavors = new Set(variantsInCart.map(item => item.dish_flavor || '')); // Use dish_flavor, handle null/empty flavor
    const uniqueVariantsCount = uniqueFlavors.size;

    if (uniqueVariantsCount > 1) {
      // If there are multiple unique flavors for this dish, alert and open cart details
      alert('不同口味的菜品需在购物车删除');
      setIsCartDetailsVisible(true);
    } else if (uniqueVariantsCount === 1) {
      // If there's only one unique flavor (or no flavor specified), directly decrement
      // Find the specific item to decrement (there should be only one variant for this dishId/flavor)
      const singleVariant = variantsInCart[0]; // Assuming there's only one if uniqueVariantsCount is 1
      if (singleVariant) {
        await handleUpdateQuantity(singleVariant, singleVariant.number - 1);
      }
    }
    // If uniqueVariantsCount is 0, do nothing (button shouldn't be visible anyway)
  };

  const handleClearCart = async () => {
    try {
      const response = await clearShoppingCart();
      if (response.data && response.data.code === 200) {
        await fetchCartItems(); // Re-fetch to confirm empty cart
        setIsCartDetailsVisible(false);
      } else {
        console.error("Failed to clear cart:", response.data.message);
        alert(response.data.message || "清空购物车失败");
      }
    } catch (error) {
      console.error("Error clearing cart:", error);
      alert(error.response?.data?.message || "清空购物车失败，请稍后再试");
    }
  };

  const handleOpenFlavorModal = (dish) => {
    setSelectedDish(dish);
    setIsFlavorModalVisible(true);
  };

  // --- 数据获取和联动逻辑 (省略) ---
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

        // Fetch initial cart items from backend
        await fetchCartItems();

      } catch (error) {
        console.error("Failed to fetch initial data:", error);
      }
    };
    fetchData();
  }, []);

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
        />
      </main>

      <ShoppingCartBar 
        isVisible={isCartBarVisible} 
        cartItems={cartItems}
        onShowDetails={() => setIsCartDetailsVisible(true)} 
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
    </div>
  );
};

export default StorePage;