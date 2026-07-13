# PayOS Confirmation and Booking Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reliably recognize successful PayOS payments, return the customer to Bookings -> Active with success feedback, persist success notifications, add Active/Past/Canceled reservation categories, and support policy-compliant cancellation.

**Architecture:** Keep PayOS verification and booking-state transitions on the ASP.NET Core backend. Flutter observes the completed backend return navigation, requests the authenticated status endpoint through its repository, and coordinates navigation/refresh through focused ChangeNotifier view models. Cancellation follows controller -> service -> repository on the backend and view -> view model -> repository -> service in Flutter.

**Tech Stack:** .NET 8, ASP.NET Core Web API, Microsoft.Data.SqlClient, xUnit, Flutter/Dart, ChangeNotifier MVVM, `http`, `webview_flutter`, `flutter_test`, python-docx.

## Global Constraints

- Preserve the current Flutter layered MVVM dependency direction: View -> ViewModel -> Repository -> Service.
- Keep controllers thin, business rules in `BookingService`, and parameterized SQL in `SqlServerBookingRepository`.
- Production PayOS return URL: `https://bingcook-api.mascoteach.com/api/payments/payos/return`.
- Production PayOS cancel URL: `https://bingcook-api.mascoteach.com/api/payments/payos/cancel`.
- PayOS dashboard webhook URL: `https://bingcook-api.mascoteach.com/api/payments/payos/webhook`.
- Android-emulator development callbacks use `http://10.0.2.2:5115`.
- Cancellation closes exactly 24 hours before the documented 14:00 check-in time at UTC+07:00.
- A cancelled paid reservation keeps payment status `Success`; automatic refunds are outside scope.
- Do not loosen `BookingStatuses.CanTransition(Paid, ...)`; customer cancellation uses its own authenticated transaction so PayOS callbacks still cannot downgrade a paid booking.
- Persisted notification failure must not revert an already verified payment or cancellation.
- Keep existing Explore -> Details -> Select Room -> Checkout -> Payment, PayAtProperty, chat, map, profile, and notification behavior working.
- Make no unrelated MainShell refactor and add no new package unless the existing SDK/packages cannot implement the approved design.

## File Structure

### Backend

- `appsettings.json`: production PayOS callback defaults.
- `appsettings.Development.json`: emulator-local callback overrides.
- `BingCook.Api.Tests/PayOSConfigurationTests.cs`: callback configuration regression tests.
- `Models/BookingCheckout.cs`: PayOS update result shared by service/repository.
- `Models/BookingCancellation.cs`: cancellation commands, candidate, result, and service outcome.
- `Dtos/Bookings/BookingCancellationResponse.cs`: public cancellation response.
- `Data/IBookingRepository.cs`: payment-update result and cancellation contracts.
- `Data/SqlServerBookingRepository.cs`: locked/idempotent PayOS update and transactional cancellation SQL.
- `Services/IBookingService.cs`: cancellation command contract.
- `Services/BookingService.cs`: success-notification, clock, cancellation-policy, and cancellation-notification logic.
- `Controllers/BookingsController.cs`: authenticated cancellation endpoint.
- `Program.cs`: `TimeProvider.System` dependency registration.
- `BingCook.Api.Tests/BookingServiceTests.cs`: service-level payment and cancellation coverage.

### Flutter

- `lib/domain/models/booking.dart`: final-payment, cancellation, category, and eligibility domain models.
- `lib/domain/repositories/booking_repository.dart`: status and cancel methods.
- `lib/data/models/booking_api_models.dart`: status/cancel response DTOs.
- `lib/data/services/booking_api_service.dart`: authenticated status and cancel calls.
- `lib/data/repositories/api_booking_repository.dart`: DTO mapping and error translation.
- `lib/ui/features/checkout/view_models/payment_result_view_model.dart`: redirect recognition and bounded final-status checks.
- `lib/ui/features/checkout/views/payment_result_view.dart`: WebView completion bridge and status/retry presentation.
- `lib/ui/features/navigation/views/main_shell.dart`: payment-success navigation and cross-feature refresh.
- `lib/ui/features/bookings/view_models/bookings_view_model.dart`: three-way filtering and cancellation state.
- `lib/ui/features/bookings/views/bookings_view.dart`: three tabs and cancel confirmation/feedback.
- `lib/ui/features/bookings/widgets/reservation_card.dart`: eligible cancel action and per-card progress.
- `test/domain/models/booking_test.dart`: category and deadline rules.
- `test/data/services/booking_api_service_test.dart`: status/cancel HTTP contracts.
- `test/data/repositories/api_booking_repository_test.dart`: repository mapping/auth/error behavior.
- `test/ui/features/checkout/payment_result_view_model_test.dart`: status-check state machine.
- `test/ui/features/checkout/payment_result_view_test.dart`: WebView bridge and retry UI.
- `test/ui/features/bookings/bookings_view_model_test.dart`: categories and cancellation transitions.
- `test/ui/features/bookings/bookings_view_test.dart`: three-tab and cancellation interaction coverage.
- `test/ui/features/explore/main_shell_test.dart`: automatic Bookings navigation and success popup.
- Existing test fakes implementing `BookingRepository`: add status/cancel methods so all suites compile.

### Documentation

- `BingCook_Implementation_and_Grading_Plan.docx`: minimal implementation/grading status update.
- `.tmp-docx-payment-flow/update_implementation_plan.py`: task-local deterministic DOCX updater.
- `.tmp-docx-payment-flow/rendered/`: internal render QA only.

---

### Task 1: Protect Production and Development PayOS Callback Configuration

**Files:**
- Create: `BingCookBackEnd/Bingcook-Backend/BingCook.Api.Tests/PayOSConfigurationTests.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/appsettings.json`
- Modify: `BingCookBackEnd/Bingcook-Backend/appsettings.Development.json`

**Interfaces:**
- Consumes: ASP.NET Core environment-specific JSON configuration merge rules.
- Produces: production public callbacks and emulator-local development overrides.

- [ ] **Step 1: Write failing configuration tests**

