import 'dart:async';

import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/explore/view_models/explore_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExploreViewModel', () {
    test('loads products and exposes stay cards', () async {
      final completer = Completer<List<Product>>();
      final viewModel = ExploreViewModel(
        productRepository: FakeProductRepository(completer.future),
      );

      final load = viewModel.loadProducts();

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.stays, isEmpty);

      completer.complete([
        const Product(
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
          isAvailable: true,
        ),
      ]);
      await load;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.resultCountLabel, '1 result');
      expect(viewModel.stays.single.name, 'Ocean Pearl Hotel');
      expect(
        viewModel.stays.single.description,
        'Beachfront hotel near My Khe Beach.',
      );
      expect(
        viewModel.stays.single.location,
        'Da Nang, Vo Nguyen Giap, Son Tra',
      );
      expect(viewModel.stays.single.city, 'Da Nang');
      expect(viewModel.stays.single.address, 'Vo Nguyen Giap, Son Tra');
      expect(viewModel.stays.single.imageUrl, 'https://example.com/ocean.jpg');
      expect(viewModel.stays.single.price, 68);
      expect(viewModel.stays.single.status, 'Active');
    });

    test('exposes empty state when API returns no products', () async {
      final viewModel = ExploreViewModel(
        productRepository: FakeProductRepository(Future.value(const [])),
      );

      await viewModel.loadProducts();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.resultCountLabel, '0 results');
      expect(viewModel.stays, isEmpty);
    });

    test('exposes repository failure message', () async {
      final viewModel = ExploreViewModel(
        productRepository: FakeProductRepository(
          Future.error(
            const ProductRepositoryException(
              'Unable to reach BingCook server.',
            ),
          ),
        ),
      );

      await viewModel.loadProducts();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Unable to reach BingCook server.');
      expect(viewModel.stays, isEmpty);
    });

    test('keeps a search submitted during the initial load', () async {
      final repository = _QueuedProductRepository();
      final viewModel = ExploreViewModel(productRepository: repository);

      final initialLoad = viewModel.loadProducts();
      final search = viewModel.applySearch(
        const ProductSearchQuery(keyword: 'Ocean Pearl'),
      );
      repository.completeSearch([
        const Product(
          id: 'result',
          type: 'Hotel',
          name: 'Ocean Pearl Hotel',
          description: '',
          location: 'Da Nang',
          city: 'Da Nang',
          address: '',
          imageUrl: null,
          rating: 4.7,
          reviewCount: 3,
          amenities: [],
          pricePerNight: 100,
          status: 'Active',
          isAvailable: true,
        ),
      ]);
      await search;
      repository.completeInitial(const []);
      await initialLoad;

      expect(viewModel.activeQuery.keyword, 'Ocean Pearl');
      expect(viewModel.stays.single.name, 'Ocean Pearl Hotel');
    });
  });
}

class _QueuedProductRepository implements ProductRepository {
  final initial = Completer<List<Product>>();
  final search = Completer<List<Product>>();

  void completeInitial(List<Product> products) => initial.complete(products);
  void completeSearch(List<Product> products) => search.complete(products);

  @override
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) => query.keyword == null ? initial.future : search.future;

  @override
  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) => throw UnimplementedError();
}

class FakeProductRepository implements ProductRepository {
  const FakeProductRepository(this.products);

  final Future<List<Product>> products;

  @override
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) {
    return products;
  }

  @override
  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) {
    throw UnimplementedError();
  }
}
