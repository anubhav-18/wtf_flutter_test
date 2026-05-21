# AI Ledger

This ledger records the AI-assisted work for the WTF Flutter Engineer assessment.

## Prompt #1 — Project Scaffolding
**Timestamp**: 2026-05-21 15:30 IST
**Tool**: Cascade (Claude 3.5 Sonnet)
**Intent**: Scaffolding two apps and a shared package in a monorepo setup.
**Prompt**: "Create a Flutter monorepo with `guru_app`, `trainer_app`, and a `shared` package. Set up Riverpod, Google Fonts, and the folder structure according to the assessment docs. Also initialize a small Node Express server in `token_server` for the 100ms tokens."
**Output Summary**: Scaffolded the three packages. Added `shared` as a path dependency in both apps.
**Commit**: `881a56c chore: scaffold shared package and token server`

## Prompt #2 — Architecture Decision (Hive vs REST)
**Timestamp**: 2026-05-21 16:15 IST
**Tool**: Antigravity (Gemini 1.5 Pro)
**Intent**: Figuring out how to sync data between physical device and emulator locally.
**Problem**: I originally planned to use Hive for local storage, polling it to simulate real-time updates.
**Prompt**: "I am running the Trainer app on a local Android emulator and the Guru app on a physical Android device. I am using Hive for local storage. How can I make changes in one app reflect in the other in real-time without a cloud backend?"
**AI Response**: Suggested options: 1. Firebase (ruled out as I wanted to keep it strictly local), 2. Local HTTP Server in one of the apps (too complex to maintain state), 3. Extending the existing 100ms Node token server to hold in-memory state.
**Adaptation**: Option 3 was brilliant. Since I already needed the Node server for 100ms tokens, I expanded it to be a tiny REST API with in-memory arrays for users, messages, and calls. Hive is now just used for local device flags (like onboarded state). Added ADR-5 to DECISIONS.md.
**Commit**: `191b3ff fix: migrate shared data to REST backend — fix cross-emulator sync`

## Prompt #3 — REST API Polling Bug
**Timestamp**: 2026-05-21 16:40 IST
**Tool**: Cascade
**Intent**: Fixing a frozen UI issue caused by bad timer logic.
**Error**: "Flutter app UI freezes occasionally and timer stops firing when network is slow."
**Prompt**: "I switched my `Timer.periodic` polling from reading Hive to making HTTP GET requests. Now the UI stutters, and if I throttle the network, the polling just stops working and throws unhandled exceptions."
**AI Response**: The AI pointed out that `Timer.periodic` doesn't await async operations. If the HTTP request takes longer than the 300ms polling interval, multiple requests stack up. Also, unhandled exceptions inside the timer callback kill the timer.
**Adaptation**: AI provided a code snippet using `Timer(Duration, callback)` that re-schedules itself *after* the HTTP request completes. I implemented this in my `BasePollingRepository` and wrapped the HTTP call in a try/catch.
**Commit**: `191b3ff fix: migrate shared data to REST backend` (Included in the migration)

## Prompt #4 — UI Redesign
**Timestamp**: 2026-05-21 17:10 IST
**Tool**: Antigravity
**Intent**: Styling
**Prompt**: "The assessment says 'Clean, modern, no clutter'. Generate a premium Dark Theme `AppTheme` class for Flutter using Inter font, rounded cards, and filled buttons."
**Output Summary**: Generated `app_theme.dart` with a dark color scheme (`#0E0E12` scaffold bg).
**Adaptation**: I tweaked the primary colors. I used `#E50914` for Trainer App and `#1769E0` for Guru app as requested in the rubric.

## Prompt #5 — Chat Bubble Attachments
**Timestamp**: 2026-05-21 17:45 IST
**Tool**: Cascade
**Intent**: Generating chat bubble UI with image support (bonus task).
**Prompt**: "Write a Flutter `MessageBubble` widget that supports text and optional base64 image attachments. Use an `image_picker` to select the image. The bubble should have a 'tail' on the sender's side."
**Output Summary**: Provided a `ClipRRect` wrapped `Image.memory` implementation and the `image_picker` logic.
**Adaptation**: The AI generated a basic square bubble. I manually added the `CustomPaint` tail for a WhatsApp-like look and handled the base64 encoding/decoding in the repository layer to keep the UI clean.
**Commit**: `753a54f fix+feat: 6 bug fixes + full UI redesign + chat attachments`

## Prompt #6 — Image Picker Android Permission Crash
**Timestamp**: 2026-05-21 18:00 IST
**Tool**: Cascade
**Intent**: Debugging
**Error**: `MissingPluginException(No implementation found for method pickImage)`
**Prompt**: "Flutter image_picker throws MissingPluginException on Android even after adding dependency. I ran flutter pub get, added READ_MEDIA_IMAGES permission. Still failing."
**AI Response**: Suggested running `flutter clean && flutter pub get` and ensuring the plugin is listed in pubspec.yaml. Also suggested checking minSdkVersion ≥ 21.
**Adaptation**: I ran flutter clean, confirmed minSdk=21 in build.gradle, and then realized I had only added the dependency to `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`, but the code using it was inside `shared/lib/widgets`. I added the dependency to `shared/pubspec.yaml`.
**Result**: Picker now works.

