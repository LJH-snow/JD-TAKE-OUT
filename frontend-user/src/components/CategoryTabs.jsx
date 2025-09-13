import React, { useState, useEffect } from 'react';
import { getCategories } from '../api';
import { Spin, message } from 'antd';
import './CategoryTabs.css';

const CategoryTabs = ({ onSelectCategory }) => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeKey, setActiveKey] = useState(null);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const data = await getCategories();
        // 假设返回的数据结构是 { items: [...] } 或直接是 [...]
        const categoryList = data.items || data || [];
        setCategories(categoryList);
        // 默认选中第一个分类
        if (categoryList.length > 0) {
          const firstCategoryId = categoryList[0].id;
          setActiveKey(firstCategoryId);
          onSelectCategory(firstCategoryId);
        }
      } catch (err) {
        message.error('无法加载分类信息');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchCategories();
  }, [onSelectCategory]);

  const handleTabClick = (id) => {
    setActiveKey(id);
    onSelectCategory(id);
    // 可以在这里添加滚动到对应菜品列表的逻辑
    const element = document.getElementById(`category-${id}`);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  if (loading) {
    return (
      <div className="tabs-container sticky-tabs">
        <Spin />
      </div>
    );
  }

  return (
    <div className="tabs-container sticky-tabs">
      <div className="tabs-scroll-view">
        {categories.map((cat) => (
          <div
            key={cat.id}
            className={`tab-item ${activeKey === cat.id ? 'active' : ''}`}
            onClick={() => handleTabClick(cat.id)}
          >
            {cat.name}
          </div>
        ))}
      </div>
    </div>
  );
};

export default CategoryTabs;
