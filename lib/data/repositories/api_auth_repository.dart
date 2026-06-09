import 'package:bingcook/data/models/auth_api_models.dart';
import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required AuthApiService authApiService})
    : _authApiService = authApiService;

  final AuthApiService _authApiService;
  AuthSession? _currentSession;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _runAuthRequest(
      () => _authApiService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _runAuthRequest(
      () => _authApiService.login(identity: identity, password: password),
    );
  }

  @override
  Future<void> logout() async {
    final token = _currentSession?.token;
    if (token == null || token.isEmpty) {
      _currentSession = null;
      return;
    }

    try {
      await _authApiService.logout(token: token);
      _currentSession = null;
    } on AuthApiException catch (error) {
      throw AuthRepositoryException(error.message);
    } catch (_) {
      throw const AuthRepositoryException('Unable to reach BingCook server.');
    }
  }

  Future<AuthSession> _runAuthRequest(
    Future<AuthApiResponse> Function() request,
  ) async {
    try {
      final response = await request();
      final session = response.toDomain();
      _currentSession = session;
      return session;
    } on AuthApiException catch (error) {
      throw AuthRepositoryException(error.message);
    } on FormatException {
      throw const AuthRepositoryException(
        'Unable to read authentication response.',
      );
    } catch (_) {
      throw const AuthRepositoryException('Unable to reach BingCook server.');
    }
  }
}
