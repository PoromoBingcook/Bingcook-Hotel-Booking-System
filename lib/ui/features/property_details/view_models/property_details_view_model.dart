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
    _minimumCheckIn = today;
    _defaultCheckIn = today.add(const Duration(days: 1));
    _checkIn = _defaultCheckIn;
    _checkOut = _checkIn.add(const Duration(days: 1));
  }

  final ReviewRepository _reviewRepository;
  late final DateTime _minimumCheckIn;
  late final DateTime _defaultCheckIn;
  late DateTime _checkIn;
  late DateTime _checkOut;
  int _guests = 2;
  PropertyReview? _myReview;
  List<PropertyReview> _myReviews = const [];
  PropertyReview? _editingReview;
  int _selectedRating = 0;
  bool _isLoadingReview = false;
  bool _isSubmittingReview = false;
  String? _errorMessage;
  String? _reviewPropertyId;

  DateTime get checkIn => _checkIn;
  DateTime get checkOut => _checkOut;
  int get guests => _guests;
  PropertyReview? get myReview => _myReview;
  List<PropertyReview> get myReviews => List.unmodifiable(_myReviews);
  PropertyReview? get editingReview => _editingReview;
  int get selectedRating => _selectedRating;
  bool get isLoadingReview => _isLoadingReview;
  bool get isSubmittingReview => _isSubmittingReview;
  String? get errorMessage => _errorMessage;

  void configure(ProductSearchQuery query) {
    final requestedCheckIn = _dateOnly(query.checkIn ?? _defaultCheckIn);
    final checkIn = requestedCheckIn.isBefore(_minimumCheckIn)
        ? _minimumCheckIn
        : requestedCheckIn;
    final requestedCheckOut = query.checkOut;
    final checkOut =
        requestedCheckOut != null &&
            _dateOnly(requestedCheckOut).isAfter(checkIn)
        ? _dateOnly(requestedCheckOut)
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
    final start = _dateOnly(range.start);
    final end = _dateOnly(range.end);
    if (start.isBefore(_minimumCheckIn) ||
        !end.isAfter(start) ||
        (_checkIn == start && _checkOut == end)) {
      return;
    }

    _checkIn = start;
    _checkOut = end;
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
    _myReviews = const [];
    _editingReview = null;
    _selectedRating = 0;
    _errorMessage = null;
    _isLoadingReview = true;
    notifyListeners();

    try {
      final repository = _reviewRepository;
      final multiRepository = repository is MultiReviewRepository
          ? repository as MultiReviewRepository
          : null;
      final List<PropertyReview> reviews;
      if (multiRepository != null) {
        reviews = await multiRepository.fetchMyReviews(propertyId);
      } else {
        final review = await repository.fetchMyReview(propertyId);
        reviews = review == null ? const [] : [review];
      }
      if (_reviewPropertyId != propertyId) return;
      _myReviews = reviews;
      _myReview = reviews.isEmpty ? null : reviews.first;
      _editingReview = null;
      _selectedRating = _myReview?.rating ?? 0;
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

  bool ownsReview(String reviewId) {
    return reviewId.isNotEmpty &&
        _myReviews.any((review) => review.id == reviewId);
  }

  void prepareNewReview() {
    _editingReview = null;
    _selectedRating = 0;
    _errorMessage = null;
    notifyListeners();
  }

  bool prepareEditReview(String reviewId) {
    PropertyReview? ownedReview;
    for (final review in _myReviews) {
      if (review.id == reviewId) {
        ownedReview = review;
        break;
      }
    }
    if (ownedReview == null) return false;
    _editingReview = ownedReview;
    _selectedRating = ownedReview.rating;
    _errorMessage = null;
    notifyListeners();
    return true;
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
      final normalizedComment = trimmedComment == null || trimmedComment.isEmpty
          ? null
          : trimmedComment;
      final repository = _reviewRepository;
      final multiRepository = repository is MultiReviewRepository
          ? repository as MultiReviewRepository
          : null;
      final editingReview = _editingReview;
      final PropertyReview saved = multiRepository != null
          ? editingReview == null
                ? await multiRepository.createReview(
                    propertyId: propertyId,
                    rating: _selectedRating,
                    comment: normalizedComment,
                  )
                : await multiRepository.updateReview(
                    reviewId: editingReview.id,
                    rating: _selectedRating,
                    comment: normalizedComment,
                  )
          : await repository.saveReview(
              propertyId: propertyId,
              rating: _selectedRating,
              comment: normalizedComment,
            );
      _reviewPropertyId = propertyId;
      _myReview = saved;
      if (editingReview == null) {
        _myReviews = [saved, ..._myReviews];
      } else {
        _myReviews = _myReviews
            .map((review) => review.id == saved.id ? saved : review)
            .toList(growable: false);
      }
      _editingReview = saved;
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
