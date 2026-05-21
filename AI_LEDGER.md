# AI Ledger

This ledger records the actual AI-assisted work used for the WTF Flutter Engineer assessment. Target: 15 meaningful entries across architecture, generation, debugging, refactor, tests, and docs.

## Prompt #1

**Timestamp**: 2026-05-21 15:28 IST

**Tool**: Cascade

**Intent**: Architecture

**Prompt**: `Read the assessment file and build a strict source-of-truth plan. Do not code yet. Capture hard-fail conditions, reviewer flow, 100ms requirements, AI ledger requirements, and local-first constraints.`

**Output Summary**: Created a line-by-line implementation plan covering two apps, Hive local storage, 300ms polling watcher, Riverpod, 100ms token server, chat, scheduler, My Requests, Upcoming Calls, Session Logs, DevPanel, tests, and demo checklist.

**Files Modified**: `plan.md`

**Commit**: Not committed separately; plan.md is a working planning artifact.

**Decision**: Treat the `.txt` assessment as source of truth and skip stretch features until required flows pass.

---

## Prompt #2

**Timestamp**: 2026-05-21 15:36 IST

**Tool**: Cascade

**Intent**: Requirement correction

**Prompt**: `Upcoming Calls module and My Requests screen are required. Re-read the assessment line-by-line and update the plan.`

**Output Summary**: Confirmed `My Requests` from schedule flow and `Upcoming Calls list` from join-call flow. Updated the plan to make both explicit modules, added manual reviewer steps for checking them, and added them to the submission checklist.

**Files Modified**: `plan.md`

**Commit**: Not committed separately; plan.md remains the source-of-truth planning artifact.

**Decision**: My Requests and Upcoming Calls are required P0 screens, not implied UI states.

---

## Prompt #3

**Timestamp**: 2026-05-21 15:43 IST

**Tool**: Cascade

**Intent**: Docs

**Prompt**: `Start implementing step by step. First create the required root docs and AI ledger baseline before writing app code.`

**Output Summary**: Generated root assessment documentation: README, requirements, architecture, ADRs, task breakdown, implementation plan, and initial AI ledger.