Create `PayOSConfigurationTests.cs` with exact path resolution and assertions:

```csharp
using System.Text.Json;
using Xunit;

namespace BingCook.Api.Tests;

public sealed class PayOSConfigurationTests
{
    [Fact]
    public void ProductionCallbacksUseDeployedApiOrigin()
    {
        var payOS = ReadPayOS("appsettings.json");

        Assert.Equal(
            "https://bingcook-api.mascoteach.com/api/payments/payos/return",
            payOS.GetProperty("ReturnUrl").GetString());
        Assert.Equal(
            "https://bingcook-api.mascoteach.com/api/payments/payos/cancel",
            payOS.GetProperty("CancelUrl").GetString());
    }

    [Fact]
    public void DevelopmentCallbacksUseAndroidEmulatorHostBridge()
    {
        var payOS = ReadPayOS("appsettings.Development.json");

        Assert.Equal(
            "http://10.0.2.2:5115/api/payments/payos/return",
            payOS.GetProperty("ReturnUrl").GetString());
        Assert.Equal(
            "http://10.0.2.2:5115/api/payments/payos/cancel",
            payOS.GetProperty("CancelUrl").GetString());
    }

    private static JsonElement ReadPayOS(string fileName)
    {
        var repositoryRoot = Path.GetFullPath(Path.Combine(
            AppContext.BaseDirectory,
            "..", "..", "..", ".."));
        using var document = JsonDocument.Parse(
            File.ReadAllText(Path.Combine(repositoryRoot, fileName)));
        return document.RootElement.GetProperty("PayOS").Clone();
    }
}
```

- [ ] **Step 2: Run the focused tests and confirm RED**

Run from `BingCookBackEnd/Bingcook-Backend`:

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter PayOSConfigurationTests
```

Expected: FAIL because production still contains `localhost` and the development PayOS section is absent.

- [ ] **Step 3: Set the environment-specific callback values**

Change only the callback properties in `appsettings.json`:

```json
"ReturnUrl": "https://bingcook-api.mascoteach.com/api/payments/payos/return",
"CancelUrl": "https://bingcook-api.mascoteach.com/api/payments/payos/cancel"
```

Add this section to `appsettings.Development.json` beside `Logging`:

```json
"PayOS": {
  "ReturnUrl": "http://10.0.2.2:5115/api/payments/payos/return",
  "CancelUrl": "http://10.0.2.2:5115/api/payments/payos/cancel"
}
```

- [ ] **Step 4: Run the focused tests and confirm GREEN**

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter PayOSConfigurationTests
```

Expected: 2 passed, 0 failed.

- [ ] **Step 5: Commit the backend configuration slice**

```powershell
git add appsettings.json appsettings.Development.json BingCook.Api.Tests/PayOSConfigurationTests.cs
git commit -m "fix: configure PayOS callbacks per environment"
```

---

### Task 2: Make PayOS Paid Transitions Idempotent and Notify Once

**Files:**
- Modify: `BingCookBackEnd/Bingcook-Backend/Models/BookingCheckout.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Data/IBookingRepository.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Data/SqlServerBookingRepository.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Services/BookingService.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/BingCook.Api.Tests/BookingServiceTests.cs`

**Interfaces:**
- Consumes: `PayOSPaymentUpdateCommand` and existing payment/booking transition rules.
- Produces: `PayOSPaymentUpdateResult?` from the repository while retaining `IBookingService.UpdatePayOSPaymentAsync(...): Task<bool>` for controllers.

- [ ] **Step 1: Add failing service tests for paid and duplicate callbacks**

Add these tests to `BookingServiceTests` and extend the fake repository with a settable `PayOSUpdateResult`:

```csharp
[Fact]
public async Task UpdatePayOSPaymentAsync_CreatesOneSuccessfulBookingNotification()
{
    var userId = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    var notifications = new FakeNotificationRepository();
    var repository = new FakeBookingRepository
    {
        PayOSUpdateResult = new PayOSPaymentUpdateResult(
            userId,
            "BingCook Central Hotel",
            PaymentStatuses.Success,
            BookingStatuses.Paid,
            true)
    };
    var service = CreateService(
        repository,
        new FakePayOSPaymentGateway(),
        notifications);

    var found = await service.UpdatePayOSPaymentAsync(
        new PayOSPaymentUpdateCommand(
            "123456789",
            PaymentStatuses.Success,
            BookingStatuses.Paid),
        CancellationToken.None);

    Assert.True(found);
    var notification = Assert.Single(notifications.Created);
    Assert.Equal(userId, notification.UserId);
    Assert.Equal("Booking Successful", notification.Title);
    Assert.Contains("BingCook Central Hotel", notification.Message);
}

[Fact]
public async Task UpdatePayOSPaymentAsync_DoesNotDuplicateNotificationForNoOp()
{
    var notifications = new FakeNotificationRepository();
    var repository = new FakeBookingRepository
    {
        PayOSUpdateResult = new PayOSPaymentUpdateResult(
            Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
            "BingCook Central Hotel",
            PaymentStatuses.Success,
            BookingStatuses.Paid,
            false)
    };
    var service = CreateService(
        repository,
        new FakePayOSPaymentGateway(),
        notifications);

    var found = await service.UpdatePayOSPaymentAsync(
        new PayOSPaymentUpdateCommand(
            "123456789",
            PaymentStatuses.Success,
            BookingStatuses.Paid),
        CancellationToken.None);

    Assert.True(found);
    Assert.Empty(notifications.Created);
}
```

- [ ] **Step 2: Run the focused tests and confirm RED**

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter UpdatePayOSPaymentAsync
```

Expected: build/test failure because `PayOSPaymentUpdateResult` and the new repository result do not exist.

- [ ] **Step 3: Add the repository result contract**

Append to `Models/BookingCheckout.cs`:

```csharp
public sealed record PayOSPaymentUpdateResult(
    Guid UserId,
    string PropertyName,
    string PaymentStatus,
    string BookingStatus,
    bool StateChanged);
