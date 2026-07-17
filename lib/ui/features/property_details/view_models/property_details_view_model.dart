import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

class PropertyDetailsViewModel extends ChangeNotifier {
  PropertyDetailsViewModel({
    required ReviewRepository reviewRepository,
    DateTime? now,
  }) : _reviewRepository = reviewRepository {
    final today = _dateOnly(now ?? DateTime.now());
    _defaultCheckIn = today.add(const Duration(days: 1));
    _checkIn = _defaultCheckIn;
    _checkOut = _checkIn.add(const Duration(days: 1));
  }

  final ReviewRepository _reviewRepository;
  late final DateTime _defaultCheckIn;
  late DateTime _checkIn;
  late DateTime _checkOut;
  int _guests = 2;
  PropertyReview? _myReview;
  int _selectedRating = 0;
  bool _isLoadingReview = false;
  bool _isSubmittingReview = false;
  String? _errorMessage;
  String? _reviewPropertyId;

  DateTime get checkIn => _checkIn;
  DateTime get checkOut => _checkOut;
  int get guests => _guests;
  PropertyReview? get myReview => _myReview;
  int get selectedRating => _selectedRating;
  bool get isLoadingReview => _isLoadingReview;
  bool get isSubmittingReview => _isSubmittingReview;
  String? get errorMessage => _errorMessage;

  void configure(ProductSearchQuery query) {
    final checkIn = query.checkIn ?? _defaultCheckIn;
    final requestedCheckOut = query.checkOut;
    final checkOut =
        requestedCheckOut != null && requestedCheckOut.isAfter(checkIn)
        ? requestedCheckOut
        : checkIn.add(const Duration(days: 1));
    final guests = query.guests != null && query.guests! > 0
        ? query.guests!
        : 2;

    if (_checkIn == checkIn && _checkOut == checkOut && _guests == guests) {
      return;
    }

    _checkIn = checkIn;
    _checkOut = checkOut;
    _guests = guests;
    notifyListeners();
  }

  void updateDates(DateTimeRange range) {
    if (!range.end.isAfter(range.start) ||
        (_checkIn == range.start && _checkOut == range.end)) {
      return;
    }

    _checkIn = range.start;
    _checkOut = range.end;
    notifyListeners();
  }

  void incrementGuests() {
    _guests++;
    notifyListeners();
  }

  void decrementGuests() {
    if (_guests == 1) return;
    _guests--;
    notifyListeners();
  }

  ProductSearchQuery buildQuery(ProductSearchQuery base) {
    return ProductSearchQuery(
      keyword: base.keyword,
      location: base.location,
      checkIn: _checkIn,
      checkOut: _checkOut,
      guests: _guests,
      minPrice: base.minPrice,
      maxPrice: base.maxPrice,
      amenities: base.amenities,
      minRating: base.minRating,
      type: base.type,
    );
  }

  Future<void> loadMyReview(String propertyId) async {
    _reviewPropertyId = propertyId;
    _myReview = null;
    _selectedRating = 0;
    _errorMessage = null;
    _isLoadingReview = true;
    notifyListeners();

    try {
      final review = await _reviewRepository.fetchMyReview(propertyId);
      if (_reviewPropertyId != propertyId) return;
      _myReview = review;
      _selectedRating = review?.rating ?? 0;
    } on ReviewRepositoryException catch (error) {
      if (_reviewPropertyId != propertyId) return;
      _errorMessage = error.message;
    } finally {
      if (_reviewPropertyId == propertyId) {
        _isLoadingReview = false;
        notifyListeners();
      }
    }
  }

  void selectRating(int rating) {
    if (rating == _selectedRating || rating < 1 || rating > 5) return;
    _selectedRating = rating;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitReview({
    required String propertyId,
    required String? comment,
  }) async {
    if (_selectedRating < 1 || _selectedRating > 5) {
      _errorMessage = 'Choose a rating from 1 to 5 stars.';
      notifyListeners();
      return false;
    }

    final trimmedComment = comment?.trim();
    _errorMessage = null;
    _isSubmittingReview = true;
    notifyListeners();

    try {
      final saved = await _reviewRepository.saveReview(
        propertyId: propertyId,
        rating: _selectedRating,
        comment: trimmedComment == null || trimmedComment.isEmpty
            ? null
            : trimmedComment,
      );
      _reviewPropertyId = propertyId;
      _myReview = saved;
      _selectedRating = saved.rating;
      return true;
    } on ReviewRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
