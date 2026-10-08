import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/products/data/product_detail_content.dart';
import 'package:flutter_app/features/products/presentation/product_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: productAsync.when(
        data: (product) => ProductDetailContent(product: product),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: "The product could not be loaded.",
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
      ),
    );
  }
}
