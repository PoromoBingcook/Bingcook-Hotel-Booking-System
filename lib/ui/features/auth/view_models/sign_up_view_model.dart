import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class SignUpErrors {
  const SignUpErrors({this.fullName, this.email, this.phone, this.password});

  final String? fullName;
  final String? email;
  final String? phone;
  final String? password;

  bool get hasErrors =>
      fullName != null || email != null || phone != null || password != null;
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  SignUpErrors _errors = const SignUpErrors();
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isSubmitting => _isSubmitting;
  SignUpErrors get errors => _errors;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  SignUpErrors validate({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    final normalizedEmail = email.trim();
    return SignUpErrors(
      fullName: fullName.trim().isEmpty ? 'Enter your full name' : null,
      email: normalizedEmail.isEmpty
          ? 'Enter your email address'
          : (!_looksLikeEmail(normalizedEmail)
                ? 'Enter a valid email address'
                : null),
      phone: phone.trim().isEmpty ? 'Enter your phone number' : null,
      password: password.isEmpty
          ? 'Enter a password'
          : (password.length < 8 ? 'Use at least 8 characters' : null),
    );
  }

  Future<bool> submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (_isSubmitting) {
      return false;
    }

    _errors = validate(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    _errorMessage = null;
    if (_errors.hasErrors) {
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
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
      _errorMessage = 'Unable to create account. Try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  bool _looksLikeEmail(String value) {
    final separator = value.indexOf('@');
    return separator > 0 &&
        separator < value.length - 1 &&
        value.substring(separator + 1).contains('.');
  }
}
