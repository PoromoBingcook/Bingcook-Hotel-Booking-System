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
  static const availableCities = [
    'Hà Nội',
    'Hải Phòng',
    'Huế',
    'Đà Nẵng',
    'Thành phố Hồ Chí Minh',
    'Cần Thơ',
    'Đồng Nai',
  ];
  static const minAllowedPrice = 0.0;
  static const maxAllowedPrice = 5000000.0;

  String _destination = '';
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
  List<String> get citySuggestions {
    final input = _foldVietnamese(_destination.trim());
    if (input.isEmpty) return const [];
    if (availableCities.any((city) => _foldVietnamese(city) == input)) {
      return const [];
    }
    return availableCities
        .where((city) => _foldVietnamese(city).contains(input))
        .toList(growable: false);
  }

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
    final location = _canonicalLocation(trimmedDestination);
    return ProductSearchQuery(
      keyword: trimmedDestination.isEmpty || location != null
          ? null
          : _foldVietnamese(trimmedDestination),
      location: location,
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

  static String? _canonicalLocation(String value) {
    final normalized = _foldVietnamese(value.trim());
    return switch (normalized) {
      'ha noi' || 'hanoi' => 'Ha Noi',
      'hai phong' => 'Hai Phong',
      'hue' => 'Hue',
      'da nang' || 'danang' => 'Da Nang',
      'thanh pho ho chi minh' ||
      'ho chi minh' ||
      'ho chi minh city' ||
      'hcm' ||
      'tp hcm' ||
      'tp. hcm' ||
      'sai gon' ||
      'saigon' => 'Ho Chi Minh',
      'can tho' => 'Can Tho',
      'dong nai' => 'Dong Nai',
      _ => null,
    };
  }

  static String _foldVietnamese(String value) {
    var folded = value.toLowerCase();
    const replacements = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    for (final entry in replacements.entries) {
      for (final character in entry.value.split('')) {
        folded = folded.replaceAll(character, entry.key);
      }
    }
    return folded;
  }
}
