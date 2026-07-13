# PayOS Confirmation and Booking Management Design

**Date:** 2026-07-14

**Status:** Approved

**Repositories:** `BingCookApp` and `BingCookBackEnd/Bingcook-Backend`

## Goal

Make a completed PayOS payment visibly and reliably recognized by BingCook, return the customer to the Active bookings list with a success popup, persist the corresponding success notification, organize reservations into Active/Past/Canceled categories, and allow policy-compliant cancellation without regressing the existing booking workflow.

## Confirmed Root Causes

1. The PayOS `ReturnUrl` and `CancelUrl` in the shared backend configuration point to `localhost:5115`. A PayOS page running on the Android emulator cannot reach that backend address after payment, so the WebView ends on `ERR_CONNECTION_REFUSED`.
2. The deployed URL supplied by the team is a product endpoint, not a callback base. `https://bingcook-api.mascoteach.com/api/products` is live and returned HTTP 200 during investigation. PayOS must use the same origin with the payment controller paths.
3. Flutter refreshes reservations and notifications immediately after the checkout API creates a payment link, when the booking is still `PendingPayment`. The PayOS WebView does not recognize the later return/cancel navigation and never asks the existing booking-status endpoint for the final state.
4. The backend creates a `Payment Pending` notification when it creates a PayOS link, but the successful PayOS transition does not create a `Booking Successful` notification.
5. Reservations currently expose only Upcoming and Past tabs. Cancelled/expired records are mixed into Past, and there is no cancellation command in the Flutter repository or backend booking API.

## Scope

### Included

- Environment-specific PayOS return and cancel URLs.
- Existing PayOS webhook and return verification paths.
- Idempotent successful-payment state handling and success notification creation.
- Flutter recognition of the PayOS return/cancel navigation.
- Authenticated booking-status refresh after the redirect.
- Automatic navigation to Bookings -> Active after confirmed payment.
- In-app success popup and refreshed persisted notifications.
- Active, Past, and Canceled reservation categories.
- Authenticated, policy-aware reservation cancellation.
- Cancellation confirmation, loading, success, and error states.
- Backend, data-layer, view-model, widget, and navigation tests.
- An update to `BingCook_Implementation_and_Grading_Plan.docx` describing the completed work and current verification evidence.

### Excluded

- Automatic PayOS refunds.
- Firebase push notifications or operating-system notifications.
- A new deep-link/custom-URL scheme.
- A general MainShell navigation refactor.
- Repayment UI, review creation, or unrelated grading-roadmap work.
- Deployment of the backend or APK; the implementation will leave exact deployment configuration documented for the team.

## Selected Approach

Use a hybrid callback plus authenticated status-check flow.

- PayOS webhook and return requests remain authoritative server-side signals.
- The backend verifies PayOS instead of trusting redirect query parameters.
- The Flutter WebView recognizes completion only after the public backend return page finishes loading.
- Flutter then requests `GET /api/bookings/{bookingId}/status` with the signed-in user's JWT and acts on the stored booking/payment state.
- A bounded retry handles a short race between redirect rendering, webhook delivery, and database visibility. A manual Check payment status action remains available after the retry limit.

This approach fits the existing MVVM and repository/service layers, works inside the current embedded WebView, and avoids continuous polling or Android deep-link setup.

## Configuration Design

### Production

The shared production configuration uses:

- Return: `https://bingcook-api.mascoteach.com/api/payments/payos/return`
- Cancel: `https://bingcook-api.mascoteach.com/api/payments/payos/cancel`
- PayOS dashboard webhook: `https://bingcook-api.mascoteach.com/api/payments/payos/webhook`

The webhook is configured in the PayOS dashboard; it is not sent as part of the payment-link request.

### Development

`appsettings.Development.json` overrides the return and cancel URLs with Android-emulator-reachable endpoints:

- Return: `http://10.0.2.2:5115/api/payments/payos/return`
- Cancel: `http://10.0.2.2:5115/api/payments/payos/cancel`

This preserves the current emulator-to-local-backend workflow and prevents a locally created booking from being redirected to a deployed backend that uses a different database. Physical-device development must override these values with a reachable HTTPS tunnel or LAN origin.

Flutter keeps its emulator-friendly default API origin. Production builds use:

```powershell
flutter build apk --dart-define=BINGCOOK_API_BASE_URL=https://bingcook-api.mascoteach.com
```

Environment variables using ASP.NET Core's double-underscore convention may override any deployed PayOS setting.

## Backend Design

### PayOS return and webhook processing

