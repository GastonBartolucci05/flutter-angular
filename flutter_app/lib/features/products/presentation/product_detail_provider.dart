import 'package:flutter_app/features/products/data/products_repositroy_impl.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productDetailProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  id,
) {
  return ref.watch(productsRepositoryProvider).getProductById(id);
});
