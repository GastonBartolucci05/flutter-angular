import 'package:flutter_app/features/products/domain/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts({int limit = 20, int skip = 0});
  Future<List<Product>> searchProducts(String query);
  Future<Product> getProductById(int id);
}