```

Change `IBookingRepository` to:

```csharp
Task<PayOSPaymentUpdateResult?> UpdatePayOSPaymentAsync(
    PayOSPaymentUpdateCommand command,
    CancellationToken cancellationToken);
```

Update the test fake to return `Task.FromResult(PayOSUpdateResult)` from this signature.

- [ ] **Step 4: Implement the locked, idempotent SQL outcome**

Replace `SqlServerBookingRepository.UpdatePayOSPaymentAsync` with this transaction shape, retaining the existing parameter helpers:

```csharp
public async Task<PayOSPaymentUpdateResult?> UpdatePayOSPaymentAsync(
    PayOSPaymentUpdateCommand command,
    CancellationToken cancellationToken)
{
    const string findSql = """
        SELECT TOP (1)
            b.UserId,
            property.[Name] AS propertyname,
            p.[Status] AS paymentstatus,
            b.[Status] AS bookingstatus
        FROM dbo.Payment p WITH (UPDLOCK, ROWLOCK)
        INNER JOIN dbo.Booking b WITH (UPDLOCK, ROWLOCK)
            ON b.Id = p.BookingId
        INNER JOIN dbo.Property property ON property.Id = b.PropertyId
        WHERE p.TransactionCode = @transactionCode
          AND p.Provider = N'PayOS';
        """;
    const string updatePaymentSql = """
        UPDATE dbo.Payment
        SET [Status] = @paymentStatus,
            PaidAt = CASE
                WHEN @paymentStatus = N'Success'
                    THEN COALESCE(PaidAt, SYSUTCDATETIME())
                ELSE PaidAt
            END,
            UpdatedAt = SYSUTCDATETIME()
        WHERE TransactionCode = @transactionCode
          AND Provider = N'PayOS';
        """;
    const string updateBookingSql = """
        UPDATE dbo.Booking
        SET [Status] = @bookingStatus
        WHERE Id = (
            SELECT TOP (1) BookingId
            FROM dbo.Payment
            WHERE TransactionCode = @transactionCode
              AND Provider = N'PayOS');
        """;

    await using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);
    await using var transaction = await connection.BeginTransactionAsync(
        cancellationToken);

    await using var find = connection.CreateCommand();
    find.Transaction = (SqlTransaction)transaction;
    find.CommandText = findSql;
    AddText(find, "@transactionCode", command.TransactionCode, 100);
    await using var reader = await find.ExecuteReaderAsync(cancellationToken);
    if (!await reader.ReadAsync(cancellationToken))
    {
        await transaction.RollbackAsync(cancellationToken);
        return null;
    }

    var userId = reader.GetGuid(reader.GetOrdinal("UserId"));
    var propertyName = reader.GetString(reader.GetOrdinal("propertyname"));
    var currentPaymentStatus = reader.GetString(reader.GetOrdinal("paymentstatus"));
    var currentBookingStatus = reader.GetString(reader.GetOrdinal("bookingstatus"));
    await reader.CloseAsync();

    var canTransition =
        PaymentStatuses.CanTransition(currentPaymentStatus, command.PaymentStatus)
        && BookingStatuses.CanTransition(currentBookingStatus, command.BookingStatus);
    var stateChanged =
        currentPaymentStatus != command.PaymentStatus
        || currentBookingStatus != command.BookingStatus;

    if (!canTransition || !stateChanged)
    {
        await transaction.CommitAsync(cancellationToken);
        return new PayOSPaymentUpdateResult(
            userId,
            propertyName,
            currentPaymentStatus,
            currentBookingStatus,
            false);
    }

    await using var updatePayment = connection.CreateCommand();
    updatePayment.Transaction = (SqlTransaction)transaction;
    updatePayment.CommandText = updatePaymentSql;
    AddText(updatePayment, "@transactionCode", command.TransactionCode, 100);
    AddText(updatePayment, "@paymentStatus", command.PaymentStatus, 20);
    await updatePayment.ExecuteNonQueryAsync(cancellationToken);

    await using var updateBooking = connection.CreateCommand();
    updateBooking.Transaction = (SqlTransaction)transaction;
    updateBooking.CommandText = updateBookingSql;
    AddText(updateBooking, "@transactionCode", command.TransactionCode, 100);
    AddText(updateBooking, "@bookingStatus", command.BookingStatus, 20);
    await updateBooking.ExecuteNonQueryAsync(cancellationToken);

    await transaction.CommitAsync(cancellationToken);
    return new PayOSPaymentUpdateResult(
        userId,
        propertyName,
        command.PaymentStatus,
        command.BookingStatus,
        true);
}
```

- [ ] **Step 5: Create the success notification only for the first paid transition**

Replace the service pass-through with:

```csharp
public async Task<bool> UpdatePayOSPaymentAsync(
    PayOSPaymentUpdateCommand command,
    CancellationToken cancellationToken)
{
    var result = await _bookingRepository.UpdatePayOSPaymentAsync(
        command,
        cancellationToken);
    if (result is null)
    {
        return false;
    }

    if (result.StateChanged
        && result.PaymentStatus == PaymentStatuses.Success
        && result.BookingStatus == BookingStatuses.Paid)
    {
        await CreateCheckoutNotificationAsync(
            result.UserId,
            "Booking Successful",
            $"Your booking at {result.PropertyName} has been paid and confirmed.",
            cancellationToken);
    }

    return true;
}
```

- [ ] **Step 6: Run focused and complete backend tests**

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter UpdatePayOSPaymentAsync
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj
```

Expected: focused tests pass; complete backend suite has 0 failures.

- [ ] **Step 7: Commit the backend payment slice**

```powershell
git add Models/BookingCheckout.cs Data/IBookingRepository.cs Data/SqlServerBookingRepository.cs Services/BookingService.cs BingCook.Api.Tests/BookingServiceTests.cs
git commit -m "feat: recognize PayOS payment success once"
```

---

### Task 3: Add Authenticated Policy-Aware Booking Cancellation

