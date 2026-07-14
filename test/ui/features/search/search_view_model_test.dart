import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchViewModel', () {
    test('starts with deterministic Figma values', () {
      final viewModel = _newViewModel();

      expect(viewModel.destination, isEmpty);
      expect(viewModel.checkIn, DateTime(2023, 6, 12));
      expect(viewModel.checkOut, DateTime(2023, 6, 15));
      expect(viewModel.adults, 2);
      expect(viewModel.children, 0);
      expect(viewModel.selectedAmenities, {'Self check-in'});
    });

    test('clears destination', () {
      final viewModel = _newViewModel();

      viewModel.clearDestination();

      expect(viewModel.destination, isEmpty);
    });

    test('filters Vietnamese cities without requiring accents', () {
      final viewModel = _newViewModel()..updateDestination('ho chi');

      expect(viewModel.citySuggestions, ['Thành phố Hồ Chí Minh']);

      viewModel.updateDestination('hai');
      expect(viewModel.citySuggestions, ['Hải Phòng']);
    });

    test('starts a new range after a complete range', () {
      final viewModel = _newViewModel();

      viewModel.selectDate(DateTime(2023, 6, 18));

      expect(viewModel.checkIn, DateTime(2023, 6, 18));
      expect(viewModel.checkOut, isNull);
    });

    test('completes an open range with a later date', () {
      final viewModel = _newViewModel()
        ..selectDate(DateTime(2023, 6, 18))
        ..selectDate(DateTime(2023, 6, 21));

      expect(viewModel.checkIn, DateTime(2023, 6, 18));
      expect(viewModel.checkOut, DateTime(2023, 6, 21));
    });

    test('replaces check-in when open range receives an earlier date', () {
      final viewModel = _newViewModel()
        ..selectDate(DateTime(2023, 6, 18))
        ..selectDate(DateTime(2023, 6, 16));

      expect(viewModel.checkIn, DateTime(2023, 6, 16));
      expect(viewModel.checkOut, isNull);
    });

    test('guest counters respect minimums and increment independently', () {
      final viewModel = _newViewModel();

      viewModel.decrementAdults();
      viewModel.decrementAdults();
      viewModel.decrementChildren();
      viewModel.incrementAdults();
      viewModel.incrementChildren();

      expect(viewModel.adults, 2);
      expect(viewModel.children, 1);
    });

    test('toggles amenities independently', () {
      final viewModel = _newViewModel();

      viewModel.toggleAmenity('Wi-Fi');
      viewModel.toggleAmenity('Self check-in');

      expect(viewModel.selectedAmenities, {'Wi-Fi'});
    });

    test('builds backend search and filter parameters', () {
      final viewModel = _newViewModel()
        ..updateDestination('Ocean Pearl')
        ..setType('Hotel')
        ..setPriceRange(500000, 2000000)
        ..setMinRating(4.5)
        ..toggleAmenity('Wi-Fi');

      final query = viewModel.buildQuery();

      expect(query.keyword, 'ocean pearl');
      expect(query.location, isNull);
      expect(query.type, 'Hotel');
      expect(query.minPrice, 500000);
      expect(query.maxPrice, 2000000);
      expect(query.minRating, 4.5);
      expect(query.amenities, ['Self check-in', 'Wi-Fi']);
      expect(query.guests, 2);
    });

    test('builds city destinations as location parameters', () {
      final viewModel = _newViewModel()
        ..updateDestination('Thành phố Hồ Chí Minh');

      final query = viewModel.buildQuery();

      expect(query.keyword, isNull);
      expect(query.location, 'Ho Chi Minh');
    });

    test('maps common Ho Chi Minh aliases to the same location', () {
      final aliases = ['Hồ Chí Minh', 'Ho Chi Minh City', 'HCM', 'Sài Gòn'];

      for (final alias in aliases) {
        final query = (_newViewModel()..updateDestination(alias)).buildQuery();

        expect(query.keyword, isNull, reason: alias);
        expect(query.location, 'Ho Chi Minh', reason: alias);
      }
    });
  });
}

SearchViewModel _newViewModel() {
  return SearchViewModel(now: DateTime(2023, 6, 11));
}
