import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:flutter/foundation.dart';

class SavedStaysViewModel extends ChangeNotifier {
  SavedStaysViewModel({
    required SavedPropertyRepository savedPropertyRepository,
  }) : _savedPropertyRepository = savedPropertyRepository;

  final SavedPropertyRepository _savedPropertyRepository;
  List<StayCardData> _stays = const [];
  Set<String> _savedIds = const {};
  final Set<String> _updatingIds = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _requestId = 0;

  List<StayCardData> get stays => _stays;
  bool get isLoading => _isLoading;
  bool get isEmpty => _hasLoaded && !_isLoading && _stays.isEmpty;
  String? get errorMessage => _errorMessage;

  bool isSaved(String propertyId) => _savedIds.contains(propertyId);

  bool isUpdating(String propertyId) => _updatingIds.contains(propertyId);

  Future<void> load() => _load(showLoading: true);

  Future<void> refresh() => _load(showLoading: _stays.isEmpty);

  Future<bool> toggle(String propertyId) async {
    if (_updatingIds.contains(propertyId)) return true;

    final wasSaved = isSaved(propertyId);
    final previousStays = _stays;
    _updatingIds.add(propertyId);
    _errorMessage = null;
    _savedIds = {..._savedIds};
    if (wasSaved) {
      _savedIds.remove(propertyId);
      _stays = _stays
          .where((stay) => stay.id != propertyId)
          .toList(growable: false);
    } else {
      _savedIds.add(propertyId);
    }
    notifyListeners();

    try {
      if (wasSaved) {
        await _savedPropertyRepository.removeProperty(propertyId);
      } else {
        await _savedPropertyRepository.saveProperty(propertyId);
      }
      await _load(showLoading: false);
      return true;
    } on SavedPropertyRepositoryException catch (error) {
      _restoreAfterFailure(propertyId, wasSaved, previousStays, error.message);
      return false;
    } catch (_) {
      _restoreAfterFailure(
        propertyId,
        wasSaved,
        previousStays,
        'Unable to update saved stays.',
      );
      return false;
    } finally {
      _updatingIds.remove(propertyId);
      notifyListeners();
    }
  }

  void _restoreAfterFailure(
    String propertyId,
    bool wasSaved,
    List<StayCardData> previousStays,
    String message,
  ) {
    _savedIds = {..._savedIds};
    if (wasSaved) {
      _savedIds.add(propertyId);
    } else {
      _savedIds.remove(propertyId);
    }
    _stays = previousStays;
    _errorMessage = message;
  }

  Future<void> _load({required bool showLoading}) async {
    final requestId = ++_requestId;
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await _savedPropertyRepository.fetchSavedProperties();
      if (requestId != _requestId) return;
      _stays = products.map(_toStayCardData).toList(growable: false);
      _savedIds = products.map((product) => product.id).toSet();
    } on SavedPropertyRepositoryException catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.message;
    } catch (_) {
      if (requestId != _requestId) return;
      _errorMessage = 'Unable to reach BingCook server.';
    } finally {
      if (requestId == _requestId) {
        _hasLoaded = true;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  StayCardData _toStayCardData(Product product) {
    return StayCardData(
      id: product.id,
      imageAsset: product.name == 'Blue Garden Homestay'
          ? AppAssets.blueGardenHomestay
          : AppAssets.oceanPearlHotel,
      imageUrl: product.imageUrl,
      type: product.type,
      name: product.name,
      description: product.description,
      location: product.location,
      city: product.city,
      address: product.address,
      latitude: product.latitude,
      longitude: product.longitude,
      rating: product.rating,
      reviewCount: product.reviewCount,
      amenities: product.amenities,
      price: product.pricePerNight.round(),
      status: product.status,
    );
  }
}
