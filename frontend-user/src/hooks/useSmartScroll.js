
import { useState, useEffect, useRef } from 'react';

export const useSmartScroll = (targetRef) => {
  const [isVisible, setIsVisible] = useState(true);
  const lastScrollY = useRef(0);
  const timeoutId = useRef(null);

  useEffect(() => {
    const element = targetRef.current;

    if (!element) {
      return;
    }

    const handleScroll = () => {
      const currentScrollY = element.scrollTop;
      if (timeoutId.current) {
        clearTimeout(timeoutId.current);
      }
      if (currentScrollY < lastScrollY.current || currentScrollY < 10) {
        setIsVisible(true);
      } else { 
        if (currentScrollY > 100) {
          setIsVisible(false);
        }
      }
      timeoutId.current = setTimeout(() => {
        setIsVisible(true);
      }, 2000);
      lastScrollY.current = currentScrollY;
    };

    element.addEventListener('scroll', handleScroll, { passive: true });

    return () => {
      element.removeEventListener('scroll', handleScroll);
      if (timeoutId.current) {
        clearTimeout(timeoutId.current);
      }
    };
  }, [targetRef.current]);

  return isVisible;
};
