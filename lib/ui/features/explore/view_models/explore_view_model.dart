import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:flutter/foundation.dart';

class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel({required ProductRepository productRepository})
    : _productRepository = productRepository;

  final ProductRepository _productRepository;
  List<StayCardData> _stays = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<StayCardData> get stays => _stays;
  bool get isLoading => _isLoading;
  bool get isEmpty => _hasLoaded && !_isLoading && _stays.isEmpty;
  String? get errorMessage => _errorMessage;

  String get resultCountLabel {
    final count = _stays.length;
    return count == 1 ? '1 result' : '$count results';
  }

  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await _productRepository.fetchProducts();
      _stays = products.map(_toStayCardData).toList(growable: false);
    } on ProductRepositoryException catch (error) {
      _stays = const [];
      _errorMessage = error.message;
    } catch (_) {
      _stays = const [];
      _errorMessage = 'Unable to reach BingCook server.';
    } finally {
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => loadProducts();

  StayCardData _toStayCardData(Product product) {
    return StayCardData(
      imageAsset: _fallbackImageAsset(product),
      imageUrl: product.imageUrl,
      type: product.type,
      name: product.name,
      location: product.location,
      rating: product.rating,
      reviewCount: product.reviewCount,
      amenities: product.amenities,
      price: product.pricePerNight.round(),
    );
  }

  String _fallbackImageAsset(Product product) {
    if (product.name == 'Blue Garden Homestay') {
      return AppAssets.blueGardenHomestay;
    }
    return AppAssets.oceanPearlHotel;
  }
}
