import 'package:bingcook/ui/features/auth/view_models/verify_email_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerifyEmailViewModel', () {
    test('tracks a six digit code as verifiable', () {
      final viewModel = VerifyEmailViewModel();

      viewModel.updateOtp('123456');

      expect(viewModel.otp, '123456');
      expect(viewModel.canVerify, isTrue);
    });

    test('rejects incomplete codes', () async {
      final viewModel = VerifyEmailViewModel();

      final result = await viewModel.verify(email: 'jane@example.com');

      expect(result, isFalse);
      expect(viewModel.message, 'Enter the 6-digit verification code');
      expect(viewModel.isVerified, isFalse);
    });

    test('verifies complete codes', () async {
      final viewModel = VerifyEmailViewModel()..updateOtp('123456');

      final result = await viewModel.verify(email: 'jane@example.com');

      expect(result, isTrue);
      expect(viewModel.message, 'OTP successfully verified');
      expect(viewModel.isVerified, isTrue);
    });
  });
}
