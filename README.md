# WTF Flutter Assessment — Guru ↔ Trainer

Local-first Flutter assessment: real-time-feel chat, smart call scheduling, and 100ms video calling between a **Guru (Member)** app and a **Trainer** app, sharing a single `wtf_shared` package.

---

## Project layout

```
wtf_flutter_test/
├── guru_app/          # Member (DK) Flutter app
├── trainer_app/       # Trainer (Aarav) Flutter app
├── shared/            # wtf_shared package — models, services, providers, widgets, screens
└── token_server/      # Node.js 100ms JWT token server
```

---

## Quick start

### 1 — Token server

```bash
cd token_server
cp .env.example .env          # fill HMS_ACCESS_KEY, HMS_SECRET, HMS_ROOM_ID
npm install
node index.js                 # runs on http://localhost:4000
```

Test it: `curl http://localhost:4000/health` → `{"ok":true}`

### 2 — Run both apps (two terminals)

```bash
# Terminal 1 – Guru (Member) app
cd guru_app && flutter run

# Terminal 2 – Trainer app
cd trainer_app && flutter run
```

> **Requires Android device / emulator.** Use `flutter devices` to confirm.

---

## Full demo walkthrough

| Step | Action |
|------|--------|
| 1 | Start token server (`node index.js`) |
| 2 | Launch Trainer app → login as Aarav |
| 3 | Launch Guru app → onboard as DK |
| 4 | Chat both ways (typing indicator, read receipts) |
| 5 | DK: Schedule Call → pick date/time → submit |
| 6 | Aarav: Requests → approve the request |
| 7 | DK: Upcoming Calls → Join (opens within 10 min window) |
| 8 | Pre-join check → toggle mic/camera → Join Now |
| 9 | In-call UI: mute / camera / flip / end |
| 10 | End call → DK rates session → Aarav adds notes |
| 11 | Both apps: Sessions tab → verify log with duration & rating |

---

## Architecture overview

- **Local-first** — all state in Hive boxes (`users`, `messages`, `call_requests`, `room_meta`, `session_logs`).
- **Riverpod** for state management; `BasePollingRepository` streams live data.
- **HmsService** wraps `hmssdk_flutter` with auto-reconnect (up to 3 attempts).
- **Shared screens** — `PreJoinScreen` and `InCallScreen` are in `wtf_shared` and reused by both apps.

See `ARCHITECTURE.md` and `DECISIONS.md` for ADRs.

---

## Token server environment

Copy `token_server/.env.example` → `token_server/.env` and fill in your 100ms credentials:

```env
HMS_ACCESS_KEY=your_100ms_access_key
HMS_SECRET=your_100ms_secret
HMS_ROOM_ID=your_100ms_room_id
PORT=4000
```

> Do **not** commit `.env`.

---

## Running tests

```bash
cd shared
flutter test         # 16 tests — message serialization, scheduler conflict, session log
```

---

## Implemented features

| Feature | Guru App | Trainer App |
|---------|----------|-------------|
| Onboarding / Login | ✅ | ✅ |
| Chat (list + conversation) | ✅ | ✅ |
| Read receipts + typing indicator | ✅ | ✅ |
| Schedule call | ✅ | — |
| Approve / decline requests | — | ✅ |
| Upcoming calls (with 10-min join window) | ✅ | ✅ |
| Pre-join device check | ✅ | ✅ |
| In-call (100ms video, mic/cam/flip/end) | ✅ | ✅ |
| Post-call rating sheet | ✅ | — |
| Post-call notes sheet | — | ✅ |
| Session logs (filter by 7d / month) | ✅ | ✅ |
| Members CRM | — | ✅ |
| Dev log panel | ✅ | ✅ |

---

## Missing-feature fallback rule

If a feature is incomplete at submission, its fallback is logged via `DevLogService` and a visual empty state is shown with descriptive copy. No silent failures.
