import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUpViewModel', () {
    test('toggles password visibility', () {
      final viewModel = SignUpViewModel();

      expect(viewModel.isPasswordVisible, isFalse);

      viewModel.togglePasswordVisibility();

      expect(viewModel.isPasswordVisible, isTrue);
    });

    test('returns validation errors for empty values', () {
      final viewModel = SignUpViewModel();

      final errors = viewModel.validate(
        fullName: '',
        email: '',
        phone: '',
        password: '',
      );

      expect(errors.fullName, isNotNull);
      expect(errors.email, isNotNull);
      expect(errors.phone, isNotNull);
      expect(errors.password, isNotNull);
    });
  });
}
