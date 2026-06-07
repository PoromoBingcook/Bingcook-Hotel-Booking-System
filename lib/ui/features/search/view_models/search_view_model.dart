import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  static const availableAmenities = [
    'Self check-in',
    'Wi-Fi',
    'Pool',
    'Parking',
    'AC',
    'Breakfast',
    'Pet allowed',
  ];

  String _destination = 'Da Nang';
  DateTime _checkIn = DateTime(2023, 6, 12);
  DateTime? _checkOut = DateTime(2023, 6, 15);
  int _adults = 2;
  int _children = 0;
  final Set<String> _selectedAmenities = {'Self check-in'};

  String get destination => _destination;
  DateTime get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  int get adults => _adults;
  int get children => _children;
  Set<String> get selectedAmenities => Set.unmodifiable(_selectedAmenities);

  void clearDestination() {
    if (_destination.isEmpty) {
      return;
    }
    _destination = '';
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_checkOut != null) {
      _checkIn = normalizedDate;
      _checkOut = null;
    } else if (normalizedDate.isAfter(_checkIn)) {
      _checkOut = normalizedDate;
    } else {
      _checkIn = normalizedDate;
    }

    notifyListeners();
  }

  void incrementAdults() {
    _adults++;
    notifyListeners();
  }

  void decrementAdults() {
    if (_adults == 1) {
      return;
    }
    _adults--;
    notifyListeners();
  }

  void incrementChildren() {
    _children++;
    notifyListeners();
  }

  void decrementChildren() {
    if (_children == 0) {
      return;
    }
    _children--;
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }
}
