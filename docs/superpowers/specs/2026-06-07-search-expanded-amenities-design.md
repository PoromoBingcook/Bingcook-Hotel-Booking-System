# Search Expanded With Amenities Design

## Scope

Implement the Figma "Search - Expanded with Amenities" screen opened from the
Explore search card. The feature is presentation-only and uses hard-coded
initial values. No repository, service, use case, backend request, or Explore
result filtering is included.

## Architecture

- Keep the feature under `ui/features/search/`.
- `SearchViewModel` extends `ChangeNotifier` and owns all mutable presentation
  state.
- The search view receives its ViewModel through its constructor and renders
  state with `ListenableBuilder`.
- Feature widgets remain under `ui/features/search/widgets/`.
- Explore requests the search mode through an injected callback.
- `MainShell` owns both bottom-navigation state and whether Explore or Search is
  visible. This keeps the existing bottom navigation mounted and interactive.
- Search state remains feature-local and is not stored by Explore.

## Initial State

- Destination: `Da Nang`
- Check-in: June 12, 2023
- Check-out: June 15, 2023
- Adults: 2
- Children: 0
- Selected amenity: `Self check-in`
- Other amenities: `Wi-Fi`, `Pool`, `Parking`, `AC`, `Breakfast`, and
  `Pet allowed`

Dates are deterministic presentation values rather than values derived from
the current clock.

## Interaction

1. Tapping the Explore search card opens the search screen.
2. Tapping the close icon returns to Explore.
3. Tapping the destination clear icon empties the destination.
4. Tapping a calendar date starts or updates the selected date range:
   - When a complete range is displayed, the next tap starts a new range and
     clears check-out.
   - With only check-in selected, a later date sets check-out.
   - With only check-in selected, the same or an earlier date replaces
     check-in and keeps check-out empty.
5. Adult decrement stops at 1.
6. Child decrement stops at 0.
7. Increment controls increase their matching guest count.
8. Amenity chips toggle independently.
9. The Search button is enabled and visually interactive but does not navigate,
   update Explore, or fetch results in this scope.
10. Bottom-navigation controls remain usable and switch to the existing shell
    destinations.

## Components

- `SearchView`: page composition, scrolling, and close callback.
- `SearchViewModel`: destination, dates, guest counts, amenity selection, and
  intention-revealing commands.
- `SearchDestinationField`: labeled destination value and clear action.
- `SearchCalendar`: deterministic month grid and date-range presentation.
- `GuestCounterCard`: adult and child counter rows.
- `AmenitySelector`: reusable wrapping chip group.
- Existing `AppBottomNavigation`: unchanged shared navigation component.

The page uses project colors and typography. New repeated visual values are
added to project tokens only when they are shared or semantically meaningful.

## Layout And Accessibility

- Use `SafeArea` and a constrained centered phone layout consistent with
  Explore.
- Keep the header and bottom navigation fixed while the form content scrolls.
- Support narrow screens and text scaling without overflow.
- Give icon-only close, clear, increment, and decrement controls tooltips and
  semantic labels.
- Disabled decrement controls remain visible with reduced contrast.
- Interactive controls maintain practical Android tap targets.

## Testing

- Unit-test `SearchViewModel` date selection, counter boundaries, destination
  clearing, and amenity toggling.
- Widget-test Explore search-card navigation and close behavior.
- Widget-test Search screen interactions and visible state changes.
- Keep the existing bottom-navigation selection test green.
- Run formatting, analysis, the complete Flutter test suite, and Android debug
  build.
- Visually inspect the runnable UI against the supplied Figma screenshot.

## Out Of Scope

- Destination entry or autocomplete
- Month navigation
- Persisting search state after leaving the screen
- Updating the Explore summary
- Filtering stays or displaying search results
- Backend, repository, domain, or service layers
