import 'package:dio/dio.dart';
import 'package:flutter_app/core/providers.dart';
import 'package:flutter_app/features/products/data/product_dto.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/products_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(dioProvider));
});

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return _parseProducts(response.data);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    return _parseProducts(response.data);
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await _dio.get('/products/$id');
    return ProductDto.fromJson(response.data).toDomain();
  }

  List<Product> _parseProducts(dynamic data) {
    final list = data['products'] as List;
    return list.map((json) => ProductDto.fromJson(json).toDomain()).toList();
  }
}