**Files:**
- Create: `BingCookBackEnd/Bingcook-Backend/Models/BookingCancellation.cs`
- Create: `BingCookBackEnd/Bingcook-Backend/Dtos/Bookings/BookingCancellationResponse.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Data/IBookingRepository.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Data/SqlServerBookingRepository.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Services/IBookingService.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Services/BookingService.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Controllers/BookingsController.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/Program.cs`
- Modify: `BingCookBackEnd/Bingcook-Backend/BingCook.Api.Tests/BookingServiceTests.cs`

**Interfaces:**
- Consumes: authenticated user ID, booking ID, existing notification repository, and `TimeProvider`.
- Produces: `POST /api/bookings/{bookingId}/cancel` returning `BookingCancellationResponse` or HTTP 404/409.

- [ ] **Step 1: Write failing cancellation service tests**

Add tests using a fixed clock of `2026-07-14T02:00:00Z`:

```csharp
[Fact]
public async Task CancelAsync_CancelsEligiblePaidBookingAndPreservesSuccessfulPayment()
{
    var bookingId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
    var userId = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    var notifications = new FakeNotificationRepository();
    var repository = new FakeBookingRepository
    {
        CancellationCandidate = new BookingCancellationCandidate(
            bookingId,
            userId,
            "BingCook Central Hotel",
            new DateOnly(2026, 7, 16),
            BookingStatuses.Paid,
            PaymentStatuses.Success),
        CancellationResult = new BookingCancellationResult(
            bookingId,
            BookingStatuses.Cancelled,
            PaymentStatuses.Success)
    };
    var service = CreateService(
        repository,
        new FakePayOSPaymentGateway(),
        notifications,
        new FixedTimeProvider(new DateTimeOffset(2026, 7, 14, 2, 0, 0, TimeSpan.Zero)));

    var outcome = await service.CancelAsync(
        bookingId,
        userId,
        CancellationToken.None);

    Assert.Equal(BookingCancellationOutcomeStatus.Success, outcome.Status);
    Assert.Equal(PaymentStatuses.Success, outcome.Result?.PaymentStatus);
    Assert.Equal(BookingStatuses.Paid, repository.LastCancellationCommand?.ExpectedBookingStatus);
    Assert.Equal("Booking Cancelled", Assert.Single(notifications.Created).Title);
}

[Fact]
public async Task CancelAsync_RejectsAtTwentyFourHourDeadline()
{
    var bookingId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
    var userId = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    var repository = new FakeBookingRepository
    {
        CancellationCandidate = new BookingCancellationCandidate(
            bookingId,
            userId,
            "BingCook Central Hotel",
            new DateOnly(2026, 7, 16),
            BookingStatuses.Paid,
            PaymentStatuses.Success)
    };
    var service = CreateService(
        repository,
        new FakePayOSPaymentGateway(),
        timeProvider: new FixedTimeProvider(
            new DateTimeOffset(2026, 7, 15, 7, 0, 0, TimeSpan.Zero)));

    var outcome = await service.CancelAsync(
        bookingId,
        userId,
        CancellationToken.None);

    Assert.Equal(BookingCancellationOutcomeStatus.Conflict, outcome.Status);
    Assert.Contains("24 hours", outcome.Error);
    Assert.Null(repository.LastCancellationCommand);
}
```

Also add focused tests for: missing/unowned candidate -> `NotFound`; terminal status -> `Conflict`; pending payment -> cancellation result has payment `Cancelled`; repository race returning null -> `Conflict` and no notification.

- [ ] **Step 2: Run cancellation tests and confirm RED**

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter CancelAsync
```

Expected: build/test failure because cancellation types and service method do not exist.

- [ ] **Step 3: Add cancellation models and service outcomes**

Create `Models/BookingCancellation.cs`:

```csharp
namespace BingCook.Api.Models;

public sealed record BookingCancellationCandidate(
    Guid BookingId,
    Guid UserId,
    string PropertyName,
    DateOnly CheckIn,
    string BookingStatus,
    string? PaymentStatus);

public sealed record CompleteBookingCancellationCommand(
    Guid BookingId,
    Guid UserId,
    string ExpectedBookingStatus);

public sealed record BookingCancellationResult(
    Guid BookingId,
    string BookingStatus,
    string? PaymentStatus);

public enum BookingCancellationOutcomeStatus
{
    Success,
    NotFound,
    Conflict
}

public sealed record BookingCancellationOutcome(
    BookingCancellationOutcomeStatus Status,
    BookingCancellationResult? Result,
    string? Error)
{
    public static BookingCancellationOutcome Success(BookingCancellationResult result) =>
        new(BookingCancellationOutcomeStatus.Success, result, null);

    public static BookingCancellationOutcome NotFound(string error) =>
        new(BookingCancellationOutcomeStatus.NotFound, null, error);

    public static BookingCancellationOutcome Conflict(string error) =>
        new(BookingCancellationOutcomeStatus.Conflict, null, error);
}
```

Add repository contracts for `GetCancellationCandidateAsync` and `CancelAsync(CompleteBookingCancellationCommand, ...)`. Add `IBookingService.CancelAsync(Guid bookingId, Guid userId, ...)`.

- [ ] **Step 4: Inject a deterministic clock and implement the 24-hour rule**

Register in `Program.cs`:

```csharp
builder.Services.AddSingleton(TimeProvider.System);
```

Add `TimeProvider` to `BookingService`, replace direct `DateTime.UtcNow` use in this service with `_timeProvider.GetUtcNow().UtcDateTime`, and implement the deadline:

```csharp
private static readonly TimeOnly StandardCheckInTime = new(14, 0);
private static readonly TimeSpan VietnamOffset = TimeSpan.FromHours(7);

