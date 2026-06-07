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
  bool _isPasswordVisible = false;
  SignUpErrors _errors = const SignUpErrors();

  bool get isPasswordVisible => _isPasswordVisible;
  SignUpErrors get errors => _errors;

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

  bool submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    _errors = validate(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    notifyListeners();
    return !_errors.hasErrors;
  }

  bool _looksLikeEmail(String value) {
    final separator = value.indexOf('@');
    return separator > 0 &&
        separator < value.length - 1 &&
        value.substring(separator + 1).contains('.');
  }
}
