import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Helper to generate a unique ID for a cart item based on dish and flavors
const generateCartItemId = (dish, flavors) => {
  if (!flavors || Object.keys(flavors).length === 0) {
    return `${dish.id}`;
  }
  const flavorString = Object.entries(flavors)
    .sort(([keyA], [keyB]) => keyA.localeCompare(keyB)) // Sort for consistency
    .map(([key, value]) => `${key}:${value}`)
    .join('|');
  return `${dish.id}_${flavorString}`;
};

const useStore = create(
  persist(
    (set, get) => ({
      cart: [],
      user: null,

      // Add item to cart, potentially with flavors
      addToCart: (dish, selectedFlavors = {}) => {
        const cartItemId = generateCartItemId(dish, selectedFlavors);
        const cart = get().cart;
        const existingItem = cart.find((item) => item.cartItemId === cartItemId);

        if (existingItem) {
          // If item with same flavors exists, increment quantity
          existingItem.quantity += 1;
          set({ cart: [...cart] });
        } else {
          // Otherwise, add new item to cart
          const newItem = {
            ...dish,
            quantity: 1,
            selectedFlavors,
            cartItemId,
          };
          set({ cart: [...cart, newItem] });
        }
      },

      // Remove an item from the cart by its unique cartItemId
      removeFromCart: (cartItemId) => {
        set((state) => ({
          cart: state.cart.filter((item) => item.cartItemId !== cartItemId),
        }));
      },

      // Update quantity of an item by its unique cartItemId
      updateQuantity: (cartItemId, quantity) => {
        set((state) => ({
          cart: state.cart
            .map((item) =>
              item.cartItemId === cartItemId ? { ...item, quantity } : item
            )
            .filter((item) => item.quantity > 0), // Remove item if quantity is 0
        }));
      },

      // Clear the entire cart
      clearCart: () => set({ cart: [] }),

      // User session management
      setUser: (user) => set({ user }),
      logout: () => set({ user: null, token: null }),
    }),
    {
      name: 'jd-take-out-storage', // localStorage key
    }
  )
);

export default useStore;