`PaymentsController` continues to expose unauthenticated PayOS-facing webhook, return, and cancel endpoints. The return endpoint queries PayOS by `orderCode`, maps the provider status, applies the transition through `IBookingService`, and returns machine-readable JSON containing the provider status. Missing order codes remain a non-mutating acknowledgement.

The payment update repository operation becomes an outcome rather than a plain Boolean. Its result identifies whether a real state transition occurred and, for a paid transition, provides the booking's user and property name for notification content.

The SQL transaction locks the selected payment/booking row while evaluating and applying a transition. If webhook and return arrive concurrently, only the first `Pending` -> `Success` and `PendingPayment` -> `Paid` transition reports `StateChanged = true`. Later identical callbacks are successful no-ops. The service creates the success notification only for that first paid transition.

The persisted success notification uses:

- Title: `Booking Successful`
- Message: `Your booking at {PropertyName} has been paid and confirmed.`

Notification persistence remains non-fatal to payment confirmation, matching the existing checkout notification behavior. Failures are logged without reverting a verified payment.

### Cancellation endpoint

Add:

```text
POST /api/bookings/{bookingId}/cancel
Authorization: Bearer <token>
```

The endpoint contains no request body. The authenticated user ID is passed through controller -> service -> repository.

The service retrieves an owned cancellation candidate and enforces:

- The booking exists and belongs to the signed-in user.
- Status is `Pending`, `PendingPayment`, `Confirmed`, or `Paid`.
- Current time is more than 24 hours before check-in. Because the database stores a date without a time, BingCook uses the documented 14:00 check-in time at UTC+07:00 to construct the policy deadline.
- Already cancelled, expired, completed, or otherwise terminal bookings cannot be cancelled again.

Cancellation is transactional and uses a conditional status update to reject races:

- Booking status becomes `Cancelled`.
- A latest payment in `Pending` becomes `Cancelled`.
- A payment already in `Success` remains `Success` as an immutable audit/payment record.

No physical room counter needs to be incremented: availability is calculated dynamically and excludes cancelled bookings. A successful cancellation creates a persisted `Booking Cancelled` notification. The response returns the booking ID, resulting booking status, payment status, and a customer-safe message.

Automatic refund behavior is explicitly not claimed. The UI explains that an already successful payment remains recorded and any refund is handled separately under the property's policy.

## Flutter Data and Domain Design

`BookingApiService` gains methods for booking status and cancellation. It reuses the current authenticated JSON/error handling patterns.

`BookingRepository` gains:

```dart
Future<BookingPaymentStatus> fetchStatus(String bookingId);
Future<BookingCancellation> cancel(String bookingId);
```

The API repository supplies the current JWT, maps response DTOs into immutable domain models, preserves server messages for known failures, and converts transport/format failures into `BookingRepositoryException`.

The reservation domain model exposes category and cancellation-eligibility helpers based on normalized backend status and dates. Cancellation eligibility uses the same 14:00 UTC+07:00 check-in instant as the backend. The backend remains authoritative: Flutter's eligibility controls whether to show the button, while the cancellation endpoint revalidates every rule.

## Payment Result Presentation Design

A focused `PaymentResultViewModel` owns final-payment confirmation state. It receives the booking repository and booking ID and exposes:

- initial/waiting state;
- checking state;
- confirmed state;
- cancelled/expired/failed terminal state;
- retryable error state;
- a command for WebView navigation completion;
- a manual status-check command.

The WebView continues loading the backend return/cancel page. On `onPageFinished`, the view passes recognized `/api/payments/payos/return` or `/api/payments/payos/cancel` URLs to the view model. It does not trust URL status parameters.

For a return, the view model performs an immediate authenticated status request and up to two short retries while the status remains pending. It suppresses duplicate checks from repeated WebView callbacks. After the retry limit it remains pending and exposes Check payment status.

For `Paid` plus `Success`, the view emits completion exactly once. `MainShell` then:

1. refreshes bookings;
2. refreshes notifications;
3. clears the nested Explore/room/checkout/payment flow;
4. selects bottom-navigation index 2 (Bookings);
5. selects the Active booking category;
6. shows `Room booked successfully.` in a SnackBar.

Refresh failure cannot reverse payment success. The user remains on Bookings with the success message and can use pull-to-refresh/retry.

Cancel, expired, and failed payment results remain on the result view with a clear terminal message and a route back to Bookings. WebView loading errors remain retryable and do not change booking state.

## Bookings Presentation Design

Replace `BookingListTab.upcoming`/`past` with:

```dart
enum BookingListTab { active, past, canceled }
```

Classification is deterministic:

