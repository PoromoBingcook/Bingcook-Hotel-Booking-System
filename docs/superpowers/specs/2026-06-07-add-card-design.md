# Add Card Details Design

## Goal

Open reusable Add Card Details screen when Checkout's Confirm Booking button is
pressed.

## Architecture

- Extend presentation-only `checkout` feature.
- `AddCardViewModel` owns save-for-future toggle state.
- `AddCardView` owns and disposes form controllers and mirrors holder/expiry
  input into visual card preview.
- Focused widgets render card preview, form, trust badges, and sticky footer.
- `MainShell` owns Add Card mode. Back restores Checkout.

## Interaction

- Cardholder, card number, expiry, and CVV fields are editable.
- Numeric fields use constrained input formatters.
- Save-for-future switch starts enabled and can toggle.
- Save and Continue remains no-op until next flow exists.

## Verification

One focused shell widget test covers Confirm Booking navigation, toggle state,
and back. Run formatter and analyzer.
