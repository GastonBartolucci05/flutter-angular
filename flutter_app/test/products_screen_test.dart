import 'package:flutter/material.dart';
import 'package:flutter_app/features/products/data/products_repositroy_impl.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/products_repository.dart';
import 'package:flutter_app/features/products/presentation/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _product = Product(
  id: 1,
  title: 'Product of test',
  description: 'Description of test',
  price: 10,
  rating: 4.5,
  thumbnail: 'https://example.com/img.png',
  category: 'test',
);

class FakeProductsRepository implements ProductsRepository {
  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async => [
    _product,
  ];

  @override
  Future<List<Product>> searchProducts(String query) async => [_product];

  @override
  Future<Product> getProductById(int id) async => _product;
}

class FailingProductsRepository implements ProductsRepository {
  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async =>
      throw Exception('boom');

  @override
  Future<List<Product>> searchProducts(String query) async =>
      throw Exception('boom');

  @override
  Future<Product> getProductById(int id) async => throw Exception('boom');
}

void main() {
  testWidgets('shows the products returned by the repository', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(
            FakeProductsRepository(),
          ),
        ],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Product of test'), findsOneWidget);
  });
  testWidgets('shows error view when the repository fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(
            FailingProductsRepository(),
          ),
        ],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('The products could not be loaded.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
