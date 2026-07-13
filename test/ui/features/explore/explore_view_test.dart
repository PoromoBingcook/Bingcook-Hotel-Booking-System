import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/explore/view_models/explore_view_model.dart';
import 'package:bingcook/ui/features/explore/views/explore_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty results can be refreshed', (tester) async {
    final viewModel = ExploreViewModel(
      productRepository: const _EmptyProductRepository(),
    );
    await viewModel.loadProducts();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExploreView(viewModel: viewModel)),
      ),
    );

    expect(find.text('No stays match your search.'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });
}

class _EmptyProductRepository implements ProductRepository {
  const _EmptyProductRepository();

  @override
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    return const [];
  }

  @override
  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) {
    throw UnimplementedError();
  }
}
