import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';
import 'package:bingcook/ui/features/saved/view_models/saved_stays_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads saved properties and exposes their ids', () async {
    final repository = FakeSavedPropertyRepository([_product]);
    final viewModel = SavedStaysViewModel(savedPropertyRepository: repository);

    await viewModel.load();

    expect(viewModel.stays.single.name, 'Ocean Pearl Hotel');
    expect(viewModel.isSaved(_product.id), isTrue);
    expect(viewModel.errorMessage, isNull);
  });

  test('toggle saves and removes the same property', () async {
    final repository = FakeSavedPropertyRepository([]);
    final viewModel = SavedStaysViewModel(savedPropertyRepository: repository);
    await viewModel.load();

    expect(await viewModel.toggle(_product.id), isTrue);
    expect(repository.savedProducts, [_product]);
    expect(viewModel.isSaved(_product.id), isTrue);

    expect(await viewModel.toggle(_product.id), isTrue);
    expect(repository.savedProducts, isEmpty);
    expect(viewModel.isSaved(_product.id), isFalse);
  });

  test('toggle restores state when remove fails', () async {
    final repository = FakeSavedPropertyRepository([
      _product,
    ], failRemove: true);
    final viewModel = SavedStaysViewModel(savedPropertyRepository: repository);
    await viewModel.load();

    expect(await viewModel.toggle(_product.id), isFalse);
    expect(viewModel.isSaved(_product.id), isTrue);
    expect(viewModel.stays, hasLength(1));
    expect(viewModel.errorMessage, 'Unable to remove this stay.');
  });
}

const _product = Product(
  id: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
  type: 'Hotel',
  name: 'Ocean Pearl Hotel',
  description: 'Beachfront hotel.',
  location: 'Da Nang, Son Tra',
  city: 'Da Nang',
  address: 'Son Tra',
  imageUrl: null,
  rating: 4.7,
  reviewCount: 3,
  amenities: ['Wi-Fi'],
  pricePerNight: 680000,
  status: 'Available',
  isAvailable: true,
);

class FakeSavedPropertyRepository implements SavedPropertyRepository {
  FakeSavedPropertyRepository(List<Product> products, {this.failRemove = false})
    : savedProducts = List.of(products);

  final List<Product> savedProducts;
  final bool failRemove;

  @override
  Future<List<Product>> fetchSavedProperties() async => List.of(savedProducts);

  @override
  Future<void> removeProperty(String propertyId) async {
    if (failRemove) {
      throw const SavedPropertyRepositoryException(
        'Unable to remove this stay.',
      );
    }
    savedProducts.removeWhere((product) => product.id == propertyId);
  }

  @override
  Future<void> saveProperty(String propertyId) async {
    if (savedProducts.every((product) => product.id != propertyId)) {
      savedProducts.add(_product);
    }
  }
}
