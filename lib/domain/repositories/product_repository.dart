import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  });

  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  });
}

class ProductRepositoryException implements Exception {
  const ProductRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
