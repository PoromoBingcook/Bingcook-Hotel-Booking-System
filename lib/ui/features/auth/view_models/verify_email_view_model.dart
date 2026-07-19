import 'package:flutter/foundation.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  VerifyEmailViewModel({EmailVerificationAuthRepository? authRepository})
    : _authRepository = authRepository;

  final EmailVerificationAuthRepository? _authRepository;
  String _otp = '';
  String? _message;
  bool _isVerified = false;
  bool _isSubmitting = false;

  String get otp => _otp;
  String? get message => _message;
  bool get isVerified => _isVerified;
  bool get isSubmitting => _isSubmitting;
  bool get canVerify => _otp.length == 6;

  void updateOtp(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    _otp = digitsOnly.length > 6 ? digitsOnly.substring(0, 6) : digitsOnly;
    _message = null;
    _isVerified = false;
    notifyListeners();
  }

  Future<bool> verify({required String email}) async {
    if (_isSubmitting) {
      return false;
    }

    if (!canVerify) {
      _message = 'Enter the 6-digit verification code';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository?.verifyEmailOtp(email: email, otp: _otp);
      _isVerified = true;
      _message = 'OTP successfully verified';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on AuthRepositoryException catch (error) {
      _message = error.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      _message = 'Unable to verify OTP. Try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> resend({required String email}) async {
    if (_isSubmitting) {
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository?.resendEmailOtp(email: email);
      _message = 'A new OTP has been sent to your email';
    } on AuthRepositoryException catch (error) {
      _message = error.message;
    } catch (_) {
      _message = 'Unable to resend OTP. Try again.';
    }

    _isSubmitting = false;
    notifyListeners();
  }
}
