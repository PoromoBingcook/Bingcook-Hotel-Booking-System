import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  bool _isLoggingOut = false;
  bool _isSavingProfile = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoggingOut => _isLoggingOut;
  bool get isSavingProfile => _isSavingProfile;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get fullNameValue =>
      _authRepository.currentSession?.user.fullName ?? '';
  String get phoneValue => _authRepository.currentSession?.user.phone ?? '';

  String get displayName {
    final name = _authRepository.currentSession?.user.fullName.trim();
    return name == null || name.isEmpty ? 'BingCook guest' : name;
  }

  String get email {
    final email = _authRepository.currentSession?.user.email?.trim();
    return email == null || email.isEmpty ? 'No email added' : email;
  }

  String get phone {
    final phone = _authRepository.currentSession?.user.phone?.trim();
    return phone == null || phone.isEmpty ? 'Not added' : phone;
  }

  String get roleLabel {
    final role = _authRepository.currentSession?.user.role.trim();
    return role == null || role.isEmpty ? 'BingCook user' : role;
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    if (_isSavingProfile) return false;
    final normalizedName = fullName.trim();
    final normalizedPhone = phone.trim();
    if (normalizedName.isEmpty || normalizedName.length > 100) {
      _setProfileError(
        'Full name is required and cannot exceed 100 characters.',
      );
      return false;
    }
    if (normalizedPhone.isNotEmpty &&
        !RegExp(r'^\+?\d{6,20}$').hasMatch(normalizedPhone)) {
      _setProfileError('Phone must contain 6 to 20 digits.');
      return false;
    }
    final editableRepository = _authRepository is EditableProfileAuthRepository
        ? _authRepository as EditableProfileAuthRepository
        : null;
    if (editableRepository == null) {
      _setProfileError('Profile update is unavailable.');
      return false;
    }

    _isSavingProfile = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await editableRepository.updateProfile(
        fullName: normalizedName,
        phone: normalizedPhone.isEmpty ? null : normalizedPhone,
      );
      _successMessage = 'Personal information updated.';
      _isSavingProfile = false;
      notifyListeners();
      return true;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to update personal information.';
    }
    _isSavingProfile = false;
    notifyListeners();
    return false;
  }

  void _setProfileError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.logout();
      _isLoggingOut = false;
      notifyListeners();
      return true;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
      _isLoggingOut = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unable to logout.';
      _isLoggingOut = false;
      notifyListeners();
      return false;
    }
  }
}
