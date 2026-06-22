class ProductSearchQuery {
  const ProductSearchQuery({
    this.keyword,
    this.location,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.minPrice,
    this.maxPrice,
    this.amenities = const [],
    this.minRating,
    this.type,
  });

  final String? keyword;
  final String? location;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final double? minPrice;
  final double? maxPrice;
  final List<String> amenities;
  final double? minRating;
  final String? type;

  bool get isEmpty {
    return _isBlank(keyword) &&
        _isBlank(location) &&
        checkIn == null &&
        checkOut == null &&
        guests == null &&
        minPrice == null &&
        maxPrice == null &&
        amenities.isEmpty &&
        minRating == null &&
        _isBlank(type);
  }

  String get summary {
    final parts = <String>[];
    if (!_isBlank(location)) {
      parts.add(location!.trim());
    }
    if (checkIn != null && checkOut != null) {
      parts.add('${_formatMonthDay(checkIn!)} - ${_formatMonthDay(checkOut!)}');
    }
    if (guests != null && guests! > 0) {
      parts.add(guests == 1 ? '1 guest' : '$guests guests');
    }
    if (!_isBlank(type)) {
      parts.add(type!.trim());
    }
    return parts.isEmpty ? 'Location, dates, guests' : parts.join(' · ');
  }

  Map<String, String> toQueryParameters() {
    final parameters = <String, String>{};
    _addString(parameters, 'keyword', keyword);
    _addString(parameters, 'location', location);
    _addDate(parameters, 'checkIn', checkIn);
    _addDate(parameters, 'checkOut', checkOut);
    _addInt(parameters, 'guests', guests);
    _addDouble(parameters, 'minPrice', minPrice);
    _addDouble(parameters, 'maxPrice', maxPrice);
    if (amenities.isNotEmpty) {
      parameters['amenities'] = amenities.join(',');
    }
    _addDouble(parameters, 'minRating', minRating);
    _addString(parameters, 'type', type);
    return parameters;
  }

  static void _addString(
    Map<String, String> parameters,
    String key,
    String? value,
  ) {
    if (!_isBlank(value)) {
      parameters[key] = value!.trim();
    }
  }

  static void _addDate(
    Map<String, String> parameters,
    String key,
    DateTime? value,
  ) {
    if (value != null) {
      parameters[key] = _formatIsoDate(value);
    }
  }

  static void _addInt(Map<String, String> parameters, String key, int? value) {
    if (value != null && value > 0) {
      parameters[key] = '$value';
    }
  }

  static void _addDouble(
    Map<String, String> parameters,
    String key,
    double? value,
  ) {
    if (value != null && value >= 0) {
      parameters[key] = value.toStringAsFixed(
        value.truncateToDouble() == value ? 0 : 1,
      );
    }
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  static String _formatIsoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _formatMonthDay(DateTime value) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${names[value.month - 1]} ${value.day}';
  }
}
