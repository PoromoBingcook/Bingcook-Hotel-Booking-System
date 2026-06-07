# Select Room Design

## Scope

Implement Figma node `10:653` as reusable presentation-only Flutter UI opened
from Property Details Book Now. Data remains hard-coded. Continue to Payment
has an injected callback but no navigation yet.

## Architecture

- Add `ui/features/select_room/`.
- Immutable `SelectRoomData` contains hotel context, nights, and room options.
- `SelectRoomViewModel` extends `ChangeNotifier` and owns nullable room
  selection plus favorite state.
- `SelectRoomView` accepts data, ViewModel, `onBack`, and `onContinue`.
- Feature widgets render property context, room cards, and fixed booking footer.
- `MainShell` owns Select Room mode. Book Now opens it; back restores Property
  Details.
- Bottom navigation is hidden on Select Room, matching Figma.

## Behavior

- No room selected initially; total is `$0`.
- Tapping a room selects it and updates total to nightly price multiplied by
  three nights.
- Heart toggles favorite.
- Back returns Property Details.
- Continue to Payment invokes callback only; current callback is no-op.
- Footer uses a compact button so total and action never overlap.

## Assets

Use local images from `assets/svg/select-room/`:

- `deluxe-ocean-view.png`
- `double-room.png`
- `executive-suit.png`

## Verification

- One critical flow test covers Book Now navigation, initial zero total, room
  selection total, and back.
- Run format verification, analyzer, full existing tests once, and Android
  visual inspection.
- Update `AGENTS.md` navigation and feature tracking.