**Files Modified**: `README.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `TASK_BREAKDOWN.md`, `IMPLEMENTATION_PLAN.md`, `AI_LEDGER.md`

**Commit**: `419178e docs: add assessment planning baseline`

**Decision**: Front-load docs because AI-native evidence and architecture explanation are scoring requirements.

---

## Prompt #4

**Timestamp**: 2026-05-21 15:48 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: `Continue with Phase 3 and Phase 4. Scaffold shared package and token server, then implement immutable models and repository/service skeletons. Keep it local-first and lint-clean.`

**Output Summary**: Added `shared/` package, `token_server/`, immutable models, JSON helpers, copyWith/equality, polling repository base, concrete repositories, services, Riverpod providers, and shared widgets. Ran `flutter analyze` on `shared` and fixed the unnecessary library-name lint.

**Files Modified**: `shared/`, `token_server/`, `guru_app/pubspec.yaml`, `trainer_app/pubspec.yaml`, `AI_LEDGER.md`

**Commit**: `881a56c chore: scaffold shared package and token server`

**Decision**: Avoid code generation/freezed to save setup time; manual immutable models are acceptable for the 6-hour assessment.

---

## Prompt #5

**Timestamp**: 2026-05-21 15:58 IST

**Tool**: Cascade

**Intent**: Refactor / repo hygiene

**Prompt**: `Check git status after pub get. Clean up anything that should not be committed.`

**Output Summary**: Found `shared/.dart_tool` and `.flutter-plugins-dependencies` committed by mistake after `flutter pub get`. Added root ignores for Flutter, Node, build, and env artifacts; removed generated tool state from Git.

**Files Modified**: `.gitignore`, removed tracked `shared/.dart_tool/*`, removed tracked `shared/.flutter-plugins-dependencies`

**Commit**: `b9c4a48 chore: ignore generated tool artifacts`

**Decision**: Keep generated local tool state out of version control to make the repo cleaner for review.

---

## Prompt #6

**Timestamp**: 2026-05-21 16:01 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: `Implement the first runnable app flows: shared bootstrap, Guru splash/onboarding/profile/dashboard, and Trainer splash/mock login/dashboard.`

**Output Summary**: Added `AppBootstrap.init()`, seeded DK/Aarav users, implemented Guru onboarding/profile/dashboard shell with role badge and required cards, and implemented Trainer mock login/dashboard shell with required tiles.

**Files Modified**: `shared/lib/services/app_bootstrap.dart`, `shared/lib/services/services.dart`, `guru_app/lib/main.dart`, `trainer_app/lib/main.dart`

**Commit**: `feat: add first-run app shells`

**Decision**: Keep early screens in `main.dart` temporarily for speed, then split once chat/scheduler modules grow.

---

## Prompt #7

**Timestamp**: 2026-05-21 16:02 IST

**Tool**: Cascade

**Intent**: Debugging

**Prompt**: `Guru app failed due to missing flutter_riverpod dependency.`

**Error**:

```text
info - The imported package 'flutter_riverpod' isn't a dependency of the importing package - lib/main.dart:2:8 - depend_on_referenced_packages
Target of URI doesn't exist: package:flutter_riverpod/flutter_riverpod.dart
```

**AI Fix**: Add `flutter_riverpod` as a direct dependency to both `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`, because both apps import `package:flutter_riverpod/flutter_riverpod.dart` directly. Run `flutter pub get` and re-run `flutter analyze` for both apps.

**Files Modified**: `guru_app/pubspec.yaml`, `trainer_app/pubspec.yaml`, `guru_app/pubspec.lock`, `trainer_app/pubspec.lock`

**Commit**: `fix: add missing riverpod dependency`

**Decision**: App packages must declare direct dependencies they import, even if the shared package also depends on them.

---

## Prompt #8

**Timestamp**: 2026-05-21 16:04 IST

**Tool**: Cascade

**Intent**: Dependency correction

**Prompt**: `Update dependency versions: riverpod ^3.2.1 and uuid ^4.5.3. Also fix the AI ledger because prompts are too generic and commits are pending everywhere.`

**Output Summary**: Rewrote ledger entries with concrete prompts, errors, files, and commit references. Updated `flutter_riverpod` and `uuid` constraints to requested versions.

**Files Modified**: `AI_LEDGER.md`, `shared/pubspec.yaml`, `guru_app/pubspec.yaml`, `trainer_app/pubspec.yaml`

**Commit**: `chore: repair ai ledger and dependency versions`

**Decision**: Ledger entries should read like audit evidence, not generic summaries.

---

## Prompt #9

**Timestamp**: 2026-05-21 16:45 IST

**Tool**: Cascade

**Intent**: Refactor

**Prompt**: `For UI, make proper file. Do not combine every code in single main.dart. Make a proper folder structure.`

**Output Summary**: Refactored both Flutter apps so `main.dart` only bootstraps dependencies and runs the app. Moved Guru UI into `app/`, `screens/`, and `widgets/`. Moved Trainer UI into `app/`, `screens/`, and `widgets/`. Added the Trainer Members CRM screen and member detail screen as the next planned UI module.

**Debugging Evidence**:

```text
flutter analyze guru_app: No issues found
flutter analyze trainer_app: No issues found
```

**Files Modified**: `guru_app/lib/main.dart`, `guru_app/lib/app/guru_app.dart`, `guru_app/lib/screens/*`, `guru_app/lib/widgets/*`, `trainer_app/lib/main.dart`, `trainer_app/lib/app/trainer_app.dart`, `trainer_app/lib/screens/*`, `trainer_app/lib/widgets/*`

**Commit**: `refactor: split app ui into screen files`

**Decision**: Keep each app entry point minimal and place UI by responsibility so upcoming chat, scheduler, calls, and sessions can be implemented without bloating `main.dart`.

---

## Prompt #10

**Timestamp**: 2026-05-21 17:05 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: `Start Implementing Next Phase. Implement chat list + conversation UI with send/read state, quick replies, empty CTA, and navigation from both dashboards/member detail.`

**Output Summary**: Created shared reusable chat widgets `ChatListView` and `ConversationView` with quick replies, typing indicator, read receipts, and empty state CTA. Implemented Guru chat screens `ChatListScreen` and `ConversationScreen` wired to dashboard. Implemented Trainer chat screens `TrainerChatListScreen` and `TrainerConversationScreen`. Wired Trainer dashboard "Chats" tile and member detail "Chat" shortcut to navigation.

**Debugging Evidence**:

```text
flutter analyze guru_app: No issues found
flutter analyze trainer_app: No issues found
```

**Files Modified**: `shared/lib/widgets/chat_list_view.dart`, `shared/lib/widgets/conversation_view.dart`, `shared/lib/widgets/widgets.dart`, `guru_app/lib/screens/chat_list_screen.dart`, `guru_app/lib/screens/conversation_screen.dart`, `guru_app/lib/widgets/dashboard_card.dart`, `guru_app/lib/screens/guru_dashboard_screen.dart`, `trainer_app/lib/screens/trainer_chat_list_screen.dart`, `trainer_app/lib/screens/trainer_conversation_screen.dart`, `trainer_app/lib/screens/trainer_dashboard_screen.dart`, `trainer_app/lib/screens/member_detail_screen.dart`

**Commit**: `feat: implement chat ui`

**Decision**: Use shared widgets for chat UI to avoid duplication between Guru and Trainer apps. Parameterize with currentUserId, peerName, and primaryColor for app-specific styling.

---

## Prompt #11

**Timestamp**: 2026-05-21 17:15 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: `Start Implementing Next Phase. And also state how much left out of 100, and what tasks as well.`

**Output Summary**: Implemented the Guru `MyRequestsScreen` using `callRequestsStreamProvider`. The screen lists member requests across pending, approved, declined, and cancelled statuses, displays scheduled time, note, requested-relative time, and declined reason where available. Wired the Guru dashboard `My Requests` card to open the screen.

**Debugging Evidence**:

```text
flutter analyze guru_app: No issues found
```

**Files Modified**: `guru_app/lib/screens/my_requests_screen.dart`, `guru_app/lib/screens/guru_dashboard_screen.dart`, `AI_LEDGER.md`

**Commit**: `feat: add guru my requests screen`

**Decision**: Keep request history as a read-only member-facing view for this phase; request creation and trainer approval actions remain separate scheduler/request-management phases.

---

## Prompt #12

**Timestamp**: 2026-05-21 17:23 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: `Now, I want you to complete Schedule Call UI & Trainer Requests Management.`

**Output Summary**: Implemented Guru `ScheduleCallScreen` with date picker, time picker, note input, 140-character helper, validation through `callServiceProvider.requestCall`, success feedback, and redirect to `MyRequestsScreen`. Implemented Trainer `TrainerRequestsScreen` with pending-first request list, scheduled time, member summary, note, declined reason, approve action, decline dialog, and repository-backed conflict feedback. Wired Guru dashboard `Schedule Call`, Trainer dashboard `Requests`, and member detail `Requests` shortcut.

**Debugging Evidence**:

```text
flutter analyze guru_app: No issues found
flutter analyze trainer_app: No issues found
```

**Files Modified**: `guru_app/lib/screens/schedule_call_screen.dart`, `guru_app/lib/screens/guru_dashboard_screen.dart`, `trainer_app/lib/screens/trainer_requests_screen.dart`, `trainer_app/lib/screens/trainer_dashboard_screen.dart`, `trainer_app/lib/screens/member_detail_screen.dart`, `AI_LEDGER.md`

**Commit**: `feat: add scheduling request flows`

**Decision**: Keep scheduling validation centralized in the shared `CallRepository`/`Validators` layer and have UI surface returned errors as SnackBars, especially for approved-slot conflicts.

---

## Prompt #13

**Timestamp**: 2026-05-21 18:05 IST

**Tool**: Antigravity (Gemini)

**Intent**: Generation — 100ms HMS Service

**Prompt**: `Implement Phase 2: Shared HMS Service (hms_service.dart). Wrap HMSSDK with token fetch, join/leave, mic/cam toggle, auto-reconnect up to 3 times, and a state stream.`

**Output Summary**: Created `shared/lib/services/hms_service.dart` implementing `HMSUpdateListener` and `HMSActionResultListener`. The service fetches a short-lived JWT from `AppConstants.tokenServerBaseUrl/token`, calls `HMSSDK.build()` and `join()`, emits `HmsRoomState` via a broadcast `StreamController`, handles `onPeerUpdate`/`onTrackUpdate`/`onHMSError`, auto-reconnects on error (up to 3 attempts with 2 s delay), and tears down cleanly on `leave()`. Added `hmsServiceProvider` (autoDispose) and `hmsStateProvider` (StreamProvider) to `app_providers.dart`.

**Debugging Evidence**:

```
flutter analyze shared: No issues found
```

**Files Modified**: `shared/lib/services/hms_service.dart` [NEW], `shared/lib/services/services.dart`, `shared/lib/providers/app_providers.dart`, `shared/lib/models/in_call_args.dart` [NEW]

**Commit**: `feat: add HmsService with token fetch, join/leave, auto-reconnect`

**Decision**: Used `Provider.autoDispose` so each in-call screen gets its own HMSSDK lifecycle, automatically cleaned up when the route is popped. This avoids SDK state leaking across multiple calls.

---

## Prompt #14

**Timestamp**: 2026-05-21 18:30 IST

**Tool**: Antigravity (Gemini)

**Intent**: Generation — Full Video Call UI Pipeline

**Prompt**: `Implement Phases 3-7: Upcoming Calls screens, Pre-join device check, InCallScreen, Session Logs, Post-call sheets. Wire all routes in both apps.`

**Output Summary**: UpcomingCallCard with 10-min join window guard; shared PreJoinScreen with mic/camera toggles; shared InCallScreen with HMSVideoView remote/PiP self-preview, duration timer, ControlBar, overlays; both apps get session logs with filter chips; post-call rating (Guru) and notes (Trainer) sheets. Wired all routes. Added Android permissions for camera/mic/bluetooth.

**Debugging Evidence**:

```
flutter analyze shared:      No issues found
flutter analyze guru_app:    No issues found
flutter analyze trainer_app: No issues found
```

**Files Modified**: 14 new/modified files across shared/, guru_app/, trainer_app/.

**Commit**: `feat: complete video call pipeline`

**Decision**: PreJoinScreen and InCallScreen live in shared/lib/screens/ so both apps reuse identical logic without code duplication.

---

## Prompt #15

**Timestamp**: 2026-05-21 18:55 IST

**Tool**: Antigravity (Gemini)

**Intent**: Tests + Documentation

**Prompt**: `Write 3 unit test files (message serialization, scheduler conflict validation, session log duration). Run flutter test and fix failures. Update README.`

**Output Summary**: 16 tests across 3 files. First run failed because test assumed wrong Message field names (content/isRead vs text/status). Fixed and all 16 pass. README rewritten with quick-start, demo table, token server setup, test command, features matrix.

**Debugging Evidence**:

```
flutter test shared: 00:00 +16: All tests passed!
```

**Files Modified**: `shared/test/message_serialization_test.dart` [NEW], `shared/test/scheduler_validation_test.dart` [NEW], `shared/test/session_log_duration_test.dart` [NEW], `README.md`

**Commit**: `test: add 16 unit tests for message, scheduler, session log`

**Decision**: Pure Dart unit tests (no widget tests) to avoid Hive initialization complexity. They validate the JSON round-trips and conflict logic that matter most for demo correctness.

---