## Prompt #7 — 100ms Video SDK Setup
**Timestamp**: 2026-05-21 18:30 IST
**Tool**: Antigravity
**Intent**: Boilerplate for 100ms SDK.
**Prompt**: "Generate a Flutter Riverpod service class that wraps `hmssdk_flutter`. It needs to fetch a token from `http://10.0.2.2:4000/token`, join a room, and expose a Stream of `HmsRoomState` containing remote peers and tracks."
**Output Summary**: Created `HmsService` implementing `HMSUpdateListener`. Provided the logic for `HMSSDK.build()`, `join()`, and the event callbacks.
**Commit**: `04a56cc feat(shared): add HmsService, InCallArgs, pre-join and in-call screens`

## Prompt #8 — 100ms "Waiting for Peer" Bug
**Timestamp**: 2026-05-21 19:15 IST
**Tool**: Antigravity
**Intent**: Debugging 100ms state updates.
**Problem**: When the second user joined the video call, the first user's screen didn't update and still showed "Waiting for peer".
**Prompt**: "I am using hmssdk_flutter. User 1 joins. User 2 joins. User 1's `onPeerUpdate` is not firing, or at least the UI isn't refreshing to show User 2's video."
**AI Response**: AI noted that depending on how the room is configured, `onPeerUpdate` might fire differently. It asked to see my listener.
**Adaptation**: I realized the SDK provides `onPeerListUpdate(List<HMSPeer> addedPeers, List<HMSPeer> removedPeers)`. I was completely ignoring this callback! Once I implemented it and added the new peers to my local state, the UI updated perfectly.
**Commit**: `753a54f fix+feat: 6 bug fixes + full UI redesign + chat attachments`

## Prompt #9 — Scheduler Conflict Validation Logic
**Timestamp**: 2026-05-21 20:00 IST
**Tool**: Cascade
**Intent**: Generating validation logic.
**Prompt**: "Write a Dart function to validate if a requested 30-minute time slot conflicts with an existing list of `CallRequest` objects that have `status == approved`. Return an error string or null."
**Output Summary**: Provided a clean function comparing `DateTime` ranges.
**Adaptation**: Modified it to ensure it also checks that the new time isn't in the past. Added this to `CallRepository.requestCall`.

## Prompt #10 — Generating Unit Tests
**Timestamp**: 2026-05-21 20:30 IST
**Tool**: Cascade
**Intent**: Writing required unit tests.
**Prompt**: "Write Flutter unit tests for the scheduler conflict validation logic you just wrote, and also for a function that calculates SessionLog duration based on start and end DateTimes."
**Output Summary**: Generated 16 test cases covering edge cases (overlapping start times, exactly adjacent times, past dates).
**Commit**: `2e191f2 test(shared): 16 unit tests for message, scheduler, session log`

## Prompt #11 — Filtering Past Calls
**Timestamp**: 2026-05-21 21:00 IST
**Tool**: Antigravity
**Intent**: Refactoring Upcoming Calls logic.
**Problem**: Completed calls were still showing in the "Upcoming Calls" list.
**Prompt**: "My upcoming calls list shows everything. How should I filter it so it only shows calls that haven't happened yet, giving a small buffer for late joins?"
**AI Response**: `requests.where((r) => r.scheduledFor.add(Duration(minutes: 30)).isAfter(DateTime.now()))`
**Adaptation**: Implemented this 30-minute buffer logic in both Guru and Trainer apps so meetings disappear 30 mins after their scheduled start time.

## Prompt #12 — Auto-assigning Trainer
**Timestamp**: 2026-05-21 21:15 IST
**Tool**: Cascade
**Intent**: Implementing Onboarding logic.
**Prompt**: "In my Guru app onboarding, I need to create a profile and auto-assign the user to 'Aarav (Lead Trainer)'. Write the Riverpod provider method for this."
**Output Summary**: Wrote `AuthRepository.completeOnboarding` which makes a POST to `/users`.

## Prompt #13 — Exact UI Copy Matches
**Timestamp**: 2026-05-21 21:40 IST
**Tool**: Antigravity
**Intent**: Final Polish
**Prompt**: "The assessment requires exact UI copy like 'Call request declined. Reason: {text}.' Can you scan my codebase and ensure I have exact matches for Section 11 of the rubric?"
**Output Summary**: AI found that my My Requests screen and Schedule Call toast didn't match perfectly. I used the AI to perform a multi-file replace to fix the exact strings.

## Prompt #14 — Implementing 10-Minute Join Window Guard
**Timestamp**: 2026-05-21 21:55 IST
**Tool**: Cascade
**Intent**: Refinement
**Prompt**: "Write a Dart method that checks if a `DateTime scheduledFor` is within 10 minutes from `DateTime.now()` (either past or future). I want to conditionally show the 'Join Call' button."
**Output Summary**: Provided `final diff = scheduledFor.difference(DateTime.now()).inMinutes; return diff <= 10 && diff >= -30;`
**Adaptation**: Integrated into `UpcomingCallCard` so users can't join calls hours in advance.

## Prompt #15 — README Documentation
**Timestamp**: 2026-05-21 22:15 IST
**Tool**: Antigravity
**Intent**: Generating final README.
**Prompt**: "Generate a professional README.md for this monorepo. It needs instructions to run the Node token server, and how to build/run the Flutter apps. Mention that it uses Riverpod and 100ms."
**Output Summary**: Created a well-structured README with a features matrix and clear setup instructions.
