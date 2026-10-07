import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/presentation/add_to_cart_button.dart';
import 'package:flutter_app/features/products/domain/product.dart';

class ProductDetailContent extends StatelessWidget {
  const ProductDetailContent({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.thumbnail,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 8),
            Text('\$${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(product.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            Text(product.category),
            const SizedBox(height: 16),
            AddToCartButton(product: product),
          ],
        ),
      ),
    );
  }
}
