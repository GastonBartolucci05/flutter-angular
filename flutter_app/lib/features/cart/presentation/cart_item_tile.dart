import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  final CartItem cartItem;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(cartItem.product.thumbnail, width: 50, height: 50),
      title: Text(cartItem.product.title),
      subtitle: Text('\$${cartItem.subtotal.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
          Text('${cartItem.quantity}'),
          IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
          IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
        ],
      ),
    );
  }
}
