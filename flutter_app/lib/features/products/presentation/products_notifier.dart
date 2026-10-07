import 'package:flutter_app/features/products/data/products_repositroy_impl.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/presentation/search_query_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _searchDebounce = Duration(milliseconds: 400);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final query = ref.watch(searchQueryProvider);
    final repository = ref.watch(productsRepositoryProvider);

    if (query.isEmpty) return repository.getProducts();

    var cancelled = false;
    ref.onDispose(() => cancelled = true);

    await Future.delayed(_searchDebounce);
    if (cancelled) return [];

    return repository.searchProducts(query);
  }
}

final productsProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);
