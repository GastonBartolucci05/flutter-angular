import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = 'https://dummyjson.com';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: _baseUrl));
});
