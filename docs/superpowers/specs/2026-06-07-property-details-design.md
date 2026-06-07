# Property Details Design

## Scope

Implement Figma node `10:459` as reusable, presentation-only Flutter UI.
Ocean Pearl Hotel data remains hard-coded. No backend, repository, service,
booking flow, or saved-stay persistence is included.

## Architecture

- Add feature under `ui/features/property_details/`.
- `PropertyDetailsData` contains immutable screen content.
- `PropertyDetailsViewModel` extends `ChangeNotifier` and owns favorite state.
- `PropertyDetailsView` accepts data, ViewModel, `onBack`, and `onBookNow`.
- Feature widgets render booking, amenities, review summary, and guest reviews.
- `MainShell` owns Explore, Search, and Property Details display modes.
- Existing `AppBottomNavigation` remains mounted with Explore active.
- `StayCard` accepts optional `onTap`; Ocean Pearl opens details.

## Behavior

- Tapping Ocean Pearl Hotel opens Property Details.
- Back returns to Explore.
- Heart toggles favorite state.
- Book Now invokes an injected callback. Current shell callback is a no-op so
  future booking navigation can be added without changing the component.
- Bottom-navigation selection exits details and opens selected destination.

## Content And Assets

- Use `assets/svg/explore/detail.png` through `AppAssets`.
- Render Ocean Pearl title, location, rating, booking dates, amenities,
  rating distribution, score, and two guest reviews from Figma.
- Preserve responsive scrolling, safe areas, semantic icon labels, and
  project-owned colors and typography.

## Testing And Verification

- Add one critical widget flow test: Ocean Pearl opens details, favorite
  toggles, and back restores Explore.
- Run focused test RED then GREEN.
- Run required repository checks: format verification, `flutter analyze`, and
  full `flutter test`.
- Visually inspect on available Android emulator.

## Documentation

Update `AGENTS.md` Current Feature Map and Navigation sections with Property
Details ownership, shell flow, reusable component contract, and static-data
status.
