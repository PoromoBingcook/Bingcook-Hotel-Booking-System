# Reservation Refresh and Cancellation Design

## Scope

This change completes two focused parts of the BingCook reservation-management
milestone:

1. Refresh My Reservations automatically when a customer closes an unpaid
   PayOS checkout.
2. Allow a paid or confirmed reservation to be canceled before the check-in
   calendar day begins in Vietnam time.

Refund processing remains outside this change. A successful payment stays
recorded as successful when its booking is canceled.

## Architecture

The implementation keeps the existing dependency direction:

`View -> ViewModel -> Repository -> Service`

- `MainShell` remains the navigation boundary and reacts to the payment-screen
  close event.
- `BookingsViewModel` remains the single owner of reservation loading and
  cancellation presentation state.
- `BookingReservation` owns the client-side cancellation eligibility rule.
- `BookingService` enforces the same rule on the backend.
- Existing booking repository and API contracts remain unchanged.

No periodic polling, new dependency, or new data-layer abstraction is needed.

## Unpaid PayOS Exit Flow

When the customer closes a generated PayOS checkout without paying:

1. Dispose the payment result ViewModel.
2. Clear the nested property, room-selection, checkout, and payment flow state.
3. Select the Active reservations tab and the Bookings destination.
4. Call `BookingsViewModel.load()` automatically.
5. Render the existing loading, success, or error state while that request
   completes.

This applies whether the payment was opened from a new booking or resumed from
My Reservations. The customer does not need to pull to refresh.

Payment confirmation and expiry keep their existing refresh behavior.

## Cancellation Rule

For `Confirmed` and `Paid` reservations, cancellation is allowed only while the
current Vietnam calendar date is earlier than the check-in date.

- Cancellation is allowed through 23:59:59 Vietnam time on the day before
  check-in.
- Cancellation is rejected from 00:00 Vietnam time on the check-in date.
- Pending PayOS cancellation keeps its existing hold-expiry behavior and PayOS
  link cancellation.
- Canceled and expired reservations cannot be canceled again.

The Flutter domain model controls button visibility. The backend service
independently enforces the same midnight boundary so stale or modified clients
cannot bypass it.

## Paid Booking Result

Canceling a paid reservation:

- changes the booking status to `Cancelled`;
- keeps the payment status as `Success`;
- releases the room from active availability;
- refreshes My Reservations after success;
- shows the existing confirmation and explains that refund handling is
  separate.

The booking state transition rules will explicitly allow `Paid -> Cancelled`
to match the cancellation service and repository behavior.

## Error Handling

- If automatic reservation refresh fails, My Reservations displays its
  existing retry state instead of stale data being treated as current.
- If cancellation becomes ineligible between rendering and submission, the
  backend returns a conflict and the ViewModel presents that message.
- A failed refund cannot occur in this scope because no refund request is made.
- Pending PayOS cancellation continues to surface gateway failures without
  changing the booking prematurely.

## Tests

Focused regression coverage will verify:

- closing unpaid PayOS opens Bookings and fetches reservations automatically;
- the refreshed pending reservation is visible without manual pull-to-refresh;
- paid cancellation is allowed immediately before Vietnam midnight;
- paid cancellation is rejected at Vietnam midnight on check-in day;
- paid cards show the cancel action only while eligible;
- canceling a paid booking keeps payment status `Success`;
- backend state transitions allow `Paid -> Cancelled`;
- existing pending-payment cancellation behavior remains intact.

After focused tests pass, run Dart formatting, Flutter analysis, the Flutter
test suite, and the backend test suite once.

