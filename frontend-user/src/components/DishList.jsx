import React, { useState, useEffect, useRef } from 'react';
import {
  SideBar,
  List,
  Image,
  Button,
  Toast,
  SpinLoading,
  Popup,
  Space,
  Tag,
} from 'antd-mobile';
import { fetchMenu } from '../api';
import useStore from '../store';
import './DishList.css';

const DishList = () => {
  const [menuData, setMenuData] = useState([]);
  const [activeCategoryKey, setActiveCategoryKey] = useState('');
  const [isLoading, setIsLoading] = useState(true); // Correct, single declaration
  const [isAtBottom, setIsAtBottom] = useState(false); // State for bottom detection

  // Refs for scrolling
  const rightScrollRef = useRef(null);
  const categoryTitleRefs = useRef(new Map());
  const isClickScrolling = useRef(false); // Flag for programmatic scroll
  const scrollTimeoutRef = useRef(null); // Timeout for resetting isClickScrolling
  const ignoreObserverRef = useRef(false); // Flag to control IntersectionObserver updates

  // Popup and Store logic
  const [popupVisible, setPopupVisible] = useState(false);
  const [selectedDish, setSelectedDish] = useState(null);
  const [selectedFlavors, setSelectedFlavors] = useState({});
  const cart = useStore((state) => state.cart);
  const addToCart = useStore((state) => state.addToCart);

  // Fetch all menu data on component mount
  useEffect(() => {
    const loadMenu = async () => {
      try {
        const res = await fetchMenu();
        const data = res.data?.data || [];
        setMenuData(data);
        if (data.length > 0) {
          setActiveCategoryKey(String(data[0].id));
        }
      } catch (error) {
        Toast.show({ icon: 'fail', content: '菜单加载失败' });
      } finally {
        setIsLoading(false);
      }
    };
    loadMenu();
  }, []);

  // Set up IntersectionObserver to sync scroll from right to left
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        // Only update if not programmatically scrolling and not at the very bottom
        if (isClickScrolling.current || ignoreObserverRef.current) return;

        const intersectingEntries = entries.filter(e => e.isIntersecting);
        if (intersectingEntries.length > 0) {
          // Find the topmost visible element among all intersecting ones
          const topmostEntry = intersectingEntries.reduce((prev, curr) => {
            return prev.boundingClientRect.top < curr.boundingClientRect.top ? prev : curr;
          });
          setActiveCategoryKey(topmostEntry.target.dataset.key);
        }
      },
      {
        root: rightScrollRef.current, // Our scrollable container
        rootMargin: '0px 0px -85% 0px', // Trigger when an element is at the top 15% of the viewport
      }
    );

    // Observe all category title elements
    categoryTitleRefs.current.forEach(ref => {
      if (ref) observer.observe(ref);
    });

    // Cleanup observer on unmount
    return () => {
      categoryTitleRefs.current.forEach(ref => {
        if (ref) observer.unobserve(ref);
      });
    };
  }, [menuData]); // Re-run when the list is rendered

  // Handle click on the left sidebar to scroll the right side
  const handleSideBarChange = (key) => {
    isClickScrolling.current = true; // Set flag to ignore observer during programmatic scroll
    ignoreObserverRef.current = true; // Also ignore observer for a short period
    setActiveCategoryKey(key);
    const targetRef = categoryTitleRefs.current.get(key);
    if (targetRef) {
      targetRef.scrollIntoView({ behavior: 'smooth' });
      // Reset the flags after scroll animation finishes
      clearTimeout(scrollTimeoutRef.current);
      scrollTimeoutRef.current = setTimeout(() => {
        isClickScrolling.current = false;
        ignoreObserverRef.current = false;
      }, 800); // 800ms should be enough for smooth scroll to finish
    }
  };

  // Handle scroll event for right-to-left sync and bottom detection
  const handleScroll = (event) => {
    if (isClickScrolling.current) return;

    const { scrollTop, scrollHeight, clientHeight } = event.currentTarget;
    const atBottom = (scrollHeight - scrollTop - clientHeight < 1); // Check if scrolled to bottom

    setIsAtBottom(atBottom); // Update state for isAtBottom

    if (atBottom) {
      // If at bottom, force the last category to be active and temporarily ignore observer
      ignoreObserverRef.current = true;
      if (menuData.length > 0) {
        const lastCategory = menuData[menuData.length - 1];
        setActiveCategoryKey(String(lastCategory.id));
      }
    } else {
      // If not at bottom, allow observer to work (unless programmatic scroll is active)s
      ignoreObserverRef.current = false;
    }
  };

  // --- Flavor Popup and Cart Logic ---
  const handleSelectFlavorClick = (dish) => {
    setSelectedDish(dish);
    setSelectedFlavors({}); // Reset previous selections
    setPopupVisible(true);
  };

  const handleFlavorSelect = (flavorName, value) => {
    setSelectedFlavors((prev) => ({ ...prev, [flavorName]: value }));
  };

  const handleAddToCartWithFlavors = () => {
    if (!selectedDish) return;
    addToCart(selectedDish, selectedFlavors);
    setPopupVisible(false);
    Toast.show({ icon: 'success', content: '已加入购物车', duration: 2000 });
  };

  const getCartItemQuantity = (dishId) => {
    return cart.filter(i => i.id === dishId).reduce((sum, item) => sum + item.quantity, 0);
  };

  // --- Render Methods ---
  const renderDishItemExtra = (dish) => {
    const totalQuantity = getCartItemQuantity(dish.id);
    return (
      <div className="dish-item-extra">
        {totalQuantity > 0 && <div className="quantity-badge">{totalQuantity}</div>}
        <Button color="primary" size="small" onClick={() => handleSelectFlavorClick(dish)}>
          选规格
        </Button>
      </div>
    );
  };

  const renderFlavorPopup = () => {
    if (!selectedDish) return null;
    return (
      <Popup
        visible={popupVisible}
        onMaskClick={() => setPopupVisible(false)}
        bodyStyle={{ borderTopLeftRadius: '8px', borderTopRightRadius: '8px' }}
      >
        <div className="flavor-popup-content">
          <div className="flavor-dish-name">{selectedDish.name}</div>
          {selectedDish.flavors.map((flavor) => (
            <div key={flavor.name} className="flavor-group">
              <div className="flavor-group-name">{flavor.name}</div>
              <Space wrap>
                {JSON.parse(flavor.value).map((val) => (
                  <Tag
                    key={val}
                    round
                    color={selectedFlavors[flavor.name] === val ? 'primary' : 'default'}
                    onClick={() => handleFlavorSelect(flavor.name, val)}
                  >
                    {val}
                  </Tag>
                ))}
              </Space>
            </div>
          ))}
          <Button
            block
            color="primary"
            size="large"
            className="add-to-cart-btn"
            onClick={handleAddToCartWithFlavors}
          >
            加入购物车 ¥{selectedDish.price.toFixed(2)}
          </Button>
        </div>
      </Popup>
    );
  };

  return (
    <div className="dish-list-layout">
      <div className="sidebar-container">
        <SideBar activeKey={activeCategoryKey} onChange={handleSideBarChange}>
          {menuData.map((cat) => (
            <SideBar.Item key={String(cat.id)} title={cat.name} />
          ))}
        </SideBar>
      </div>
      <div className="content-container" ref={rightScrollRef} onScroll={handleScroll}>
        {isLoading ? (
          <div className="loading-spinner"><SpinLoading style={{ '--size': '48px' }} /></div>
        ) : (
          menuData.map(category => (
            <div
              key={category.id}
              ref={el => categoryTitleRefs.current.set(String(category.id), el)}
              data-key={String(category.id)}
              className="category-section"
            >
              <div className="dish-list-header">{category.name}</div>
              <List>
                {category.dishes.map(dish => (
                  <List.Item
                    key={dish.id}
                    prefix={<Image src={dish.image} width={80} height={80} fit="cover" style={{ borderRadius: 4 }} />}
                    description={dish.description}
                    extra={renderDishItemExtra(dish)}
                  >
                    <div className="dish-name">{dish.name}</div>
                    <div className="dish-price">¥{dish.price.toFixed(2)}</div>
                  </List.Item>
                ))}
              </List>
            </div>
          ))
        )}
      </div>
      {renderFlavorPopup()}
    </div>
  );
};

export default DishList;