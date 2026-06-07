# Search Expanded With Amenities Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the interactive Search screen opened from Explore while keeping the existing bottom navigation mounted.

**Architecture:** `MainShell` owns whether Explore or Search is visible. A feature-local `SearchViewModel` owns deterministic presentation state, while small Search widgets render destination, calendar, guest counters, and amenities.

**Tech Stack:** Flutter, Dart, Material 3, `ChangeNotifier`, `ListenableBuilder`, `flutter_test`.

---

### Task 1: Search Presentation State

**Files:**
- Create: `test/ui/features/search/search_view_model_test.dart`
- Create: `lib/ui/features/search/view_models/search_view_model.dart`

- [x] Write failing unit tests proving initial state, destination clearing,
  date-range restart/completion, guest boundaries, and amenity toggling.
- [x] Run `flutter test test/ui/features/search/search_view_model_test.dart` and
  confirm failure because `SearchViewModel` does not exist.
- [x] Implement `SearchViewModel extends ChangeNotifier` with private state,
  read-only getters, and commands: `clearDestination`, `selectDate`,
  `incrementAdults`, `decrementAdults`, `incrementChildren`,
  `decrementChildren`, and `toggleAmenity`.
- [x] Re-run focused tests and confirm they pass.

### Task 2: Shell Navigation Behavior

**Files:**
- Modify: `test/ui/features/explore/main_shell_test.dart`
- Modify: `lib/ui/features/explore/views/explore_view.dart`
- Modify: `lib/ui/features/navigation/views/main_shell.dart`

- [x] Add failing widget tests proving the Explore search card opens Search,
  close returns to Explore, and bottom navigation leaves Search mode.
- [x] Run `flutter test test/ui/features/explore/main_shell_test.dart` and
  confirm failure because the card has no action and Search view is absent.
- [x] Add `onSearchRequested` to `ExploreView`, make the card semantic and
  tappable, and make `MainShell` switch its first destination between
  `ExploreView` and `SearchView`.
- [x] Re-run focused shell tests after Task 3 supplies `SearchView`.

### Task 3: Search Screen Components

**Files:**
- Create: `test/ui/features/search/search_view_test.dart`
- Create: `lib/ui/features/search/views/search_view.dart`
- Create: `lib/ui/features/search/widgets/search_destination_field.dart`
- Create: `lib/ui/features/search/widgets/search_calendar.dart`
- Create: `lib/ui/features/search/widgets/guest_counter_card.dart`
- Create: `lib/ui/features/search/widgets/amenity_selector.dart`

- [x] Add failing widget tests proving the initial Figma content renders and
  clear, date, guest, and amenity controls update visible state.
- [x] Run `flutter test test/ui/features/search/search_view_test.dart` and
  confirm failure because Search widgets do not exist.
- [x] Build reusable widgets using project colors, semantic labels, tooltips,
  and responsive constraints.
- [x] Compose `SearchView` with fixed header, scrollable form, fixed Search
  button area, and the deterministic June 2023 calendar.
- [x] Run Search and shell focused tests until green.

### Task 4: Verification And Visual Inspection

**Files:**
- Modify only files required by formatter or focused fixes.

- [x] Run `dart format lib test`.
- [x] Run `dart format --output=none --set-exit-if-changed lib test`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test`.
- [x] Run `flutter build apk --debug`.
- [x] Launch the available Flutter target and inspect Search against the
  supplied screenshot for overflow, scrolling, tap targets, and bottom
  navigation behavior.
- [x] Review `git diff --check` and `git status --short`, preserving unrelated
  user changes.
