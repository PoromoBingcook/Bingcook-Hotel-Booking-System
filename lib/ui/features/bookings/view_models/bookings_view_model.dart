import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:flutter/foundation.dart';

enum BookingListTab { active, past, canceled }

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel({
    required BookingRepository bookingRepository,
    DateTime Function()? now,
  }) : _bookingRepository = bookingRepository,
       _now = now ?? DateTime.now;

  final BookingRepository _bookingRepository;
  final DateTime Function() _now;
  List<BookingReservation> _reservations = const [];
  BookingListTab _selectedTab = BookingListTab.active;
  bool _isLoading = false;
  String? _errorMessage;
  String? _cancellingBookingId;
  String? _successMessage;
  String? _actionErrorMessage;

  BookingListTab get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get cancellingBookingId => _cancellingBookingId;
  String? get successMessage => _successMessage;
  String? get actionErrorMessage => _actionErrorMessage;

  List<BookingReservation> get visibleReservations {
    final category = switch (_selectedTab) {
      BookingListTab.active => BookingCategory.active,
      BookingListTab.past => BookingCategory.past,
      BookingListTab.canceled => BookingCategory.canceled,
    };
    return _reservations
        .where((reservation) => reservation.categoryAt(_now()) == category)
        .toList(growable: false);
  }

  bool canCancel(BookingReservation reservation) {
    return reservation.categoryAt(_now()) == BookingCategory.active &&
        reservation.canCancelAt(_now());
  }

  Future<void> load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reservations = await _bookingRepository.fetchReservations();
    } on BookingRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your reservations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancel(BookingReservation reservation) async {
    if (_cancellingBookingId != null) {
      return false;
    }
    if (!canCancel(reservation)) {
      _actionErrorMessage =
          'Bookings must be cancelled at least 24 hours before check-in.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _cancellingBookingId = reservation.bookingId;
    _successMessage = null;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final result = await _bookingRepository.cancel(reservation.bookingId);
      _successMessage = result.message.isEmpty
          ? 'Booking cancelled.'
          : result.message;
      try {
        _reservations = await _bookingRepository.fetchReservations();
      } catch (_) {
        _actionErrorMessage =
            'Booking cancelled, but reservations could not be refreshed.';
      }
      return true;
    } on BookingRepositoryException catch (error) {
      _actionErrorMessage = error.message;
      return false;
    } catch (_) {
      _actionErrorMessage = 'Unable to cancel this reservation.';
      return false;
    } finally {
      _cancellingBookingId = null;
      notifyListeners();
    }
  }

  void selectTab(BookingListTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }
}
