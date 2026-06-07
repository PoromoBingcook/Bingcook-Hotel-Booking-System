# BingCook Agent Guide

This file defines mandatory implementation rules for all contributors and
coding agents working in this repository.

## Project Overview

- Product: BingCook
- Framework: Flutter
- Language: Dart
- Supported platform: Android
- UI system: Material 3 with project-owned design tokens
- Architecture: layered MVVM with feature-based presentation code
- State management: `ChangeNotifier` and `ListenableBuilder` unless project
  requirements justify another solution
- Assets: local assets declared in `pubspec.yaml`

Keep changes focused. Do not refactor unrelated code while implementing a
feature or bug fix.

## Source Structure

Use this structure as the project grows:

```text
lib/
|-- app/
|   |-- app.dart                 # Application composition and MaterialApp
|   |-- routes/                  # Route definitions and navigation setup
|   `-- dependencies/            # Dependency creation and injection
|-- data/
|   |-- models/                  # API, database, and DTO models
|   |-- repositories/            # Repository implementations
|   `-- services/                # HTTP, storage, database, platform wrappers
|-- domain/
|   |-- models/                  # Framework-independent business entities
|   |-- repositories/            # Repository contracts when abstraction helps
|   `-- use_cases/               # Reusable or complex business operations
|-- ui/
|   |-- core/
|   |   |-- constants/           # Asset paths and application constants
|   |   |-- theme/               # Colors, typography, spacing, and themes
|   |   `-- widgets/             # Shared widgets used by multiple features
|   `-- features/
|       `-- feature_name/
|           |-- models/          # Presentation-only immutable view data
|           |-- view_models/     # Presentation state and user actions
|           |-- views/           # Screens and page-level widgets
|           `-- widgets/         # Widgets private to this feature
`-- main.dart                    # Minimal application entry point

test/
|-- data/
|-- domain/
|-- ui/
`-- app_test.dart
```

Do not create empty layers or placeholder files. Add a directory when the
feature needs it.

## Dependency Direction

Dependencies must point inward:

```text
View -> ViewModel -> UseCase (optional) -> Repository -> Service
```

Rules:

- Views may depend on ViewModels, theme tokens, and widgets.
- Views must not call APIs, databases, repositories, or services directly.
- ViewModels own presentation state, validation, loading state, and user
  actions.
- ViewModels receive repositories or use cases through constructors.
- Repositories are the single source of truth for application data.
- Services are stateless wrappers around external systems.
- Data models must not leak into Views. Convert them to domain models first.
- Small immutable models used only to render static UI may live in a feature's
  `models/` directory. They must not contain API serialization or business
  rules.
- Domain code must not import Flutter UI libraries.
- Use cases are optional. Add one only for complex, reusable, or
  cross-repository business logic.
- Create dependencies in the application composition root. Do not instantiate
  services or repositories deep inside widgets.

## Feature Implementation Workflow

For each feature:

1. Inspect related code, tests, assets, and design references.
2. Define domain models only when the feature has business data.
3. Add or update services for external access.
4. Add repository contracts and implementations where needed.
5. Add a use case only if business logic does not belong in the ViewModel.
6. Write failing tests for behavior before production code.
7. Implement the ViewModel and expose read-only state.
8. Build small reusable widgets and then compose the View.
9. Register dependencies and routes at the application layer.
10. Format, analyze, and test the complete change.

Never add fake data-layer abstractions to a UI-only feature. For example, a
static splash screen needs no repository.

## View Rules

- Keep Views focused on rendering, layout, animation, navigation, and simple
  UI-only coordination.
- Pass dependencies explicitly through constructors.
- Use `const` constructors and widgets whenever possible.
- Dispose controllers, focus nodes, animation controllers, and owned
  ViewModels.
- Use `SafeArea` where system UI can overlap content.
- Support small screens, keyboard opening, text scaling, and scrolling.
- Do not place validation rules or business decisions in widget build methods.
- Do not create oversized screen files. Extract feature widgets when a section
  has its own responsibility or is reused.
- Prefer project widgets over repeated button, field, card, or header markup.
- Add semantic labels and tooltips for icon-only controls.

## ViewModel Rules

- Extend `ChangeNotifier` unless another project-wide state solution has been
  deliberately adopted.
- Keep mutable fields private.
- Expose immutable values or read-only getters.
- Provide intention-revealing commands such as `submit`, `retry`, or
  `togglePasswordVisibility`.
- Notify listeners only after observable state changes.
- Represent loading, success, empty, and failure states explicitly.
- Catch repository failures and convert them into user-safe presentation state.
- Never store `BuildContext`, widgets, controllers, or navigation objects in a
  ViewModel.
- Keep ViewModels independently unit testable.

## Data And Domain Rules

- Services perform raw external operations and return DTOs or structured
  results.
- Repositories coordinate services, caching, mapping, retry, and data
  consistency.
- Domain models use immutable fields and contain no JSON parsing or Flutter UI
  dependencies.
- Keep serialization inside data models.
- Do not parse structured data with ad hoc string operations.
- Do not silently swallow exceptions. Map known failures and preserve useful
  debugging context.
- Never expose secrets, tokens, or personal data in logs.

## UI And Design Consistency

- Match the approved Figma design before adding personal design choices.
- Use `AppColors`, `AppTheme`, and future project spacing or typography tokens.
- Do not scatter repeated color hex values, text styles, radii, or shadows
  through feature files.
- Register asset paths in `AppAssets`; do not repeat raw paths in widgets.
- Reuse assets already present in `assets/`.
- Shared widgets belong in `ui/core/widgets/` only when used by multiple
  features.
- Feature-specific widgets stay under that feature's `widgets/` directory.
- Keep the user-facing product name exactly `BingCook`.
- Preserve responsive behavior instead of hardcoding one device size.

## Naming And File Style

- Files and directories: `snake_case`
- Types and enums: `UpperCamelCase`
- Variables, methods, and parameters: `lowerCamelCase`
- Private members: leading underscore
- Views: `FeatureView`
- ViewModels: `FeatureViewModel`
- Repositories: `FeatureRepository`
- Services: `FeatureService`
- Use cases: action-oriented names such as `CreateAccountUseCase`
- Reusable widgets: purpose-oriented names such as `AuthTextField`

Keep one primary responsibility per file. Use package imports for files under
`lib/`:

```dart
import 'package:bingcook/ui/core/theme/app_colors.dart';
```

Follow `analysis_options.yaml`. Do not disable lints globally to avoid fixing
code.

## Navigation

- Keep route names and route construction in `lib/app/routes/`.
- Current route flow is `Splash -> Sign Up <-> Login -> Login Success ->
  Explore`.
- Inside `MainShell`, Explore can switch to Search or Property Details without
  changing the selected Explore bottom-navigation destination. Property
  Details can open Select Room through its Book Now callback. Select Room can
  open Checkout and Payment through its Continue to Payment callback.
- Views request navigation through callbacks or the chosen routing boundary.
- Do not spread hardcoded route strings across feature widgets.
- Navigation decisions based on business state belong in the app flow or
  presentation coordination layer, not repositories.
- `MainShell` owns the selected bottom-navigation destination.
- `MainShell` owns Search, Property Details, Select Room, and Checkout display
  modes and clears those modes when another bottom-navigation destination is
  selected.
- Select Room and Checkout hide bottom navigation. Checkout back restores
  Select Room; Select Room back restores Property Details.
- `AppBottomNavigation` is the reusable visual navigation component and must
  not own page content or feature state.
- Use `IndexedStack` in the main shell when tab state must survive navigation.
- New main destinations should be added to the shell and bottom-navigation
  definitions together, with a widget test covering selection.

## Current Feature Map

- `ui/features/splash/`: timed entry screen.
- `ui/features/auth/`: Sign Up, Login, Login Success, auth fields, and
  presentation state.
- `ui/features/explore/`: static Explore UI, local stay-card data, and cards.
- `ui/features/property_details/`: reusable data-driven Property Details view,
  favorite presentation state, booking card, amenities, rating summary, and
  guest reviews.
- `ui/features/select_room/`: reusable data-driven room selection view,
  nullable room selection state, computed stay total, room cards, and compact
  booking footer.
- `ui/features/checkout/`: reusable Checkout and Payment view, immutable local
  summary and pricing data, editable guest fields, selectable payment methods,
  terms, and fixed confirmation footer.
- `ui/features/navigation/`: application shell for Explore, Saved, Bookings,
  and Profile destinations.

Until backend work begins, Login, Explore, Search, Property Details, Select
Room, and Checkout remain presentation-only. Do not add repositories, services,
or use cases for static Figma content. `PropertyDetailsView` receives immutable
`PropertyDetailsData`, a `PropertyDetailsViewModel`, and navigation callbacks
so future properties and booking navigation can reuse the same component.
`SelectRoomView` receives immutable `SelectRoomData`, a `SelectRoomViewModel`,
and back/continue callbacks. No room is selected initially; selecting a room
updates the total for the configured number of nights. `CheckoutView` receives
immutable `CheckoutData`, a `CheckoutViewModel`, and back/confirm callbacks.
Guest controllers remain view-owned; payment selection remains ViewModel-owned.

## Testing

Use test-driven development for new behavior and bug fixes:

1. Write a focused failing test.
2. Run it and confirm failure is caused by missing behavior.
3. Add the smallest correct implementation.
4. Run the test until green.
5. Refactor while keeping tests green.

Required coverage:

- ViewModel validation, commands, and state transitions: unit tests
- Repository mapping, caching, and failure handling: unit tests
- Important screens, navigation, and user interactions: widget tests
- Critical end-to-end flows: integration tests when those flows exist

Mirror source paths under `test/` where practical. Avoid tests that only verify
implementation details.

## Packages And Generated Files

- Prefer Flutter SDK and existing packages before adding dependencies.
- Add a package only when it solves a real need and is actively maintained.
- Keep `pubspec.lock` committed for this application.
- Update `pubspec.yaml` when adding assets or fonts.
- Do not hand-edit generated plugin registrants or build output.
- Do not commit `.dart_tool/`, `build/`, IDE caches, or temporary logs.
- Change platform files only when the feature requires platform configuration.
- Do not regenerate iOS, web, Windows, macOS, or Linux targets unless the
  product scope explicitly expands beyond Android.

## Verification

After changing Dart files, run from repository root:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

When formatting reports changes, run `dart format lib test`, then repeat the
verification commands.

For UI changes, also run the app on a relevant target and inspect:

- layout at common phone sizes
- keyboard behavior
- scrolling and overflow
- loading, empty, error, and success states
- accessibility labels and tap targets
- visual match against Figma

Do not claim completion while required checks fail. Report exact failing
commands and relevant errors.

## Definition Of Done

A change is complete only when:

- Architecture boundaries remain intact.
- New behavior has appropriate tests.
- Reusable UI is extracted at the correct scope.
- No stale product names or placeholder demo content remain.
- Assets and dependencies are declared correctly.
- Formatting, analysis, and tests pass.
- UI changes were visually inspected when a runnable target is available.
- Unrelated user changes were not reverted.
