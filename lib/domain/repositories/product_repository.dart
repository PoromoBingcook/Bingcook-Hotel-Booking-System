import 'package:bingcook/domain/models/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts();
}

class ProductRepositoryException implements Exception {
  const ProductRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
