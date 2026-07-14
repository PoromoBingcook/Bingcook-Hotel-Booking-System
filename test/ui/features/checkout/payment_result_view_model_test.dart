import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/checkout/view_models/payment_result_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores non-BingCook navigation', () async {
    final repository = _BookingRepository();
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: repository,
      delay: (_) async {},
    );

    expect(
      await viewModel.handlePageFinished('https://pay.payos.vn/web/1'),
      isFalse,
    );
    expect(repository.statusCalls, 0);
  });

  test('confirms paid return exactly once', () async {
    final repository = _BookingRepository(statuses: [_paidStatus]);
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: repository,
      delay: (_) async {},
    );

    const returnUrl =
        'https://bingcook-api.mascoteach.com/api/payments/payos/return?orderCode=1';
    expect(await viewModel.handlePageFinished(returnUrl), isTrue);
    expect(await viewModel.handlePageFinished(returnUrl), isFalse);
    expect(viewModel.state, PaymentResultState.confirmed);
    expect(repository.statusCalls, 1);
  });

  test('retries pending status before confirming paid result', () async {
    final repository = _BookingRepository(
      statuses: [_pendingStatus, _pendingStatus, _paidStatus],
    );
    var delayCalls = 0;
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: repository,
      delay: (_) async => delayCalls++,
    );

    expect(
      await viewModel.handlePageFinished(
        'http://10.0.2.2:5115/api/payments/payos/return?orderCode=1',
      ),
      isTrue,
    );
    expect(repository.statusCalls, 3);
    expect(delayCalls, 2);
  });

  test('leaves pending result retryable after bounded attempts', () async {
    final repository = _BookingRepository(
      statuses: [_pendingStatus, _pendingStatus, _pendingStatus, _paidStatus],
    );
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: repository,
      delay: (_) async {},
    );

    expect(await viewModel.checkStatus(), isFalse);
    expect(viewModel.state, PaymentResultState.waiting);
    expect(await viewModel.checkStatus(maxAttempts: 1), isTrue);
    expect(viewModel.state, PaymentResultState.confirmed);
  });

  test('maps canceled and repository failure to non-success states', () async {
    final canceledViewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: _BookingRepository(statuses: [_canceledStatus]),
      delay: (_) async {},
    );
    expect(await canceledViewModel.checkStatus(), isFalse);
    expect(canceledViewModel.state, PaymentResultState.canceled);

    final errorViewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: _BookingRepository(error: 'Network unavailable.'),
      delay: (_) async {},
    );
    expect(await errorViewModel.checkStatus(), isFalse);
    expect(errorViewModel.state, PaymentResultState.error);
    expect(errorViewModel.errorMessage, 'Network unavailable.');
  });

  test('counts down to expiry and cancels its timer on dispose', () {
    var now = DateTime.utc(2026, 7, 14, 3);
    void Function(Timer)? tick;
    final timer = _Timer();
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-1',
      bookingRepository: _BookingRepository(),
      expiresAt: DateTime.utc(2026, 7, 14, 3, 0, 2),
      now: () => now,
      timerFactory: (_, callback) {
        tick = callback;
        return timer;
      },
    );

    expect(viewModel.formattedRemaining, '00:02');
    now = DateTime.utc(2026, 7, 14, 3, 0, 1);
    tick!(timer);
    expect(viewModel.formattedRemaining, '00:01');

    now = DateTime.utc(2026, 7, 14, 3, 0, 2);
    tick!(timer);
    expect(viewModel.formattedRemaining, '00:00');
    expect(viewModel.state, PaymentResultState.expired);
    expect(timer.isActive, isFalse);

    viewModel.dispose();
    expect(timer.cancelCalls, 2);
  });
}

class _Timer implements Timer {
  var cancelCalls = 0;
  var _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  int get tick => 0;

  @override
  void cancel() {
    cancelCalls++;
    _isActive = false;
  }
}

const _paidStatus = BookingPaymentStatus(
  bookingId: 'booking-1',
  bookingStatus: 'Paid',
  paymentMethod: 'PayOS',
  paymentStatus: 'Success',
  amount: 5000,
  transactionCode: '1',
  paidAt: null,
  updatedAt: null,
);

const _pendingStatus = BookingPaymentStatus(
  bookingId: 'booking-1',
  bookingStatus: 'PendingPayment',
  paymentMethod: 'PayOS',
  paymentStatus: 'Pending',
  amount: 5000,
  transactionCode: '1',
  paidAt: null,
  updatedAt: null,
);

const _canceledStatus = BookingPaymentStatus(
  bookingId: 'booking-1',
  bookingStatus: 'Cancelled',
  paymentMethod: 'PayOS',
  paymentStatus: 'Cancelled',
  amount: 5000,
  transactionCode: '1',
  paidAt: null,
  updatedAt: null,
);

class _BookingRepository implements BookingRepository {
  _BookingRepository({List<BookingPaymentStatus>? statuses, this.error})
    : _statuses = statuses ?? const [];

  final List<BookingPaymentStatus> _statuses;
  final String? error;
  int statusCalls = 0;

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) async {
    statusCalls++;
    if (error case final message?) {
      throw BookingRepositoryException(message);
    }
    return _statuses[statusCalls - 1];
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) =>
      throw UnimplementedError();

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) =>
      throw UnimplementedError();

  @override
  Future<List<BookingReservation>> fetchReservations() =>
      throw UnimplementedError();
}
