import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:flutter/foundation.dart';

class SelectRoomViewModel extends ChangeNotifier {
  SelectRoomViewModel({required this.nights});

  final int nights;

  String? _selectedRoomId;
  int _selectedNightlyPrice = 0;
  bool _isFavorite = false;

  String? get selectedRoomId => _selectedRoomId;
  bool get isFavorite => _isFavorite;
  int get totalPrice => _selectedNightlyPrice * nights;

  void selectRoom(RoomOptionData room) {
    if (_selectedRoomId == room.id) {
      return;
    }
    _selectedRoomId = room.id;
    _selectedNightlyPrice = room.pricePerNight;
    notifyListeners();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
