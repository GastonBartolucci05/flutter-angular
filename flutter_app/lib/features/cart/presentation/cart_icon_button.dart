import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/presentation/cart_notifier.dart';
import 'package:flutter_app/features/cart/presentation/cart_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);

    return IconButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CartScreen())),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
