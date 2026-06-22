import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/features/select_room/view_models/select_room_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SelectRoomViewModel', () {
    test('creates draft for selected room', () async {
      final repository = FakeBookingRepository();
      final viewModel = SelectRoomViewModel(
        nights: 3,
        bookingRepository: repository,
      );

      viewModel.selectRoom(_room);
      final result = await viewModel.createDraft(_data);

      expect(result, isTrue);
      expect(repository.lastDraftCommand?.propertyId, _data.propertyId);
      expect(repository.lastDraftCommand?.roomId, _room.id);
      expect(viewModel.draft?.bookingId, 'booking-id');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isCreatingDraft, isFalse);
    });

    test('shows safe error when no room selected', () async {
      final viewModel = SelectRoomViewModel(
        nights: 3,
        bookingRepository: FakeBookingRepository(),
      );

      final result = await viewModel.createDraft(_data);

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'Select a room before continuing.');
    });
  });
}

final _data = SelectRoomData(
  propertyId: 'property-id',
  propertyName: 'Ocean Pearl Hotel',
  propertyImageAsset: AppAssets.propertyDetails,
  dateRange: 'Jul 10 - Jul 13',
  checkIn: DateTime(2026, 7, 10),
  checkOut: DateTime(2026, 7, 13),
  adults: 2,
  children: 1,
  roomQuantity: 1,
  guests: 3,
  nights: 3,
  rooms: [_room],
);

const _room = RoomOptionData(
  id: 'room-id',
  imageAsset: AppAssets.deluxeOceanView,
  name: 'Deluxe Ocean View',
  maxGuests: 3,
  pricePerNight: 100,
  features: ['AC'],
  policy: 'Instant Booking',
  policyPositive: true,
);

class FakeBookingRepository implements BookingRepository {
  CreateBookingDraftCommand? lastDraftCommand;

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) async {
    lastDraftCommand = command;
    return BookingDraft(
      bookingId: 'booking-id',
      propertyId: command.propertyId,
      propertyName: 'Ocean Pearl Hotel',
      roomId: command.roomId,
      roomName: 'Deluxe Ocean View',
      roomType: 'Deluxe',
      checkIn: command.checkIn,
      checkOut: command.checkOut,
      nights: 3,
      adults: command.adults,
      children: command.children,
      totalGuests: command.adults + command.children,
      roomQuantity: command.roomQuantity,
      maxGuests: 3,
      availableRooms: 4,
      roomSubtotal: 300,
      addOnSubtotal: 0,
      totalPrice: 300,
      addOns: const [],
      note: command.note,
      nextAction: 'ProceedToConfirmationPayment',
    );
  }

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) {
    throw UnimplementedError();
  }
}
