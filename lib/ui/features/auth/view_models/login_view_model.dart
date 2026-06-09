import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class LoginErrors {
  const LoginErrors({this.identity, this.password});

  final String? identity;
  final String? password;

  bool get hasErrors => identity != null || password != null;
}

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _isSubmitting = false;
  LoginErrors _errors = const LoginErrors();
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isSubmitting => _isSubmitting;
  LoginErrors get errors => _errors;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    if (_rememberMe == value) {
      return;
    }
    _rememberMe = value;
    notifyListeners();
  }

  LoginErrors validate({required String identity, required String password}) {
    return LoginErrors(
      identity: identity.trim().isEmpty
          ? 'Enter your email or phone number'
          : null,
      password: password.isEmpty ? 'Enter your password' : null,
    );
  }

  Future<bool> submit({
    required String identity,
    required String password,
  }) async {
    if (_isSubmitting) {
      return false;
    }

    _errors = validate(identity: identity, password: password);
    _errorMessage = null;
    if (_errors.hasErrors) {
      _errorMessage = _errors.identity ?? _errors.password;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.login(
        identity: identity.trim(),
        password: password,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unable to login. Try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
