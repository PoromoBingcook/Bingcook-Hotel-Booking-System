import 'package:bingcook/data/repositories/api_auth_repository.dart';
import 'package:bingcook/data/repositories/api_booking_repository.dart';
import 'package:bingcook/data/repositories/api_product_repository.dart';
import 'package:bingcook/data/services/api_config.dart';
import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:bingcook/data/services/booking_api_service.dart';
import 'package:bingcook/data/services/product_api_service.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  AppDependencies._({
    required this.authRepository,
    required this.productRepository,
    required this.bookingRepository,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  factory AppDependencies.production() {
    final client = http.Client();
    final baseUrl = Uri.parse(ApiConfig.baseUrl);
    final authApiService = AuthApiService(client: client, baseUrl: baseUrl);
    final authRepository = ApiAuthRepository(authApiService: authApiService);
    final productApiService = ProductApiService(
      client: client,
      baseUrl: baseUrl,
    );
    final bookingApiService = BookingApiService(
      client: client,
      baseUrl: baseUrl,
    );

    return AppDependencies._(
      authRepository: authRepository,
      productRepository: ApiProductRepository(
        productApiService: productApiService,
      ),
      bookingRepository: ApiBookingRepository(
        bookingApiService: bookingApiService,
        authRepository: authRepository,
      ),
      httpClient: client,
    );
  }

  factory AppDependencies.test({
    required AuthRepository authRepository,
    required ProductRepository productRepository,
    required BookingRepository bookingRepository,
  }) {
    return AppDependencies._(
      authRepository: authRepository,
      productRepository: productRepository,
      bookingRepository: bookingRepository,
    );
  }

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final BookingRepository bookingRepository;
  final http.Client? _httpClient;

  void dispose() {
    _httpClient?.close();
  }
}
