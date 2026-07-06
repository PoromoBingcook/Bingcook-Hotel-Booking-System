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
  bool get shouldOpenStaffPortal {
    final role = _authRepository.currentSession?.user.role.trim().toLowerCase();
    return role == 'host' || role == 'admin' || role == 'staff';
  }

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
    final normalizedIdentity = identity.trim();
    return LoginErrors(
      identity: _validateEmail(normalizedIdentity),
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

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Enter your email address';
    }
    return _looksLikeEmail(value) ? null : 'Enter a valid email address';
  }

  bool _looksLikeEmail(String value) {
    final atIndex = value.indexOf('@');
    final dotIndex = value.lastIndexOf('.');
    return atIndex > 0 && dotIndex > atIndex + 1 && dotIndex < value.length - 1;
  }
}
