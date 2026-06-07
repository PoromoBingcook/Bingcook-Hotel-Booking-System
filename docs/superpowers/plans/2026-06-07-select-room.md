# Select Room Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Navigate from Property Details Book Now to reusable interactive Select Room UI.

**Architecture:** MainShell owns Select Room mode. Immutable presentation data feeds `SelectRoomView`; `SelectRoomViewModel` owns selection, favorite state, and computed total.

**Tech Stack:** Flutter, Dart, Material 3, ChangeNotifier, flutter_test.

---

### Task 1: Critical Flow Test

- [x] Add one shell widget test for Book Now, initial `$0`, room selection
  `$255`, and back to Property Details.
- [x] Run focused test and confirm RED.

### Task 2: Reusable Select Room Feature

- [x] Add immutable room/select-room models and hard-coded content.
- [x] Add ViewModel with nullable selected room, favorite toggle, and total.
- [x] Add reusable property context, room card, footer, and composed view.
- [x] Register all Select Room assets in `AppAssets` and `pubspec.yaml`.

### Task 3: Shell Integration

- [x] Wire Property Details Book Now to Select Room.
- [x] Back restores Property Details.
- [x] Hide bottom navigation during Select Room.
- [x] Run focused flow test until GREEN.

### Task 4: Documentation And Verification

- [x] Update `AGENTS.md`.
- [x] Run format verification, analyzer, and full tests once.
- [x] Inspect Android render and fix visible overflow.
