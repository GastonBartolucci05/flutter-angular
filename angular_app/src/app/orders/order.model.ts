export interface OrderProduct {
  id: number;
  title: string;
  price: number;
  quantity: number;
  total: number;
}

export interface Order {
  id: number;
  userId: number;
  products: OrderProduct[];
  total: number;
  totalProducts: number;
  totalQuantity: number;
}

export interface OrderResponse {
  carts: Order[];
}