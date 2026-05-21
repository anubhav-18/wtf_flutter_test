# Requirements

This document captures the assessment requirements for the Guru ↔ Trainer local-first Flutter system.

## Functional requirements

- Build two Android Flutter apps:
  - Guru App for member `DK`.
  - Trainer App for trainer `Aarav (Lead Trainer)`.
- Provide mock auth and first-run state persistence.
- Guru first-run flow:
  - Splash.
  - Two-slide onboarding.
  - DK profile screen with name prefilled as `DK`.
  - Trainer selection from seeded trainers.
  - Auto-assign DK to Aarav.
  - Land on dashboard with Chat, Schedule Call, and My Sessions cards.
- Trainer first-run flow:
  - Splash.
  - Mock login as Aarav.
  - Land on dashboard with Members, Chats, Requests, and Sessions tiles.
- Implement chat:
  - Recent conversations.
  - Unread badges.
  - Last message preview.
  - Relative timestamps.
  - Left/right bubbles with Member blue and Trainer red.
  - Typing indicator with 400–800ms simulated delay.
  - Sent/read ticks.
  - Pull history.
  - Auto-scroll to latest message.
  - Quick replies.
  - Empty state with illustration and `Say hi` CTA.
- Implement scheduler:
  - Guru can pick from next 3 days.
  - 30-minute slots.
  - 140-character note limit.
  - Create `CallRequest.pending`.
  - Show request under My Requests.
  - Trainer can approve or decline with reason.
  - Prevent duplicate approved slot conflicts.
  - Approval creates `RoomMeta` and injects system chat message.
- Implement My Requests screen for Guru:
  - Shows pending, approved, declined, and cancelled requests.
  - Shows scheduled time, note, and declined reason.
- Implement Upcoming Calls module for both apps:
  - Shows approved calls.
  - Shows Join Call only inside the allowed join window.
  - Exposes chat toolbar camera icon with badge.
- Implement 100ms video calling:
  - Local token server under `token_server/`.
  - Endpoint `GET /token?userId=&role=`.
  - 100ms SDK integration in Flutter.
  - Pre-join device check.
  - Join/leave.
  - Mute/unmute.
  - Camera toggle.
  - Flip camera.
  - Reconnect loader.
  - Role mapping for trainer/member.
- Implement session logs:
  - Auto-created on call end.
  - Duration calculation.
  - Member rating and notes.
  - Trainer notes.
  - Filters: All, Last 7 days, This Month.
  - Latest-first sort.
- Implement DevPanel:
  - Floating `⋮` debug button.
  - Masked env values.
  - Build info.
  - Last 20 logs with `[CHAT]`, `[RTC]`, `[SCHEDULE]`, `[AUTH]` tags.
- Maintain `AI_LEDGER.md` throughout implementation.

## Non-functional requirements

- Android only.
- Must run locally without cloud backend.
- No Firebase.
- No websocket server.
- Hive local persistence.
- 300ms polling watcher for cross-process live UX.
- Riverpod state management.
- 100ms is the only external RTC dependency.
- Flutter lints enabled.
- Zero-warning target.
- Secrets must not be hardcoded.
- `.env.example` must be provided for token server.

## Acceptance tests

- Launch Trainer App and login as Aarav.
- Launch Guru App and onboard DK assigned to Aarav.
- DK sends `Hi Coach 👋`; Trainer sees unread badge and replies.
- DK schedules a call with note `Macros review`.
- DK sees request under My Requests as pending.
- Trainer approves request.
- DK sees system message and approved request state.
- Both apps show the call in Upcoming Calls.
- Both join via pre-join device check.
- Trainer toggles mute/video/flip.
- End call creates session logs.
- DK rates session and Trainer adds notes.
- Session list shows latest item first with rating and duration.

## Hard fail conditions

- No 100ms integration.
- No AI ledger.
- Apps do not run.
- Token server cannot provide 100ms tokens.
- Chat does not work both ways locally.

## Scoring rubric impact

- Architecture & Code Quality: shared layers, naming, linting, local-first design.
- Chat UX & Reliability: cross-app updates, statuses, typing, history, animations.
- Scheduler & Workflow: conflict validation and approve/decline clarity.
- 100ms Calls: SDK join/leave, roles, reconnection, device toggles.
- Session Logs & Ratings: captured duration, notes, filters.
- AI-Native Proof: meaningful ledger entries and commit evidence.
- Polish & DX: DevPanel, docs, error states, demo readiness.

## Risks

- Android app sandboxes do not share Hive data by default.
- 100ms SDK setup can be time-consuming.
- 300ms polling must avoid excessive rebuilds.
- Token server secrets must remain outside source control.
- Timebox requires skipping stretch features.

## Time critical items

- Chat first.
- Scheduler second.
- 100ms third.
- Session logs fourth.
- DevPanel and tests after P0 flow is stable.
