import 'package:bingcook/data/repositories/api_auth_repository.dart';
import 'package:bingcook/data/repositories/api_booking_repository.dart';
import 'package:bingcook/data/repositories/api_chat_repository.dart';
import 'package:bingcook/data/repositories/api_notification_repository.dart';
import 'package:bingcook/data/repositories/api_product_repository.dart';
import 'package:bingcook/data/repositories/api_review_repository.dart';
import 'package:bingcook/data/repositories/api_saved_property_repository.dart';
import 'package:bingcook/data/services/api_config.dart';
import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:bingcook/data/services/auth_session_storage.dart';
import 'package:bingcook/data/services/booking_api_service.dart';
import 'package:bingcook/data/services/chat_api_service.dart';
import 'package:bingcook/data/services/notification_api_service.dart';
import 'package:bingcook/data/services/product_api_service.dart';
import 'package:bingcook/data/services/review_api_service.dart';
import 'package:bingcook/data/services/saved_property_api_service.dart';
import 'package:bingcook/data/services/signalr_chat_service.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  AppDependencies._({
    required this.authRepository,
    required this.productRepository,
    required this.bookingRepository,
    required this.chatRepository,
    required this.notificationRepository,
    required this.savedPropertyRepository,
    required this.reviewRepository,
    this.chatRealtimeService,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  factory AppDependencies.production() {
    final client = http.Client();
    final baseUrl = Uri.parse(ApiConfig.baseUrl);
    final authApiService = AuthApiService(client: client, baseUrl: baseUrl);
    final authRepository = ApiAuthRepository(
      authApiService: authApiService,
      sessionStorage: const SecureAuthSessionStorage(),
    );
    final productApiService = ProductApiService(
      client: client,
      baseUrl: baseUrl,
    );
    final bookingApiService = BookingApiService(
      client: client,
      baseUrl: baseUrl,
    );
    final chatApiService = ChatApiService(client: client, baseUrl: baseUrl);
    final notificationApiService = NotificationApiService(
      client: client,
      baseUrl: baseUrl,
    );
    final savedPropertyApiService = SavedPropertyApiService(
      client: client,
      baseUrl: baseUrl,
    );
    final reviewApiService = ReviewApiService(client: client, baseUrl: baseUrl);

    return AppDependencies._(
      authRepository: authRepository,
      productRepository: ApiProductRepository(
        productApiService: productApiService,
      ),
      bookingRepository: ApiBookingRepository(
        bookingApiService: bookingApiService,
        authRepository: authRepository,
      ),
      chatRepository: ApiChatRepository(
        chatApiService: chatApiService,
        authRepository: authRepository,
      ),
      notificationRepository: ApiNotificationRepository(
        notificationApiService: notificationApiService,
        authRepository: authRepository,
      ),
      savedPropertyRepository: ApiSavedPropertyRepository(
        savedPropertyApiService: savedPropertyApiService,
        authRepository: authRepository,
      ),
      reviewRepository: ApiReviewRepository(
        reviewApiService: reviewApiService,
        authRepository: authRepository,
      ),
      chatRealtimeService: SignalRChatService(
        baseUrl: baseUrl,
        authRepository: authRepository,
      ),
      httpClient: client,
    );
  }

  factory AppDependencies.test({
    required AuthRepository authRepository,
    required ProductRepository productRepository,
    required BookingRepository bookingRepository,
    NotificationRepository? notificationRepository,
    SavedPropertyRepository? savedPropertyRepository,
    ChatRepository? chatRepository,
    ReviewRepository? reviewRepository,
    ChatRealtimeService? chatRealtimeService,
  }) {
    return AppDependencies._(
      authRepository: authRepository,
      productRepository: productRepository,
      bookingRepository: bookingRepository,
      notificationRepository:
          notificationRepository ?? const _UnavailableNotificationRepository(),
      savedPropertyRepository:
          savedPropertyRepository ??
          const _UnavailableSavedPropertyRepository(),
      chatRepository: chatRepository ?? const _UnavailableChatRepository(),
      reviewRepository:
          reviewRepository ?? const _UnavailableReviewRepository(),
      chatRealtimeService: chatRealtimeService,
    );
  }

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final BookingRepository bookingRepository;
  final ChatRepository chatRepository;
  final NotificationRepository notificationRepository;
  final SavedPropertyRepository savedPropertyRepository;
  final ReviewRepository reviewRepository;
  final ChatRealtimeService? chatRealtimeService;
  final http.Client? _httpClient;

  void dispose() {
    chatRealtimeService?.disconnect();
    _httpClient?.close();
  }
}

class _UnavailableReviewRepository implements ReviewRepository {
  const _UnavailableReviewRepository();

  @override
  Future<PropertyReview?> fetchMyReview(String propertyId) {
    throw const ReviewRepositoryException(
      'Reviews are unavailable in this test.',
    );
  }

  @override
  Future<PropertyReview> saveReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) {
    throw const ReviewRepositoryException(
      'Reviews are unavailable in this test.',
    );
  }
}

class _UnavailableSavedPropertyRepository implements SavedPropertyRepository {
  const _UnavailableSavedPropertyRepository();

  @override
  Future<List<Product>> fetchSavedProperties() async => const [];

  @override
  Future<void> removeProperty(String propertyId) {
    throw const SavedPropertyRepositoryException(
      'Saved stays are unavailable in this test.',
    );
  }

  @override
  Future<void> saveProperty(String propertyId) {
    throw const SavedPropertyRepositoryException(
      'Saved stays are unavailable in this test.',
    );
  }
}

class _UnavailableNotificationRepository implements NotificationRepository {
  const _UnavailableNotificationRepository();

  @override
  Future<List<NotificationItem>> fetchNotifications() {
    throw const NotificationRepositoryException(
      'Notifications are unavailable in this test.',
    );
  }

  @override
  Future<void> markAllRead() {
    throw const NotificationRepositoryException(
      'Notifications are unavailable in this test.',
    );
  }

  @override
  Future<void> markRead(String notificationId) {
    throw const NotificationRepositoryException(
      'Notifications are unavailable in this test.',
    );
  }
}

class _UnavailableChatRepository implements ChatRepository {
  const _UnavailableChatRepository();

  @override
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  }) {
    throw const ChatRepositoryException('Chat is unavailable in this test.');
  }

  @override
  Future<List<ChatConversation>> fetchConversations() {
    throw const ChatRepositoryException('Chat is unavailable in this test.');
  }

  @override
  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) {
    throw const ChatRepositoryException('Chat is unavailable in this test.');
  }

  @override
  Future<void> markRead({required String conversationId}) {
    throw const ChatRepositoryException('Chat is unavailable in this test.');
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) {
    throw const ChatRepositoryException('Chat is unavailable in this test.');
  }
}
