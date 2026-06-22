import 'package:bingcook/data/models/product_api_models.dart';
import 'package:bingcook/data/repositories/api_product_repository.dart';
import 'package:bingcook/data/services/product_api_service.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiProductRepository', () {
    test('maps API products to domain products', () async {
      final repository = ApiProductRepository(
        productApiService: FakeProductApiService(
          products: const [
            ProductListItemResponse(
              id: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
              type: 'Hotel',
              name: 'Ocean Pearl Hotel',
              description: 'Beachfront hotel near My Khe Beach.',
              location: 'Da Nang, Vo Nguyen Giap, Son Tra',
              city: 'Da Nang',
              address: 'Vo Nguyen Giap, Son Tra',
              imageUrl: 'https://example.com/ocean.jpg',
              rating: 4.7,
              reviewCount: 3,
              amenities: ['Wi-Fi', 'Pool'],
              pricePerNight: 68,
              status: 'Active',
            ),
          ],
        ),
      );

      final products = await repository.fetchProducts();

      expect(products, hasLength(1));
      expect(products.single.id, '13430237-d5ed-4c9f-be3a-feddf4cb4fa8');
      expect(products.single.name, 'Ocean Pearl Hotel');
      expect(products.single.pricePerNight, 68);
      expect(products.single.amenities, ['Wi-Fi', 'Pool']);
    });

    test('converts API failures to repository failures', () async {
      final repository = ApiProductRepository(
        productApiService: FakeProductApiService(
          error: const ProductApiException('Products unavailable.'),
        ),
      );

      expect(
        repository.fetchProducts,
        throwsA(
          isA<ProductRepositoryException>().having(
            (error) => error.message,
            'message',
            'Products unavailable.',
          ),
        ),
      );
    });
  });
}

class FakeProductApiService implements ProductApiService {
  const FakeProductApiService({this.products = const [], this.error});

  final List<ProductListItemResponse> products;
  final ProductApiException? error;

  @override
  Future<List<ProductListItemResponse>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return products;
  }

  @override
  Future<ProductDetailsResponse> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) {
    throw UnimplementedError();
  }
}
