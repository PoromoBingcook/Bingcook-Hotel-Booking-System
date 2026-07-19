import 'package:bingcook/data/models/review_api_models.dart';
import 'package:bingcook/data/repositories/api_review_repository.dart';
import 'package:bingcook/data/services/review_api_service.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiReviewRepository', () {
    test('maps API review and forwards the auth token', () async {
      final service = FakeReviewApiService(
        review: ReviewApiResponse(
          id: 'review-1',
          propertyId: 'property-1',
          rating: 4,
          comment: 'Comfortable room.',
          createdAt: DateTime.utc(2026, 7, 15, 2),
        ),
      );
      final repository = ApiReviewRepository(
        reviewApiService: service,
        authRepository: FakeAuthRepository(),
      );

      final review = await repository.fetchMyReview('property-1');

      expect(service.lastToken, 'jwt-token');
      expect(service.lastPropertyId, 'property-1');
      expect(review?.id, 'review-1');
      expect(review?.rating, 4);
    });

    test('saveReview forwards optional comment and maps result', () async {
      final service = FakeReviewApiService(
        review: ReviewApiResponse(
          id: 'review-1',
          propertyId: 'property-1',
          rating: 5,
          comment: null,
          createdAt: DateTime.utc(2026, 7, 15, 2),
        ),
      );
      final repository = ApiReviewRepository(
        reviewApiService: service,
        authRepository: FakeAuthRepository(),
      );

      final review = await repository.saveReview(
        propertyId: 'property-1',
        rating: 5,
      );

      expect(service.lastRating, 5);
      expect(service.lastComment, isNull);
      expect(review.rating, 5);
    });

    test('requires a logged-in session', () async {
      final repository = ApiReviewRepository(
        reviewApiService: FakeReviewApiService(),
        authRepository: const FakeAuthRepository.unauthenticated(),
      );

      expect(
        () => repository.fetchMyReview('property-1'),
        throwsA(
          isA<ReviewRepositoryException>().having(
            (error) => error.message,
            'message',
            'Please login to review this property.',
          ),
        ),
      );
    });

    test('maps API failures to repository failures', () async {
      final repository = ApiReviewRepository(
        reviewApiService: FakeReviewApiService(
          error: ReviewApiException('Reviews unavailable.'),
        ),
        authRepository: FakeAuthRepository(),
      );

      expect(
        () => repository.fetchMyReview('property-1'),
        throwsA(
          isA<ReviewRepositoryException>().having(
            (error) => error.message,
            'message',
            'Reviews unavailable.',
          ),
        ),
      );
    });
  });
}

class FakeReviewApiService implements ReviewApiService {
  FakeReviewApiService({this.review, this.error});

  final ReviewApiResponse? review;
  final ReviewApiException? error;
  String? lastToken;
  String? lastPropertyId;
  int? lastRating;
  String? lastComment;

  @override
  Future<ReviewApiResponse?> fetchMyReview({
    required String token,
    required String propertyId,
  }) async {
    lastToken = token;
    lastPropertyId = propertyId;
    final error = this.error;
    if (error != null) throw error;
    return review;
  }

  @override
  Future<ReviewApiResponse> saveReview({
    required String token,
    required String propertyId,
    required int rating,
    required String? comment,
  }) async {
    lastToken = token;
    lastPropertyId = propertyId;
    lastRating = rating;
    lastComment = comment;
    final error = this.error;
    if (error != null) throw error;
    return review!;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _session = _defaultSession;
  const FakeAuthRepository.unauthenticated() : _session = null;

  final AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async => _defaultSession;

  @override
  Future<void> logout() async {}

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async => _defaultSession;

  static final _defaultSession = AuthSession(
    token: 'jwt-token',
    user: AuthUser(
      id: 'user-1',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '0900000000',
      role: 'Customer',
    ),
  );
}
