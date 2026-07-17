import 'package:bingcook/ui/features/property_details/widgets/property_booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens date editor and exposes guest controls', (tester) async {
    var incremented = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyBookingCard(
            checkIn: DateTime(2026, 8, 10),
            checkOut: DateTime(2026, 8, 13),
            guests: 2,
            canBook: true,
            onDatesChanged: (_) {},
            onIncrementGuests: () => incremented = true,
            onDecrementGuests: () {},
            onBookNow: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('property_guests_increment_button')));
    expect(incremented, isTrue);

    await tester.tap(find.byKey(const Key('property_edit_dates_button')));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });
}
