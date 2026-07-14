import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:flutter/foundation.dart';

class PropertyDetailsViewModel extends ChangeNotifier {
  PropertyDetailsViewModel({required ReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  final ReviewRepository _reviewRepository;
  bool _isFavorite = false;
  PropertyReview? _myReview;
  int _selectedRating = 0;
  bool _isLoadingReview = false;
  bool _isSubmittingReview = false;
  String? _errorMessage;
  String? _reviewPropertyId;

  bool get isFavorite => _isFavorite;
  PropertyReview? get myReview => _myReview;
  int get selectedRating => _selectedRating;
  bool get isLoadingReview => _isLoadingReview;
  bool get isSubmittingReview => _isSubmittingReview;
  String? get errorMessage => _errorMessage;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
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
}
