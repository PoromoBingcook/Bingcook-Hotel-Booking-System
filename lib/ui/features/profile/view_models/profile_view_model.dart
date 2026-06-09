import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  bool _isLoggingOut = false;
  String? _errorMessage;

  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;

  String get displayName {
    final name = _authRepository.currentSession?.user.fullName.trim();
    return name == null || name.isEmpty ? 'BingCook guest' : name;
  }

  String get email {
    final email = _authRepository.currentSession?.user.email?.trim();
    return email == null || email.isEmpty ? 'No email added' : email;
  }

  String get membershipLabel => 'BingCook Cấp 1';

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
