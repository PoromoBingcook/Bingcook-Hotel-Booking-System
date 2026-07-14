import 'package:bingcook/domain/models/product.dart';

abstract interface class SavedPropertyRepository {
  Future<List<Product>> fetchSavedProperties();

  Future<void> saveProperty(String propertyId);

  Future<void> removeProperty(String propertyId);
}

class SavedPropertyRepositoryException implements Exception {
  const SavedPropertyRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