- Active: status is `Pending`, `PendingPayment`, `Confirmed`, or `Paid`, and checkout is today or later.
- Past: a non-cancelled booking has checkout before today, or a future backend `Completed` status is received.
- Canceled: status is `Cancelled`, `Canceled`, or `Expired`.

The segmented control labels are Active, Past, and Canceled. Each category has its own empty-state copy. Pull-to-refresh remains available.

`ReservationCard` receives cancellation state and callbacks from `BookingsView`; it does not call repositories. An eligible Active card displays Cancel reservation. Tapping it opens a confirmation dialog that mentions the 24-hour policy and, for paid reservations, explains that the successful payment record is retained and refund handling is separate.

`BookingsViewModel.cancel` prevents duplicate submission, calls the repository, reloads server data after success, and exposes a one-shot success/error result for the view. While cancellation is running, the affected card's button is disabled and displays progress. Success shows `Reservation cancelled.` and refreshes notifications through MainShell coordination.

## Error Handling

- Invalid webhook signatures return HTTP 400 without mutation.
- PayOS lookup/cancel failures return HTTP 502 and preserve current state.
- Missing or unowned bookings return HTTP 404 without revealing another user's booking.
- Cancellation-policy and terminal-state conflicts return HTTP 409 with a customer-safe message.
- Duplicate callback and cancellation requests are idempotent or return a clear terminal conflict.
- Flutter preserves backend messages for policy failures.
- Network and malformed-response failures use existing repository-level customer-safe errors.
- Views render loading, retryable error, empty, success, and terminal states without direct API calls.
- No secrets, tokens, or personal data are added to logs.

## Testing Strategy

All behavior changes follow red-green-refactor.

### Backend tests

- A paid PayOS transition updates state and creates one success notification.
- A duplicate paid callback does not create another notification.
- Invalid/downgrade transitions remain no-ops.
- An owned eligible pending booking cancels booking and pending payment.
- An owned eligible paid booking cancels booking but preserves `PaymentStatuses.Success`.
- The 24-hour boundary rejects cancellation.
- Missing/unowned and terminal bookings return the correct outcome.
- Successful cancellation creates one persisted cancellation notification.

### Flutter tests

- API service constructs status/cancel requests and maps success/errors.
- API repository maps status/cancellation DTOs and authentication failures.
- Payment result view model confirms paid status, handles pending retries, suppresses duplicate redirects, and exposes retryable errors.
- Bookings view model classifies Active/Past/Canceled and performs cancellation transitions.
- Bookings view renders three categories, confirmation, per-card progress, and success/error feedback.
- MainShell moves from PayOS completion to Bookings -> Active and shows the success SnackBar.
- Existing checkout, navigation, notification, and reservation tests remain green.

### Verification commands

Backend:

```powershell
dotnet build BingCook.Api.csproj
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj
```

Flutter:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

After deployment, verify the public products endpoint, PayOS return path, configured webhook, one low-value payment, automatic Active-tab navigation, exactly one success notification, and cancellation behavior.

## Documentation Update

Edit `BingCook_Implementation_and_Grading_Plan.docx` minimally while preserving its existing visual structure. The update records:

- PayOS production/development callback configuration;
- automatic final-status recognition and Bookings navigation;
- success and cancellation notifications;
- Active/Past/Canceled categories;
- cancellation policy and paid-payment audit behavior;
- new backend/frontend tests;
- fresh build/analyze/test evidence;
- the remaining deployment smoke-test responsibility.

The final DOCX must be rendered to page PNGs and visually inspected after editing. If LibreOffice remains unavailable, the document will receive structural QA and the final handoff will disclose that visual render QA could not be completed.

## Acceptance Criteria

1. A successful PayOS payment no longer returns to an unreachable localhost URL in production.
2. Backend state becomes booking `Paid` and payment `Success` only after server-side PayOS verification.
3. Flutter automatically recognizes the verified result, opens Bookings -> Active, and shows a success popup.
4. The newly paid reservation is visible after the automatic refresh.
5. Exactly one persisted success notification is created for the paid transition.
6. Bookings provides Active, Past, and Canceled categories with correct empty and loading states.
7. Eligible reservations can be cancelled after confirmation; the server enforces ownership and the 24-hour policy.
8. Cancelling a paid reservation preserves the successful payment record and does not claim an automatic refund.
9. Cancellation refreshes the list and produces clear in-app and persisted notifications.
10. Existing Flutter and backend tests remain green, and all new behavior has focused automated coverage.
11. The implementation/grading DOCX accurately reflects the delivered behavior and verification result.
