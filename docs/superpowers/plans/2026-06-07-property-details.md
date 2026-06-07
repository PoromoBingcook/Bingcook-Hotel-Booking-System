# Property Details Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Open reusable Ocean Pearl Hotel details from Explore and match Figma node `10:459`.

**Architecture:** `MainShell` owns a Property Details display mode while keeping Explore selected. Immutable presentation data feeds a reusable `PropertyDetailsView`; a small `ChangeNotifier` owns favorite state.

**Tech Stack:** Flutter, Dart, Material 3, `ChangeNotifier`, `ListenableBuilder`, `flutter_test`.

---

### Task 1: Critical Flow Test

**Files:**
- Modify: `test/ui/features/explore/main_shell_test.dart`

- [x] Add one widget test proving Ocean Pearl opens Property Details, heart
  toggles, and back restores Explore.
- [x] Run `flutter test test/ui/features/explore/main_shell_test.dart` and
  confirm RED because StayCard has no tap callback and details UI is absent.

### Task 2: Reusable Property Details Feature

**Files:**
- Create: `lib/ui/features/property_details/models/property_details_data.dart`
- Create: `lib/ui/features/property_details/view_models/property_details_view_model.dart`
- Create: `lib/ui/features/property_details/views/property_details_view.dart`
- Create: `lib/ui/features/property_details/widgets/property_booking_card.dart`
- Create: `lib/ui/features/property_details/widgets/property_amenities_grid.dart`
- Create: `lib/ui/features/property_details/widgets/property_review_summary.dart`
- Create: `lib/ui/features/property_details/widgets/property_guest_review.dart`
- Modify: `lib/ui/core/constants/app_assets.dart`

- [x] Define immutable amenity, rating distribution, guest review, and property
  detail models with hard-coded Ocean Pearl data supplied by Explore.
- [x] Implement favorite state with `toggleFavorite`.
- [x] Implement reusable sections and compose responsive scrolling details UI.
- [x] Use `AppAssets.propertyDetails` for `detail.png`.

### Task 3: Explore And Shell Integration

**Files:**
- Modify: `lib/ui/features/explore/widgets/stay_card.dart`
- Modify: `lib/ui/features/explore/views/explore_view.dart`
- Modify: `lib/ui/features/navigation/views/main_shell.dart`

- [x] Add optional `onTap` to StayCard.
- [x] Add `onStaySelected` callback to Explore and pass Ocean Pearl data.
- [x] Make MainShell open/close details, keep Explore selected, pass a no-op
  Book Now callback, and exit details when bottom navigation changes.
- [x] Run focused shell test until GREEN.

### Task 4: Documentation And Verification

**Files:**
- Modify: `AGENTS.md`

- [x] Document Property Details feature and shell flow.
- [x] Run `dart format lib test`.
- [x] Run `dart format --output=none --set-exit-if-changed lib test`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test`.
- [x] Inspect details on Android emulator and fix visible overflow.