private bool IsCancellationDeadlinePassed(DateOnly checkIn)
{
    var localCheckIn = checkIn.ToDateTime(
        StandardCheckInTime,
        DateTimeKind.Unspecified);
    var checkInInstant = new DateTimeOffset(localCheckIn, VietnamOffset);
    return _timeProvider.GetUtcNow() >= checkInInstant.AddHours(-24);
}
```

Update the test factory and define its fixed clock explicitly:

```csharp
private static BookingService CreateService(
    IBookingRepository repository,
    IPayOSPaymentGateway gateway,
    INotificationRepository? notificationRepository = null,
    TimeProvider? timeProvider = null)
{
    return new BookingService(
        repository,
        gateway,
        notificationRepository ?? new FakeNotificationRepository(),
        timeProvider ?? TimeProvider.System,
        Options.Create(new BookingOptions { HoldMinutes = 15 }),
        NullLogger<BookingService>.Instance);
}

private sealed class FixedTimeProvider(DateTimeOffset now) : TimeProvider
{
    public override DateTimeOffset GetUtcNow() => now;
}
```

`CancelAsync` accepts only `Pending`, `PendingPayment`, `Confirmed`, and `Paid`, calls the conditional repository update, and creates `Booking Cancelled` only after a successful update.

- [ ] **Step 5: Implement transactional SQL cancellation**

`GetCancellationCandidateAsync` selects the owned booking, property name, check-in date, booking status, and latest payment status.

`CancelAsync` starts a SQL transaction and executes:

```sql
UPDATE dbo.Booking
SET [Status] = N'Cancelled'
WHERE Id = @bookingId
  AND UserId = @userId
  AND [Status] = @expectedBookingStatus;

UPDATE dbo.Payment
SET [Status] = N'Cancelled',
    UpdatedAt = SYSUTCDATETIME()
WHERE BookingId = @bookingId
  AND [Status] = N'Pending';
```

Rollback and return `null` when the booking update affects zero rows. Otherwise read the latest payment status, commit, and return `BookingCancellationResult`. The payment update predicate intentionally preserves `Success`.

- [ ] **Step 6: Add the controller response and endpoint**

Create:

```csharp
namespace BingCook.Api.Dtos.Bookings;

public sealed record BookingCancellationResponse(
    Guid BookingId,
    string BookingStatus,
    string? PaymentStatus,
    string Message);
```

Add to `BookingsController`:

```csharp
[HttpPost("{bookingId:guid}/cancel")]
public async Task<ActionResult<BookingCancellationResponse>> Cancel(
    Guid bookingId,
    CancellationToken cancellationToken)
{
    var userId = GetUserId();
    if (userId is null)
    {
        return Unauthorized(new { message = "Invalid access token." });
    }

    var outcome = await _bookingService.CancelAsync(
        bookingId,
        userId.Value,
        cancellationToken);

    return outcome.Status switch
    {
        BookingCancellationOutcomeStatus.Success => Ok(
            new BookingCancellationResponse(
                outcome.Result!.BookingId,
                outcome.Result.BookingStatus,
                outcome.Result.PaymentStatus,
                "Reservation cancelled. Successful payments remain recorded; refund handling is separate.")),
        BookingCancellationOutcomeStatus.NotFound =>
            NotFound(new { message = outcome.Error }),
        BookingCancellationOutcomeStatus.Conflict =>
            Conflict(new { message = outcome.Error }),
        _ => StatusCode(StatusCodes.Status500InternalServerError)
    };
}
```

- [ ] **Step 7: Run backend tests and build**

```powershell
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj --filter CancelAsync
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj
dotnet build BingCook.Api.csproj
```

Expected: cancellation tests pass, complete suite has 0 failures, build exits 0.

- [ ] **Step 8: Commit the backend cancellation slice**

```powershell
git add Models/BookingCancellation.cs Dtos/Bookings/BookingCancellationResponse.cs Data/IBookingRepository.cs Data/SqlServerBookingRepository.cs Services/IBookingService.cs Services/BookingService.cs Controllers/BookingsController.cs Program.cs BingCook.Api.Tests/BookingServiceTests.cs
git commit -m "feat: cancel eligible reservations"
```

---

### Task 4: Add Flutter Status, Cancellation, Category, and Eligibility Contracts

**Files:**
- Modify: `BingCookApp/lib/domain/models/booking.dart`
- Modify: `BingCookApp/lib/domain/repositories/booking_repository.dart`
- Modify: `BingCookApp/lib/data/models/booking_api_models.dart`
- Modify: `BingCookApp/lib/data/services/booking_api_service.dart`
- Modify: `BingCookApp/lib/data/repositories/api_booking_repository.dart`
- Create: `BingCookApp/test/domain/models/booking_test.dart`
- Modify: `BingCookApp/test/data/services/booking_api_service_test.dart`
- Modify: `BingCookApp/test/data/repositories/api_booking_repository_test.dart`
- Modify fakes in: `test/app_test.dart`, `test/ui/features/select_room/select_room_view_model_test.dart`, `test/ui/features/checkout/checkout_view_model_test.dart`, `test/ui/features/bookings/bookings_view_model_test.dart`, `test/ui/features/explore/main_shell_test.dart`

**Interfaces:**
- Consumes: backend status and cancellation JSON.
- Produces: immutable `BookingPaymentStatus`, `BookingCancellation`, `BookingCategory`, `fetchStatus`, and `cancel` APIs.

- [ ] **Step 1: Write failing domain-rule tests**

Create `booking_test.dart` with a fixed `now` and reservation factory. Assert:

```dart
test('classifies active past and canceled reservations', () {
  final now = DateTime.utc(2026, 7, 14, 2);

  expect(_reservation(status: 'Paid').categoryAt(now), BookingCategory.active);
  expect(
    _reservation(
      status: 'Confirmed',
      checkOut: DateTime(2026, 7, 13),
    ).categoryAt(now),
    BookingCategory.past,
  );
  expect(
    _reservation(status: 'Cancelled').categoryAt(now),
    BookingCategory.canceled,
  );
  expect(
    _reservation(status: 'Expired').categoryAt(now),
    BookingCategory.canceled,
  );
});

