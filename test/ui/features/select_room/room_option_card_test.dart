import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/features/select_room/widgets/room_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the current room quantity in red', (tester) async {
    const room = RoomOptionData(
      id: 'room-1',
      imageAsset: AppAssets.deluxeOceanView,
      name: 'Deluxe Room',
      maxGuests: 2,
      availableRooms: 7,
      pricePerNight: 850000,
      features: ['AC'],
      policy: 'Instant Booking',
      policyPositive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoomOptionCard(room: room, selected: false, onSelected: () {}),
        ),
      ),
    );

    expect(find.text('We have 7 left'), findsOneWidget);
    expect(find.text('Instant Booking'), findsNothing);
    expect(
      tester.widget<Text>(find.text('We have 7 left')).style?.color,
      AppColors.error,
    );
  });
}
