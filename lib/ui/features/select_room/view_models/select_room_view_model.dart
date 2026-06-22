import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:flutter/foundation.dart';

class SelectRoomViewModel extends ChangeNotifier {
  SelectRoomViewModel({
    required this.nights,
    required BookingRepository bookingRepository,
  }) : _bookingRepository = bookingRepository;

  final int nights;
  final BookingRepository _bookingRepository;

  String? _selectedRoomId;
  RoomOptionData? _selectedRoom;
  int _selectedNightlyPrice = 0;
  bool _isFavorite = false;
  bool _isCreatingDraft = false;
  String? _errorMessage;
  BookingDraft? _draft;

  String? get selectedRoomId => _selectedRoomId;
  RoomOptionData? get selectedRoom => _selectedRoom;
  bool get isFavorite => _isFavorite;
  bool get isCreatingDraft => _isCreatingDraft;
  String? get errorMessage => _errorMessage;
  BookingDraft? get draft => _draft;
  int get totalPrice => _selectedNightlyPrice * nights;
  bool get canContinue => _selectedRoomId != null && !_isCreatingDraft;

  void selectRoom(RoomOptionData room) {
    if (_selectedRoomId == room.id) {
      return;
    }
    _selectedRoomId = room.id;
    _selectedRoom = room;
    _selectedNightlyPrice = room.pricePerNight;
    _errorMessage = null;
    _draft = null;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedRoomId == null && _selectedNightlyPrice == 0) {
      return;
    }
    _selectedRoomId = null;
    _selectedRoom = null;
    _selectedNightlyPrice = 0;
    notifyListeners();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  Future<bool> createDraft(SelectRoomData data) async {
    if (_isCreatingDraft) {
      return false;
    }

    final roomId = _selectedRoomId;
    if (roomId == null) {
      _errorMessage = 'Select a room before continuing.';
      notifyListeners();
      return false;
    }

    _isCreatingDraft = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _draft = await _bookingRepository.createDraft(
        CreateBookingDraftCommand(
          propertyId: data.propertyId,
          roomId: roomId,
          checkIn: data.checkIn,
          checkOut: data.checkOut,
          adults: data.adults,
          children: data.children,
          roomQuantity: data.roomQuantity,
          addOns: const [],
          note: null,
        ),
      );
      _isCreatingDraft = false;
      notifyListeners();
      return true;
    } on BookingRepositoryException catch (error) {
      _errorMessage = error.message;
      _isCreatingDraft = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create booking draft.';
      _isCreatingDraft = false;
      notifyListeners();
      return false;
    }
  }
}