test('allows cancellation only before Vietnam check-in deadline', () {
  final reservation = _reservation(
    status: 'Paid',
    checkIn: DateTime(2026, 7, 16),
  );

  expect(reservation.canCancelAt(DateTime.utc(2026, 7, 15, 6, 59)), isTrue);
  expect(reservation.canCancelAt(DateTime.utc(2026, 7, 15, 7)), isFalse);
});
```

- [ ] **Step 2: Write failing API service and repository tests**

Add service tests asserting:

```dart
expect(capturedRequest!.method, 'GET');
expect(capturedRequest!.url.path, '/api/bookings/booking-1/status');
expect(status.isPaid, isTrue);

expect(capturedRequest!.method, 'POST');
expect(capturedRequest!.url.path, '/api/bookings/booking-1/cancel');
expect(cancellation.paymentStatus, 'Success');
```

Use backend-shaped JSON containing all `BookingStatusResponse` fields and the four `BookingCancellationResponse` fields. Add repository tests proving the current JWT is passed and a 409 message becomes `BookingRepositoryException` unchanged.

- [ ] **Step 3: Run focused tests and confirm RED**

```powershell
flutter test test/domain/models/booking_test.dart test/data/services/booking_api_service_test.dart test/data/repositories/api_booking_repository_test.dart
```

Expected: compile failures because new domain/repository methods do not exist.

- [ ] **Step 4: Add domain models and deterministic rules**

Add:

```dart
enum BookingCategory { active, past, canceled }

class BookingPaymentStatus {
  const BookingPaymentStatus({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.transactionCode,
    required this.paidAt,
    required this.updatedAt,
  });

  final String bookingId;
  final String bookingStatus;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? amount;
  final String? transactionCode;
  final DateTime? paidAt;
  final DateTime? updatedAt;

  bool get isPaid =>
      bookingStatus.toLowerCase() == 'paid' &&
      paymentStatus?.toLowerCase() == 'success';
}

class BookingCancellation {
  const BookingCancellation({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.message,
  });

  final String bookingId;
  final String bookingStatus;
  final String? paymentStatus;
  final String message;
}
```

Add `BookingReservation.categoryAt(DateTime now)` and `canCancelAt(DateTime now)`. Construct 14:00 UTC+07 as `DateTime.utc(checkIn.year, checkIn.month, checkIn.day, 7)` and compare `now.toUtc()` with one day earlier.

- [ ] **Step 5: Implement API DTOs, service methods, and repository mapping**

Add response DTOs mirroring the backend records. Add to `BookingApiService`:

```dart
Future<BookingStatusResponse> fetchStatus({
  required String token,
  required String bookingId,
}) async {
  final decoded = await _getObject(
    token: token,
    path: '/api/bookings/$bookingId/status',
  );
  return BookingStatusResponse.fromJson(decoded);
}

Future<BookingCancellationResponse> cancel({
  required String token,
  required String bookingId,
}) async {
  final decoded = await _postObject(
    token: token,
    path: '/api/bookings/$bookingId/cancel',
    body: const {},
  );
  return BookingCancellationResponse.fromJson(decoded);
}
```

Add `_getObject` with the same headers/status/message behavior as `_postObject`. Extend `BookingRepository` and `ApiBookingRepository` with `fetchStatus` and `cancel`, reusing `_token()` and existing exception mapping.

- [ ] **Step 6: Update every BookingRepository test fake**

Each fake listed in this task must implement:

```dart
@override
Future<BookingPaymentStatus> fetchStatus(String bookingId) =>
    throw UnimplementedError();

@override
Future<BookingCancellation> cancel(String bookingId) =>
    throw UnimplementedError();
```

Fakes used by new tests return concrete values instead of throwing.

- [ ] **Step 7: Run focused tests and confirm GREEN**

```powershell
dart format lib test
flutter test test/domain/models/booking_test.dart test/data/services/booking_api_service_test.dart test/data/repositories/api_booking_repository_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 8: Commit the Flutter contract slice**

```powershell
git add lib/domain/models/booking.dart lib/domain/repositories/booking_repository.dart lib/data/models/booking_api_models.dart lib/data/services/booking_api_service.dart lib/data/repositories/api_booking_repository.dart test
git commit -m "feat: add booking status and cancellation contracts"
```

---

### Task 5: Recognize the PayOS Return and Navigate to Active Bookings

**Files:**
- Create: `BingCookApp/lib/ui/features/checkout/view_models/payment_result_view_model.dart`
- Modify: `BingCookApp/lib/ui/features/checkout/views/payment_result_view.dart`
- Modify: `BingCookApp/lib/ui/features/navigation/views/main_shell.dart`
- Create: `BingCookApp/test/ui/features/checkout/payment_result_view_model_test.dart`
- Modify: `BingCookApp/test/ui/features/checkout/payment_result_view_test.dart`
- Modify: `BingCookApp/test/ui/features/explore/main_shell_test.dart`

**Interfaces:**
- Consumes: `BookingRepository.fetchStatus`, WebView `onPageFinished`, and the existing checkout result.
- Produces: exactly-once payment completion signal, bounded retries, Active-tab navigation, refreshed bookings/notifications, and success SnackBar.

- [ ] **Step 1: Write failing payment-result view-model tests**

Cover these exact behaviors:

```dart
test('ignores non-BingCook navigation', () async {
  final repository = _BookingRepository();
  final viewModel = PaymentResultViewModel(
    bookingId: 'booking-1',
    bookingRepository: repository,
    delay: (_) async {},
  );

  expect(await viewModel.handlePageFinished('https://pay.payos.vn/web/1'), isFalse);
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
```

Also test pending -> pending -> paid uses three calls, three pending results expose manual retry without false success, cancel/expired states become terminal, and repository failure becomes retryable `error`.

- [ ] **Step 2: Run the new view-model test and confirm RED**

```powershell
flutter test test/ui/features/checkout/payment_result_view_model_test.dart
```

Expected: compile failure because `PaymentResultViewModel` is absent.

- [ ] **Step 3: Implement the focused payment state machine**

Create the state enum and constructor-injected delay:

```dart
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
```

