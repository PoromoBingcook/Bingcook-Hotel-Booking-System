# Auth Success Explore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix Sign Up icon alignment and implement Login, animated Login
Success, Explore, and reusable bottom navigation from Figma.

**Architecture:** Use named routes for auth transitions and a stateful
`MainShell` for bottom navigation. Keep static UI in feature views/widgets,
with no artificial data or domain layers.

**Tech Stack:** Flutter, Dart, Material 3, flutter_svg, flutter_test.

---

### Task 1: Regression And Flow Tests

**Files:**
- Modify: `test/app_test.dart`
- Create: `test/ui/features/auth/auth_text_field_test.dart`
- Create: `test/ui/features/auth/login_success_view_test.dart`
- Create: `test/ui/features/explore/main_shell_test.dart`

- [x] Write tests for left icon alignment and new screen navigation.
- [x] Run `flutter test` and confirm failures come from missing behavior.

### Task 2: Routes And Auth UI

**Files:**
- Create: `lib/app/routes/app_routes.dart`
- Create: `lib/app/routes/app_router.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/ui/features/auth/widgets/auth_text_field.dart`
- Create: `lib/ui/features/auth/widgets/login_text_field.dart`
- Create: `lib/ui/features/auth/views/login_view.dart`
- Modify: `lib/ui/features/auth/views/sign_up_view.dart`

- [x] Constrain Sign Up prefix icons to the left.
- [x] Add named routes and wire Sign Up/Login navigation.
- [x] Implement Login from Figma using reusable auth components.
- [x] Run focused auth tests until green.

### Task 3: Animated Login Success

**Files:**
- Create: `lib/ui/features/auth/views/login_success_view.dart`

- [x] Add checkmark entrance and progress animation.
- [x] Navigate to Explore after progress completes.
- [x] Run focused success tests until green.

### Task 4: Explore And Bottom Navigation

**Files:**
- Modify: `lib/ui/core/constants/app_assets.dart`
- Create: `lib/ui/core/widgets/app_bottom_navigation.dart`
- Create: `lib/ui/features/explore/models/stay_card_data.dart`
- Create: `lib/ui/features/explore/widgets/stay_card.dart`
- Create: `lib/ui/features/explore/views/explore_view.dart`
- Create: `lib/ui/features/navigation/views/main_shell.dart`
- Modify: `pubspec.yaml`

- [x] Register Explore assets.
- [x] Implement reusable bottom navigation.
- [x] Implement Figma Explore screen and property cards.
- [x] Add simple destination placeholders for unfinished tabs.
- [x] Run focused navigation tests until green.

### Task 5: Documentation And Verification

**Files:**
- Modify: `AGENTS.md`

- [x] Document route ownership, navigation shell, and static UI data rules.
- [x] Run `dart format --output=none --set-exit-if-changed lib test`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test`.
- [x] Run `flutter build apk --debug`.
