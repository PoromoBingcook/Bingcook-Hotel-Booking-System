import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class SignUpErrors {
  const SignUpErrors({
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.confirmPassword,
  });

  final String? fullName;
  final String? email;
  final String? phone;
  final String? password;
  final String? confirmPassword;

  bool get hasErrors =>
      fullName != null ||
      email != null ||
      phone != null ||
      password != null ||
      confirmPassword != null;
}

enum SignUpField { fullName, email, phone, password, confirmPassword }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  SignUpErrors _errors = const SignUpErrors();
  String? _errorMessage;
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';
  final Set<SignUpField> _editedFields = {};

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isSubmitting => _isSubmitting;
  SignUpErrors get errors => _errors;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void updateInput({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
  }) {
    if (fullName != null) {
      _fullName = fullName;
      _editedFields.add(SignUpField.fullName);
      _errors = _withFieldError(SignUpField.fullName, null);
    }
    if (email != null) {
      _email = email;
      _editedFields.add(SignUpField.email);
      _errors = _withFieldError(SignUpField.email, null);
    }
    if (phone != null) {
      _phone = phone;
      _editedFields.add(SignUpField.phone);
      _errors = _withFieldError(SignUpField.phone, null);
    }
    if (password != null) {
      _password = password;
      _editedFields.add(SignUpField.password);
      _errors = _withFieldError(SignUpField.password, null);
      _errors = _withFieldError(SignUpField.confirmPassword, null);
    }
    if (confirmPassword != null) {
      _confirmPassword = confirmPassword;
      _editedFields.add(SignUpField.confirmPassword);
      _errors = _withFieldError(SignUpField.confirmPassword, null);
    }
    _errorMessage = null;
    notifyListeners();
  }

  void validateField(SignUpField field) {
    if (!_editedFields.contains(field)) {
      return;
    }

    _errors = _withFieldError(field, _validateField(field));
    _errorMessage = null;
    notifyListeners();
  }

  SignUpErrors validate({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    final normalizedEmail = email.trim();
    return SignUpErrors(
      fullName: _validateFullName(fullName),
      email: _validateEmail(normalizedEmail),
      phone: _validatePhone(phone),
      password: _validatePassword(password),
      confirmPassword: _validateConfirmPassword(password, confirmPassword),
    );
  }

  Future<bool> submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (_isSubmitting) {
      return false;
    }

    _fullName = fullName;
    _email = email;
    _phone = phone;
    _password = password;
    _confirmPassword = confirmPassword;
    _editedFields.addAll(SignUpField.values);
    _errors = validate(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
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
        phone: _phoneDigits(phone),
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

  String? _validateField(SignUpField field) {
    return switch (field) {
      SignUpField.fullName => _validateFullName(_fullName),
      SignUpField.email => _validateEmail(_email.trim()),
      SignUpField.phone => _validatePhone(_phone),
      SignUpField.password => _validatePassword(_password),
      SignUpField.confirmPassword => _validateConfirmPassword(
        _password,
        _confirmPassword,
      ),
    };
  }

  String? _validateFullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Enter your full name';
    }
    return RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(trimmed)
        ? null
        : 'Full name can only contain letters, numbers, and spaces';
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Enter your email address';
    }
    return _looksLikeEmail(value) ? null : 'Enter a valid email address';
  }

  String? _validatePhone(String value) {
    final digits = _phoneDigits(value);
    if (digits.isEmpty) {
      return 'Enter your phone number';
    }
    return digits.length > 10 ? 'Phone number must be at most 10 digits' : null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Enter a password';
    }
    return value.length < 8 ? 'Use at least 8 characters' : null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm your password';
    }
    return confirmPassword == password ? null : 'Passwords do not match';
  }

  SignUpErrors _withFieldError(SignUpField field, String? error) {
    return switch (field) {
      SignUpField.fullName => SignUpErrors(
        fullName: error,
        email: _errors.email,
        phone: _errors.phone,
        password: _errors.password,
        confirmPassword: _errors.confirmPassword,
      ),
      SignUpField.email => SignUpErrors(
        fullName: _errors.fullName,
        email: error,
        phone: _errors.phone,
        password: _errors.password,
        confirmPassword: _errors.confirmPassword,
      ),
      SignUpField.phone => SignUpErrors(
        fullName: _errors.fullName,
        email: _errors.email,
        phone: error,
        password: _errors.password,
        confirmPassword: _errors.confirmPassword,
      ),
      SignUpField.password => SignUpErrors(
        fullName: _errors.fullName,
        email: _errors.email,
        phone: _errors.phone,
        password: error,
        confirmPassword: _errors.confirmPassword,
      ),
      SignUpField.confirmPassword => SignUpErrors(
        fullName: _errors.fullName,
        email: _errors.email,
        phone: _errors.phone,
        password: _errors.password,
        confirmPassword: error,
      ),
    };
  }

  String _phoneDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
