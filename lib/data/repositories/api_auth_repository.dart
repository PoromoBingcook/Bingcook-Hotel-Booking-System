import 'package:bingcook/data/models/auth_api_models.dart';
import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:bingcook/data/services/auth_session_storage.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository, RestorableAuthRepository {
  ApiAuthRepository({
    required AuthApiService authApiService,
    AuthSessionStorage? sessionStorage,
  }) : _authApiService = authApiService,
       _sessionStorage = sessionStorage;

  final AuthApiService _authApiService;
  final AuthSessionStorage? _sessionStorage;
  AuthSession? _currentSession;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  Future<void> restoreSession() async {
    try {
      _currentSession = await _sessionStorage?.read();
    } catch (_) {
      _currentSession = null;
    }
  }

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
      await _clearStoredSession();
      return;
    }

    try {
      await _authApiService.logout(token: token);
      _currentSession = null;
      await _clearStoredSession();
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
      await _persistSession(session);
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

  Future<void> _persistSession(AuthSession session) async {
    try {
      await _sessionStorage?.write(session);
    } catch (_) {
      // A storage failure must not turn a successful login into a failure.
    }
  }

  Future<void> _clearStoredSession() async {
    try {
      await _sessionStorage?.clear();
    } catch (_) {
      // The in-memory logout still succeeds if platform storage is unavailable.
    }
  }
}