`handlePageFinished` accepts only paths ending in `/api/payments/payos/return` or `/api/payments/payos/cancel`, suppresses concurrent/duplicate work, and delegates to `checkStatus(maxAttempts: 3)`. `checkStatus` notifies checking state, fetches authenticated status, delays one second between pending attempts, maps terminal statuses, and returns `true` only the first time `Paid` + `Success` is observed.

- [ ] **Step 4: Write failing view and shell integration tests**

Change the injectable builder contract to:

```dart
typedef PayOSCheckoutBuilder = Widget Function(
  Uri checkoutUri,
  ValueChanged<String> onPageFinished,
);
```

In `payment_result_view_test.dart`, capture `onPageFinished`, invoke it with the public return URL, and assert the completion callback fires only after the fake repository returns paid.

In `main_shell_test.dart`, use a fake repository that returns `_paidStatus`, make the injected checkout builder render a `payos_complete_button`, invoke `onPageFinished` from that button, then assert:

```dart
expect(find.byKey(const Key('bookings_title')), findsOneWidget);
expect(find.text('Active'), findsOneWidget);
expect(find.text('Room booked successfully.'), findsOneWidget);
expect(repository.fetchReservationsCalls, greaterThanOrEqualTo(2));
```

- [ ] **Step 5: Run integration tests and confirm RED**

```powershell
flutter test test/ui/features/checkout/payment_result_view_test.dart test/ui/features/explore/main_shell_test.dart
```

Expected: failures because the view and MainShell do not bridge final status or navigate.

- [ ] **Step 6: Connect WebView completion to the view model**

Pass `onPageFinished` into `_PayOSCheckoutWebView` and call it after clearing loading state. `PaymentResultView` receives `PaymentResultViewModel viewModel` and `VoidCallback onPaymentConfirmed`; it awaits `handlePageFinished` and invokes the callback only when the returned value is true. Render Check payment status for pending/error states and reuse the same exactly-once callback path for manual checks.

- [ ] **Step 7: Coordinate success in MainShell**

Create/dispose a `PaymentResultViewModel` with each checkout result. Implement `_handlePaymentConfirmed` to select `BookingListTab.active`, await booking and notification refreshes, clear nested booking-flow fields, set `_selectedIndex = 2`, and show:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Room booked successfully.')),
);
```

Do not change the existing close-to-Explore action or PayAtProperty fallback.

- [ ] **Step 8: Run focused tests and confirm GREEN**

```powershell
dart format lib test
flutter test test/ui/features/checkout/payment_result_view_model_test.dart test/ui/features/checkout/payment_result_view_test.dart test/ui/features/explore/main_shell_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 9: Commit the Flutter payment-recognition slice**

```powershell
git add lib/ui/features/checkout lib/ui/features/navigation/views/main_shell.dart test/ui/features/checkout test/ui/features/explore/main_shell_test.dart
git commit -m "feat: recognize completed PayOS payments"
```

---

### Task 6: Build Active, Past, and Canceled Tabs with Cancellation UI

**Files:**
- Modify: `BingCookApp/lib/ui/features/bookings/view_models/bookings_view_model.dart`
- Modify: `BingCookApp/lib/ui/features/bookings/views/bookings_view.dart`
- Modify: `BingCookApp/lib/ui/features/bookings/widgets/reservation_card.dart`
- Modify: `BingCookApp/lib/ui/features/navigation/views/main_shell.dart`
- Modify: `BingCookApp/test/ui/features/bookings/bookings_view_model_test.dart`
- Create: `BingCookApp/test/ui/features/bookings/bookings_view_test.dart`
- Modify: `BingCookApp/test/ui/features/explore/main_shell_test.dart`

**Interfaces:**
- Consumes: `BookingReservation.categoryAt`, `canCancelAt`, and `BookingRepository.cancel`.
- Produces: three tab states, server-backed cancellation, per-card progress, refresh, in-app feedback, and notification refresh callback.

- [ ] **Step 1: Replace the current view-model test with failing three-category tests**

Use `BookingsViewModel(now: () => DateTime.utc(2026, 7, 14, 2), ...)` and assert Active/Past/Canceled IDs independently. Add cancellation coverage:

```dart
test('cancels eligible reservation and reloads server data', () async {
  final repository = _BookingRepository([_paidReservation]);
  final viewModel = BookingsViewModel(
    bookingRepository: repository,
    now: () => DateTime.utc(2026, 7, 14, 2),
  );
  await viewModel.load();

  final success = await viewModel.cancel(_paidReservation);

  expect(success, isTrue);
  expect(repository.cancelledBookingId, _paidReservation.bookingId);
  expect(viewModel.cancellingBookingId, isNull);
  expect(viewModel.successMessage, contains('Reservation cancelled'));
  expect(repository.fetchCalls, 2);
});
```

Also assert duplicate cancellation is rejected while the first call is pending and repository errors populate `actionErrorMessage` without clearing loaded reservations.

- [ ] **Step 2: Write failing widget tests for tabs and cancellation**

Create `bookings_view_test.dart` that pumps `BookingsView` with fixed-time view model and fake repository. Assert all three labels, switch to Canceled and see the cancelled card, switch to Active and see `Cancel reservation`, tap it, confirm the dialog, observe progress, complete the fake response, and assert the success SnackBar plus callback invocation.

- [ ] **Step 3: Run focused tests and confirm RED**

```powershell
flutter test test/ui/features/bookings/bookings_view_model_test.dart test/ui/features/bookings/bookings_view_test.dart
```

Expected: failures because there are only Upcoming/Past and no cancellation state/UI.

- [ ] **Step 4: Implement deterministic three-way filtering and cancellation state**

Replace the enum with:

```dart
enum BookingListTab { active, past, canceled }
```

Inject `DateTime Function() now`, default to `DateTime.now`, and filter by `reservation.categoryAt(_now())`. Add read-only `cancellingBookingId`, `successMessage`, and `actionErrorMessage`. `cancel` verifies `canCancelAt`, prevents duplicate commands, calls the repository, reloads reservations directly, and always clears the per-card busy ID in `finally`.

