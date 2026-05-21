# WTF Flutter Assessment Source-of-Truth Plan

This plan follows the provided assessment text as the source of truth and maps implementation work directly to its deliverables, acceptance tests, scoring rubric, and hard-fail conditions.

---

## Source-of-Truth Rules

- **Timebox**: 6 hours hard stop.
- **Apps**: `guru_app` (Member DK) and `trainer_app` (Trainer Aarav).
- **Backend**: Local-first, no Firebase, no websocket server.
- **RTC**: 100ms SDK mandatory, with local `token_server/`.
- **Storage**: Hive local persistence plus polling watcher for cross-process “live” UX.
- **AI Proof**: `AI_LEDGER.md` required with meaningful prompts, outputs, files, commits, debugging, refactor, docs, and tests.
- **Hard fail**: No 100ms integration, no AI ledger, or apps do not run.
- **No excuses rule**: If any required feature is incomplete at submission time, document the reason and fallback clearly in README/IMPLEMENTATION_PLAN.

---

## Corrected Architecture

The two Flutter apps are separate Android processes, so in-memory streams alone are not enough.

```text
Hive persistence
  ↓
Repository
  ↓
Polling watcher: Timer.periodic(Duration(milliseconds: 300))
  ↓
StreamController.broadcast()
  ↓
Riverpod
  ↓
UI
```

### Watched Hive Boxes

- `users`
- `messages`
- `call_requests`
- `room_meta`
- `session_logs`
- `app_state`

### Watcher Responsibilities

- **Observe**: Read Hive snapshots every 300ms.
- **Detect**: Compare snapshot signatures/hash/updatedAt values.
- **Emit**: Push changed snapshots through `StreamController.broadcast()`.
- **Dispose**: Cancel timers and close controllers safely.

### Important Implementation Constraint

Because each Android app has its own sandbox, both apps must use an agreed local shared storage strategy for demo mode. The chosen approach must be documented in `ARCHITECTURE.md` and be verified by the manual chat test.

---

## Required Repository Layout

```text
wtf_flutter_test/
├─ README.md
├─ AI_LEDGER.md
├─ ARCHITECTURE.md
├─ DECISIONS.md
├─ REQUIREMENTS.md
├─ TASK_BREAKDOWN.md
├─ IMPLEMENTATION_PLAN.md
├─ token_server/
├─ shared/
│  ├─ models/
│  ├─ services/
│  ├─ widgets/
│  └─ utils/
├─ guru_app/
│  ├─ lib/
│  ├─ test/
│  └─ pubspec.yaml
└─ trainer_app/
   ├─ lib/
   ├─ test/
   └─ pubspec.yaml
```

Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`.

---

## Data Models Required

- **User**: `id`, `role`, `name`, `email`, `avatarUrl?`, `assignedTrainerId?`
- **Message**: `id`, `chatId`, `senderId`, `receiverId`, `text`, `createdAt`, `status`
- **CallRequest**: `id`, `memberId`, `trainerId`, `requestedAt`, `scheduledFor`, `note`, `status`
- **SessionLog**: `id`, `memberId`, `trainerId`, `startedAt`, `endedAt`, `durationSec`, `rating?`, `trainerNotes?`, `memberNotes?`
- **RoomMeta**: `id`, `callRequestId`, `hmsRoomId`, `hmsRoleMember`, `hmsRoleTrainer`

All models should be immutable, JSON serializable, null-safe, and testable.

---

## UX Requirements from Assessment

### Guru App — First Run

```text
Splash
→ Onboarding (2 slides)
→ Create DK profile
→ Choose seeded trainer
→ Auto assign trainer
→ Home with 3 cards
```

Guru home cards:

- **Chat with Trainer**
- **Schedule Call**
- **My Sessions**

Guru secondary flows required by the assessment:

- **My Requests**: Shows DK's call requests and statuses (`pending`, `approved`, `declined`, `cancelled`).
- **Upcoming Calls**: Shows approved scheduled calls and exposes Join Call when eligible.

### Trainer App — First Run

```text
Splash
→ Mock Login
→ Home with 4 tiles
```

Seed trainer:

- **Aarav (Lead Trainer)**

Trainer home tiles:

- **Members**
- **Chats**
- **Requests**
- **Sessions**

### Trainer Members / Basic CRM List

- Required because the assessment includes basic CRM lists.
- Lists seeded/assigned members, starting with DK.
- Shows member name, avatar, assigned trainer, and latest interaction summary if available.
- Tapping DK opens member detail with shortcuts:
  - Chat
  - Requests
  - Sessions

### Auth Acceptance

- **Reinstall reset**: Onboarding/login shows again after app reinstall.
- **Remembered state**: Otherwise app remembers onboarding/login state.
- **Visual**: Dummy avatars, dark text on light background, clear contrast.

---

## Chat Requirements

### Chat List

- Recent conversations.
- Unread count badge.
- Last message preview.
- Timestamp format like `5m ago`.
- Empty state: `No messages yet. Start the conversation.`
- Empty state also includes an illustration and CTA: `Say hi`.
- Floating `+` FAB starts a new chat.

### Conversation

- Bubble UI, left/right alignment.
- Member bubble color: `#1769E0`.
- Trainer bubble color: `#E50914`.
- Typing indicator with simulated 400–800ms delay.
- Message ticks: single = sent, double = read.
- Mark read when screen is open.
- Pull to load history.
- Scroll to bottom on new message.
- Quick replies:
  - `Got it 👍`
  - `Can we talk at 6?`
  - `Share plan?`

