import 'package:bingcook/data/services/product_api_service.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';

class ApiProductRepository implements ProductRepository {
  const ApiProductRepository({required ProductApiService productApiService})
    : _productApiService = productApiService;

  final ProductApiService _productApiService;

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _productApiService.fetchProducts();
      return response.map((product) => product.toDomain()).toList();
    } on ProductApiException catch (error) {
      throw ProductRepositoryException(error.message);
    } on FormatException {
      throw const ProductRepositoryException(
        'Unable to read products response.',
      );
    } catch (_) {
      throw const ProductRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }
}
