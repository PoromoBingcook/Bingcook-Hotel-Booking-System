# Checkout And Payment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build reusable Checkout and Payment UI and connect it to Select Room.

**Architecture:** Add a static presentation model, ChangeNotifier ViewModel,
focused checkout widgets, and a shell-owned checkout mode. Keep confirmation
and external links as no-op callbacks until later flows exist.

**Tech Stack:** Flutter, Dart, Material 3, ChangeNotifier, flutter_svg.

---

### Task 1: Focused Navigation Test

**Files:**
- Modify: `test/ui/features/explore/main_shell_test.dart`

- [x] Add one test for Select Room to Checkout, payment selection, and back.
- [x] Run focused test and confirm failure from missing checkout behavior.

### Task 2: Checkout Presentation Feature

**Files:**
- Create: `lib/ui/features/checkout/models/checkout_data.dart`
- Create: `lib/ui/features/checkout/models/checkout_content.dart`
- Create: `lib/ui/features/checkout/view_models/checkout_view_model.dart`
- Create: `lib/ui/features/checkout/views/checkout_view.dart`
- Create focused widgets under `lib/ui/features/checkout/widgets/`
- Modify: `lib/ui/core/constants/app_assets.dart`
- Modify: `pubspec.yaml`

- [x] Add immutable static UI data and payment state.
- [x] Build responsive summary, guest, payment, pricing, terms, and footer UI.
- [x] Register local checkout SVG assets.

### Task 3: Shell Integration And Docs

**Files:**
- Modify: `lib/ui/features/navigation/views/main_shell.dart`
- Modify: `AGENTS.md`

- [x] Connect Continue to Payment and back callbacks.
- [x] Document checkout architecture and navigation.

### Task 4: Minimal Verification

- [x] Run focused widget test.
- [x] Run formatter.
- [x] Run analyzer.