- [ ] **Step 5: Implement the three-tab view and confirmation dialog**

Render Active, Past, and Canceled segments and category-specific empty copy. Add `key: Key('bookings_title')` to the page heading. Pass `onCancel` only for eligible Active cards. The dialog copy must include the 24-hour rule; for successful payments add: `Your successful payment remains recorded. Refund handling is separate.`

After success, show the server/customer-safe success message and invoke `onReservationCancelled` so MainShell refreshes notifications. On failure, show `actionErrorMessage` and leave the card visible.

- [ ] **Step 6: Add the ReservationCard cancellation action**

Extend the constructor with nullable `VoidCallback onCancel` and `bool isCancelling`. Under the existing View Details/map row, render an outlined full-width `Cancel reservation` button when callback is present. Disable it and render a compact progress indicator for the active booking ID. Keep map and detail behavior unchanged.

- [ ] **Step 7: Refresh notifications after cancellation**

Pass this callback from MainShell:

```dart
onReservationCancelled: () {
  unawaited(_notificationsViewModel.refresh());
},
```

Add a MainShell assertion that the notification repository is fetched again after confirmed cancellation.

- [ ] **Step 8: Run focused tests and confirm GREEN**

```powershell
dart format lib test
flutter test test/ui/features/bookings/bookings_view_model_test.dart test/ui/features/bookings/bookings_view_test.dart test/ui/features/explore/main_shell_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 9: Commit the booking-management UI slice**

```powershell
git add lib/ui/features/bookings lib/ui/features/navigation/views/main_shell.dart test/ui/features/bookings test/ui/features/explore/main_shell_test.dart
git commit -m "feat: manage active past and canceled bookings"
```

---

### Task 7: Verify the Full Workflow and Update the Grading DOCX

**Files:**
- Modify: `BingCook_Implementation_and_Grading_Plan.docx`
- Create: `.tmp-docx-payment-flow/update_implementation_plan.py`
- Create internally: `.tmp-docx-payment-flow/rendered/page-<N>.png`

**Interfaces:**
- Consumes: final implemented behavior and fresh command output.
- Produces: verified backend/Flutter code and an updated implementation/grading document.

- [ ] **Step 1: Run backend verification from a clean command invocation**

```powershell
dotnet build BingCook.Api.csproj
dotnet test BingCook.Api.Tests\BingCook.Api.Tests.csproj
```

Expected: build exits 0; all backend tests pass with 0 failed.

- [ ] **Step 2: Run required Flutter verification**

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected: formatting exits 0, analyzer reports no issues, all Flutter tests pass.

- [ ] **Step 3: Inspect both worktrees before document claims**

```powershell
git status --short
git log -5 --oneline
```

Run once in each repository. Confirm only intentional changes/commits exist and record the exact backend/Flutter test counts for the DOCX.

- [ ] **Step 4: Create the deterministic DOCX updater with apply_patch**

The script must use the bundled Python runtime and `python-docx`, preserve all existing styles/tables, and make these exact local edits:

- Replace the current overall finding with a statement that PayOS confirmation, Active/Past/Canceled reservations, cancellation, and success/cancellation notifications are implemented.
- Change the P2 checkout item to record automatic final-status recognition, Bookings navigation, and success feedback.
- Change the P3 reservations item to completed for three categories and policy-aware cancellation; keep reservation-detail/repay as separate remaining work if still absent.
- Extend the notification item with paid-success and cancellation notifications.
- Update Documentation Feature Match rows 6, 7, and 8.
- Update Testing/basic verification with the exact fresh counts from Steps 1-2.
- Update milestones M2-M4 to reflect delivered scope without claiming deployment.
- Append a Heading 1 section named `8. PayOS and Reservation Management Update (July 2026)` containing configuration, backend, Flutter, cancellation-policy, notification, and verification bullets.
- Append a final note that PayOS dashboard webhook setup and live low-value payment smoke testing remain deployment responsibilities.

Save back to the original requested path only after the updater succeeds on a copied working file and structural checks pass.

- [ ] **Step 5: Run the updater with the bundled runtime**

```powershell
& "C:\Users\LUYENNGOC\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" ".tmp-docx-payment-flow\update_implementation_plan.py"
```

Expected: script reports every targeted paragraph/table replacement exactly once and writes the updated DOCX.

- [ ] **Step 6: Run structural document QA**

Use the bundled Python runtime to reopen the final DOCX and assert:

- all original tables still exist;
- the title and existing Heading 1 sections remain;
- the new Heading 1 text exists once;
- no placeholder markers, internal tool tokens, or broken empty table cells were introduced;
- the ZIP package opens without error.

- [ ] **Step 7: Attempt the required render and inspect every page**

```powershell
& "C:\Users\LUYENNGOC\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" "C:\Users\LUYENNGOC\.codex\plugins\cache\openai-primary-runtime\documents\26.709.11516\skills\documents\render_docx.py" "C:\FPTUniversity\BINGCOOK\BingCook_Implementation_and_Grading_Plan.docx" --output_dir "C:\FPTUniversity\BINGCOOK\.tmp-docx-payment-flow\rendered" --emit_pdf
```

Expected when LibreOffice is installed: one PNG per page. Open every page at 100% and verify no clipping, overlap, table breakage, missing glyphs, or misplaced headers/footers. If `soffice` is unavailable, retain the structural QA result and explicitly disclose that the render gate could not run.

- [ ] **Step 8: Perform non-mutating deployment readiness checks**

Verify:

```text
GET https://bingcook-api.mascoteach.com/api/products -> HTTP 200
GET https://bingcook-api.mascoteach.com/api/payments/payos/return -> non-mutating acknowledgement
```

Do not claim the live deployed API contains the new code until the team deploys the backend. Record the required PayOS dashboard webhook URL and production Flutter `--dart-define` command in the final handoff.

- [ ] **Step 9: Final requirement audit**

Re-read the approved spec and verify all eleven acceptance criteria against code, tests, configuration, and the updated DOCX. Report any unmet deployment-only item separately from local implementation completion.
