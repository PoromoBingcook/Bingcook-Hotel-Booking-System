import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:flutter/foundation.dart';

enum BookingListTab { upcoming, past }

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel({required BookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  final BookingRepository _bookingRepository;
  List<BookingReservation> _reservations = const [];
  BookingListTab _selectedTab = BookingListTab.upcoming;
  bool _isLoading = false;
  String? _errorMessage;

  BookingListTab get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookingReservation> get visibleReservations {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _reservations
        .where((reservation) {
          final isPast =
              reservation.checkOut.isBefore(startOfToday) ||
              const {
                'cancelled',
                'expired',
              }.contains(reservation.bookingStatus.toLowerCase());
          return _selectedTab == BookingListTab.past ? isPast : !isPast;
        })
        .toList(growable: false);
  }

  Future<void> load() async {
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

  void selectTab(BookingListTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }
}
