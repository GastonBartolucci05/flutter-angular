import 'package:flutter_app/features/products/domain/product.dart';

class ProductDto {
  final int id;
  final String title;
  final double price;
  final double rating;
  final String description;
  final String thumbnail;
  final String category;

  const ProductDto({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.description,
    required this.thumbnail,
    required this.category,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String,
    );
  }

  Product toDomain() => Product(
    id: id,
    title: title,
    price: price,
    rating: rating,
    description: description,
    thumbnail: thumbnail,
    category: category,
  );
}
