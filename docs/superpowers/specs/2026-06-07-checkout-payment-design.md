# Checkout And Payment Design

## Goal

Open a reusable Checkout and Payment screen after Select Room's Continue to
Payment action.

## Architecture

- Add presentation-only `checkout` feature. No repository or service because
  all content is currently local and static.
- `CheckoutData` contains immutable summary, guest placeholders, payment
  methods, and price rows.
- `CheckoutViewModel` owns selected payment method.
- `CheckoutView` owns and disposes text controllers, composes focused reusable
  widgets, and receives navigation callbacks.
- `MainShell` owns checkout display mode. Back restores Select Room.

## Interaction

- Credit or Debit Card starts selected.
- Payment method cards are selectable.
- Guest fields are editable.
- Add a card, account, terms, and Confirm Booking are presentational/no-op.
- Header uses BingCook to preserve project product naming.

## Verification

One focused shell widget test covers Continue to Payment, payment selection,
and back navigation. Run formatter and analyzer after implementation.