### Chat Acceptance

- Sending/receiving works across two apps when both are running.
- Status changes are visible.
- Typing dot animates.

---

## Scheduler Requirements

### Member Flow

- Calendar next 3 days.
- 30-minute time slots.
- Note field, max 140 chars.
- CTA: `Request Call`.
- Create `CallRequest.pending`.
- Toast: `Call requested. Waiting for trainer approval.`
- Request appears under My Requests: `Pending approval by Aarav`.

### My Requests Screen

- Required for Guru app.
- Lists DK's call requests.
- Shows request status:
  - `Pending approval by Aarav`
  - `Approved`
  - `Declined`
  - `Cancelled`
- Shows scheduled date/time and note.
- Updates when Trainer approves or declines.
- Declined requests show trainer-provided reason: `Call request declined. Reason: {text}.`
- Approved requests link into Upcoming Calls.

### Trainer Flow

- Requests tab lists pending requests with DK note.
- Inline Approve/Decline.
- Approve creates `RoomMeta` and scheduled entry.
- Approve sends system message: `Call approved for {date} {time}.`
- Decline opens reason modal.
- DK sees declined state: `Call request declined. Reason: {text}.`

### Scheduler Acceptance

- Cannot pick past time.
- Approved slot conflict shows error.
- DK can verify newly created requests under My Requests.
- DK can see approval/decline state changes from Trainer app.

---

## 100ms Requirements

### Token Server

- Folder: `token_server/`.
- Endpoint: `GET /token?userId=&role=`.
- Env vars only, no hardcoded live keys.
- `.env.example` required.
- `README` instructions required.

### Room Lifecycle

- On Approve: create/get room via 100ms or documented dev shortcut.
- Save `hmsRoomId` in `RoomMeta`.
- Role mapping:
  - `trainer`
  - `member`
- Pre-join obtains token from token server.
- Join with role.

### Join UI

- Join button visible 10 minutes before scheduled time.
- Join button in upcoming calls list.
- Chat toolbar camera icon with badge.
- Pre-join device check modal:
  - Camera preview
  - Mic toggle
  - Camera toggle
  - Role auto-mapped

### Upcoming Calls Module

- Required for both Guru and Trainer apps.
- Lists approved scheduled calls.
- Shows participant name, scheduled date/time, and status.
- Shows Join Call button only within the allowed join window: 10 minutes before scheduled time.
- Also exposes Join Call affordance through chat toolbar camera icon with badge.
- Empty state should guide DK to schedule a call and Trainer to wait for approved requests.
- Upcoming Calls is populated when Trainer approves a `CallRequest` and creates/saves `RoomMeta`.

### In-Call UI

- Two participant tiles.
- Name labels.
- Mute/Unmute.
- Video On/Off.
- Flip Camera.
- End Call.
- Reconnect loader on connection blip.
- Device change listener.
- Token refresh handling documented or implemented.
- Edge cases documented/handled:
  - Token expired → refresh/retry path.
  - App background/foreground transition.
  - Network loss → reconnect loader.

### Role Permissions

- Trainer can mute self and end call.
- Member can mute self; cannot end for both if SDK supports role enforcement.

### End Call

- Auto-write `SessionLog` with start, end, duration.
- Member post-call sheet: rating 1–5 and optional note.
- Trainer post-call sheet: quick notes and `Mark as complete`.

---

## Session Logs

- Filter chips:
  - All
  - Last 7 days
  - This Month
- Row shows date, duration, rating if present.
- Tap row opens detail modal with both notes.
- Sort latest first.
- Empty state: `Schedule your first call`.
- Optional stretch only: export/share summary.

---

## UI Requirements

### Design Language

- Clean, modern, no clutter.
- 8pt spacing system.
- Light background.
- Dark text with clear contrast.

### Typography

- H1: 24sp.
- H2: 20sp.
- Body: 14–16sp.
- Semi-bold titles, regular body.

### Colors

- Guru primary: `#1769E0`.
- Trainer primary: `#E50914`.
- Success: `#12B76A`.
- Warning: `#F79009`.
- Error: `#D92D20`.
- Neutral greys.

