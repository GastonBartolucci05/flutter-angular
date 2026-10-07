import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/presentation/cart_item_tile.dart';
import 'package:flutter_app/features/cart/presentation/cart_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      return CartItemTile(
                        cartItem: cartItem,
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .changeQuantity(
                              cartItem.product.id,
                              cartItem.quantity - 1,
                            ),
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .changeQuantity(
                              cartItem.product.id,
                              cartItem.quantity + 1,
                            ),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .remove(cartItem.product.id),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 20)),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
