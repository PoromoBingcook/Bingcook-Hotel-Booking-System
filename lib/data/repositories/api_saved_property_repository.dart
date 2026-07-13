import 'package:bingcook/data/services/saved_property_api_service.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';

class ApiSavedPropertyRepository implements SavedPropertyRepository {
  const ApiSavedPropertyRepository({
    required SavedPropertyApiService savedPropertyApiService,
    required AuthRepository authRepository,
  }) : _savedPropertyApiService = savedPropertyApiService,
       _authRepository = authRepository;

  final SavedPropertyApiService _savedPropertyApiService;
  final AuthRepository _authRepository;

  @override
  Future<List<Product>> fetchSavedProperties() async {
    try {
      final response = await _savedPropertyApiService.fetchSavedProperties(
        token: _token(),
      );
      return response.map((item) => item.toDomain()).toList(growable: false);
    } on SavedPropertyRepositoryException {
      rethrow;
    } on SavedPropertyApiException catch (error) {
      throw SavedPropertyRepositoryException(error.message);
    } on FormatException {
      throw const SavedPropertyRepositoryException(
        'Unable to read saved stays.',
      );
    } catch (_) {
      throw const SavedPropertyRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<void> saveProperty(String propertyId) async {
    try {
      await _savedPropertyApiService.saveProperty(
        token: _token(),
        propertyId: propertyId,
      );
    } on SavedPropertyRepositoryException {
      rethrow;
    } on SavedPropertyApiException catch (error) {
      throw SavedPropertyRepositoryException(error.message);
    } catch (_) {
      throw const SavedPropertyRepositoryException('Unable to save this stay.');
    }
  }

  @override
  Future<void> removeProperty(String propertyId) async {
    try {
      await _savedPropertyApiService.removeProperty(
        token: _token(),
        propertyId: propertyId,
      );
    } on SavedPropertyRepositoryException {
      rethrow;
    } on SavedPropertyApiException catch (error) {
      throw SavedPropertyRepositoryException(error.message);
    } catch (_) {
      throw const SavedPropertyRepositoryException(
        'Unable to remove this stay.',
      );
    }
  }

  String _token() {
    final token = _authRepository.currentSession?.token;
    if (token == null || token.isEmpty) {
      throw const SavedPropertyRepositoryException(
        'Please login to view saved stays.',
      );
    }
    return token;
  }
}