### Components

- AppBar with role badge:
  - `Trainer • Aarav`
  - `Member • DK`
- Floating `+` FAB on Chat List.
- Sticky multiline input bar with send icon.
- Time chips in scheduler.
- CTA hierarchy:
  - Primary filled
  - Secondary outline
  - Tertiary text
- Loading skeletons.
- Empty states.
- Error states with retry CTA.
- Motion: 150–250ms transitions, chat bubble slide, button press scale.

---

## DevPanel / Observability

Floating `⋮` button opens DevPanel:

- Masked env vars.
- Build info.
- Last 20 structured logs.
- Tags:
  - `[CHAT]`
  - `[RTC]`
  - `[SCHEDULE]`
  - `[AUTH]`
- Snackbars with human copy.
- `Copy error` action.

---

## Security Rules

- Do not hardcode live 100ms keys.
- Use `.env` in token server.
- Include `.env.example` placeholders.
- Mask secrets in logs and DevPanel.

---

## Performance Targets

- Cold start: ≤ 2.5s on emulator.
- Chat send → peer render: ≤ 400ms simulated ok.
- RTC join time: ≤ 4s local network.
- Chat list scroll: 60fps.

---

## Manual Reviewer Test Script

1. Launch Trainer App, login as Aarav.
2. Launch Guru App, onboard DK, assign to Aarav.
3. DK sends `Hi Coach 👋`; Trainer sees unread badge, opens chat, replies.
4. DK schedules call today at 6:00 PM with note `Macros review`.
5. DK opens My Requests and sees `Pending approval by Aarav`.
6. Trainer approves; DK sees system message and approved request state.
7. DK and Trainer both see the call in Upcoming Calls.
8. Simulate join eligibility; both tap Join Call → camera/mic preview → connect.
9. Trainer toggles mute/video/flip; Member sees changes smoothly.
10. End call → logs created; DK rates 5★ + note; Trainer adds notes.
11. Open Sessions list → latest on top with rating/duration.

Pass if all steps succeed with clean UI, no crashes, and clear feedback states.

---

## Automated Tests Required

- Message serialization/deserialization.
- Scheduler validation: no past time.
- Log duration calculation.

---

## AI Ledger Requirements

`AI_LEDGER.md` must include:

- Prompt #
- Tool
- Intent
- Output snippet or summary
- Commit link or commit reference where used
- Files modified
- Decision

Required categories:

- Architecture
- Generation
- Debugging
- Refactor
- Tests
- Docs

Assessment says at least 10 meaningful entries; current project target remains **15 meaningful entries** to exceed requirement.

Repo proof target:

- At least 6 conventional commits referencing AI use in commit body.

Seed entries:

1. Repo init.
2. Architecture setup.
3. AI ledger setup.

---

## Scoring Rubric Mapping

| Category | Points | Implementation Focus |
|---|---:|---|
| Architecture & Code Quality | 20 | Shared package, services/providers/views separation, lint clean |
| Chat UX & Reliability | 15 | Status, typing, history, animations, two-app updates |
| Scheduler & Workflow | 10 | Conflict validation, approve/decline UX |
| 100ms Calls | 25 | Join/leave, roles, reconnection, device toggles |
| Session Logs & Ratings | 10 | Duration, rating, filters, notes |
| AI-Native Proof | 10 | AI_LEDGER depth, real prompts/usage |
| Polish & DX | 10 | DevPanel, docs, errors, demo readiness |

---

## Updated Execution Order

| Phase | Work |
|---|---|
| 0 | Docs: requirements, task breakdown, implementation plan |
| 1 | Architecture docs and ADRs |
| 2 | AI Ledger setup |
| 3 | Scaffold repo and shared package |
| 4 | Models |
| 5 | Auth + onboarding |
| 6 | Dashboards |
| 7 | Chat |
| 8 | Scheduler + My Requests |
| 9 | Upcoming Calls + 100ms join entry points |
| 10 | 100ms in-call experience |
| 11 | Session logs |
| 12 | DevPanel |
| 13 | Tests |
| 14 | Demo + final docs |

---

## Stretch Features — Skip Unless Time Remains

- Push notifications / reminders.
- File/image attachments.
- Offline send queue.
- Light/dark theme toggle.
- Export/share session summary.

---

## Submission Checklist

- Both apps build and run.
- README has one-command/clear build instructions.
- Token server runs locally.
- `.env.example` exists.
- 100ms join works on both apps.
- Chat works both ways with read receipts and typing.
- Scheduler approve/decline and conflict checks work.
- Guru My Requests screen shows pending, approved, and declined request states.
- Upcoming Calls module appears for both apps and exposes Join Call in the correct window.
- Session logs populate after call.
- `AI_LEDGER.md` has at least 10 meaningful entries; target 15.
- 3-minute demo path documented.
