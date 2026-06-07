import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('prefix icon stays aligned to the left', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            fieldKey: const Key('field'),
            iconKey: const Key('field_icon_alignment'),
            controller: controller,
            label: 'Email',
            hint: 'email@example.com',
            iconAsset: AppAssets.email,
          ),
        ),
      ),
    );

    final align = tester.widget<Align>(
      find.byKey(const Key('field_icon_alignment')),
    );

    expect(align.alignment, Alignment.centerLeft);
    expect(align.widthFactor, 1);
  });
}
