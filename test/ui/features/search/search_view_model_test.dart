import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchViewModel', () {
    test('starts with deterministic Figma values', () {
      final viewModel = _newViewModel();

      expect(viewModel.destination, 'Da Nang');
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
  });
}

SearchViewModel _newViewModel() {
  return SearchViewModel(now: DateTime(2023, 6, 11));
}
