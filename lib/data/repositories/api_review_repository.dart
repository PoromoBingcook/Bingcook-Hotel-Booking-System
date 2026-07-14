import 'package:bingcook/data/services/review_api_service.dart';
import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';

class ApiReviewRepository implements ReviewRepository {
  const ApiReviewRepository({
    required ReviewApiService reviewApiService,
    required AuthRepository authRepository,
  }) : _reviewApiService = reviewApiService,
       _authRepository = authRepository;

  final ReviewApiService _reviewApiService;
  final AuthRepository _authRepository;

  @override
  Future<PropertyReview?> fetchMyReview(String propertyId) async {
    try {
      final response = await _reviewApiService.fetchMyReview(
        token: _token(),
        propertyId: propertyId,
      );
      return response?.toDomain();
    } on ReviewRepositoryException {
      rethrow;
    } on ReviewApiException catch (error) {
      throw ReviewRepositoryException(error.message);
    } on FormatException {
      throw const ReviewRepositoryException('Unable to read review response.');
    } catch (_) {
      throw const ReviewRepositoryException('Unable to reach BingCook server.');
    }
  }

  @override
  Future<PropertyReview> saveReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _reviewApiService.saveReview(
        token: _token(),
        propertyId: propertyId,
        rating: rating,
        comment: comment,
      );
      return response.toDomain();
    } on ReviewRepositoryException {
      rethrow;
    } on ReviewApiException catch (error) {
      throw ReviewRepositoryException(error.message);
    } on FormatException {
      throw const ReviewRepositoryException('Unable to read review response.');
    } catch (_) {
      throw const ReviewRepositoryException('Unable to reach BingCook server.');
    }
  }

  String _token() {
    final token = _authRepository.currentSession?.token;
    if (token == null || token.isEmpty) {
      throw const ReviewRepositoryException(
        'Please login to review this property.',
      );
    }
    return token;
  }
}
