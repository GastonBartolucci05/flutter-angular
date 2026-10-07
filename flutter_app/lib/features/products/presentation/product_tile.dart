import 'package:flutter/material.dart';
import 'package:flutter_app/features/products/domain/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Image.network(product.thumbnail, width: 50, height: 50),
      title: Text(product.title),
      subtitle: Row(
        children: [
          Text('\$${product.price.toStringAsFixed(2)}'),
          const SizedBox(width: 2),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          Text(' ${product.rating.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}
