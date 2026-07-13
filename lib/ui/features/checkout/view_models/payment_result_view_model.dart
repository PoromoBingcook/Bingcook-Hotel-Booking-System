import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:flutter/foundation.dart';

enum PaymentResultState {
  waiting,
  checking,
  confirmed,
  canceled,
  expired,
  failed,
  error,
}

typedef PaymentStatusDelay = Future<void> Function(Duration duration);

class PaymentResultViewModel extends ChangeNotifier {
  PaymentResultViewModel({
    required this.bookingId,
    required BookingRepository bookingRepository,
    PaymentStatusDelay? delay,
  }) : _bookingRepository = bookingRepository,
       _delay = delay ?? Future<void>.delayed;

  final String bookingId;
  final BookingRepository _bookingRepository;
  final PaymentStatusDelay _delay;

  PaymentResultState _state = PaymentResultState.waiting;
  String? _errorMessage;
  bool _isChecking = false;
  bool _completionDelivered = false;
  bool _isDisposed = false;

  PaymentResultState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isChecking => _isChecking;
  bool get canRetry =>
      !_isChecking &&
      (_state == PaymentResultState.waiting ||
          _state == PaymentResultState.error);

  Future<bool> handlePageFinished(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !_isPayOSCallbackPath(uri.path)) {
      return false;
    }
    return checkStatus();
  }

  Future<bool> checkStatus({int maxAttempts = 3}) async {
    if (_isChecking || _completionDelivered || maxAttempts <= 0) {
      return false;
    }
    if (_state
        case PaymentResultState.canceled ||
            PaymentResultState.expired ||
            PaymentResultState.failed) {
      return false;
    }

    _isChecking = true;
    _state = PaymentResultState.checking;
    _errorMessage = null;
    _notify();

    try {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final status = await _bookingRepository.fetchStatus(bookingId);
        if (status.isPaid) {
          _state = PaymentResultState.confirmed;
          _completionDelivered = true;
          return true;
        }

        final terminalState = _terminalState(status);
        if (terminalState != null) {
          _state = terminalState;
          return false;
        }

        if (attempt < maxAttempts - 1) {
          await _delay(const Duration(seconds: 1));
        }
      }

      _state = PaymentResultState.waiting;
      return false;
    } on BookingRepositoryException catch (error) {
      _state = PaymentResultState.error;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _state = PaymentResultState.error;
      _errorMessage = 'Unable to confirm payment status.';
      return false;
    } finally {
      _isChecking = false;
      _notify();
    }
  }

  bool _isPayOSCallbackPath(String path) {
    return path.endsWith('/api/payments/payos/return') ||
        path.endsWith('/api/payments/payos/cancel');
  }

  PaymentResultState? _terminalState(BookingPaymentStatus status) {
    final bookingStatus = status.bookingStatus.toLowerCase();
    final paymentStatus = status.paymentStatus?.toLowerCase();
    if (bookingStatus == 'cancelled' ||
        bookingStatus == 'canceled' ||
        paymentStatus == 'cancelled' ||
        paymentStatus == 'canceled') {
      return PaymentResultState.canceled;
    }
    if (bookingStatus == 'expired' || paymentStatus == 'expired') {
      return PaymentResultState.expired;
    }
    if (paymentStatus == 'failed') {
      return PaymentResultState.failed;
    }
    return null;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
