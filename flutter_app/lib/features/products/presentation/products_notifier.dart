import 'package:flutter_app/features/products/data/products_repositroy_impl.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return ref.watch(productsRepositoryProvider).getProducts();
  }
}

final productsProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);
