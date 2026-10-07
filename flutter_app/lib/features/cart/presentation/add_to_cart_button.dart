import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/presentation/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddToCartButton extends ConsumerWidget {
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => ref.read(cartProvider.notifier).add(product),
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Agregar al carrito'),
    );
  }
}
