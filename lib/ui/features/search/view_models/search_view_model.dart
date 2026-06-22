import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({DateTime? now}) {
    final baseDate = _normalize(
      now ?? DateTime.now(),
    ).add(const Duration(days: 1));
    _checkIn = baseDate;
    _checkOut = baseDate.add(const Duration(days: 3));
  }

  static const availableAmenities = [
    'Self check-in',
    'Wi-Fi',
    'Pool',
    'Parking',
    'AC',
    'Breakfast',
    'Pet allowed',
  ];

  static const availableTypes = [
    'All',
    'Hotel',
    'Motel',
    'Homestay',
    'Resort',
    'Apartment',
  ];

  static const availableRatings = [0.0, 4.0, 4.5];
  static const minAllowedPrice = 0.0;
  static const maxAllowedPrice = 500.0;

  String _destination = 'Da Nang';
  late DateTime _checkIn;
  DateTime? _checkOut;
  int _adults = 2;
  int _children = 0;
  String _selectedType = 'All';
  double _minPrice = minAllowedPrice;
  double _maxPrice = maxAllowedPrice;
  double _minRating = 0;
  final Set<String> _selectedAmenities = {'Self check-in'};

  String get destination => _destination;
  DateTime get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  int get adults => _adults;
  int get children => _children;
  int get guests => _adults + _children;
  String get selectedType => _selectedType;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  double get minRating => _minRating;
  Set<String> get selectedAmenities => Set.unmodifiable(_selectedAmenities);

  void updateDestination(String value) {
    if (_destination == value) {
      return;
    }
    _destination = value;
    notifyListeners();
  }

  void clearDestination() {
    if (_destination.isEmpty) {
      return;
    }
    _destination = '';
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final normalizedDate = _normalize(date);

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

  void setType(String type) {
    if (_selectedType == type) {
      return;
    }
    _selectedType = type;
    notifyListeners();
  }

  void setPriceRange(double minPrice, double maxPrice) {
    final normalizedMin = minPrice.clamp(minAllowedPrice, maxAllowedPrice);
    final normalizedMax = maxPrice.clamp(normalizedMin, maxAllowedPrice);
    if (_minPrice == normalizedMin && _maxPrice == normalizedMax) {
      return;
    }
    _minPrice = normalizedMin;
    _maxPrice = normalizedMax;
    notifyListeners();
  }

  void setMinRating(double rating) {
    if (_minRating == rating) {
      return;
    }
    _minRating = rating;
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

  ProductSearchQuery buildQuery() {
    final trimmedDestination = _destination.trim();
    return ProductSearchQuery(
      keyword: trimmedDestination.isEmpty ? null : trimmedDestination,
      location: trimmedDestination.isEmpty ? null : trimmedDestination,
      checkIn: _checkIn,
      checkOut: _checkOut,
      guests: guests,
      minPrice: _minPrice > minAllowedPrice ? _minPrice : null,
      maxPrice: _maxPrice < maxAllowedPrice ? _maxPrice : null,
      amenities: _selectedAmenities.toList(growable: false)..sort(),
      minRating: _minRating > 0 ? _minRating : null,
      type: _selectedType == 'All' ? null : _selectedType,
    );
  }

  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
