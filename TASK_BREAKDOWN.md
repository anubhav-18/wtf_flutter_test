# Task Breakdown

## P0 — must finish

- Create root documentation and AI ledger.
- Scaffold `shared/` package.
- Scaffold `token_server/` with `.env.example`.
- Add shared dependencies to both apps.
- Implement models:
  - User
  - Message
  - CallRequest
  - RoomMeta
  - SessionLog
- Implement Hive initialization and seeded data.
- Implement repositories with 300ms polling watchers.
- Implement mock auth and onboarding:
  - Guru DK onboarding.
  - Trainer Aarav login.
- Implement dashboards:
  - Guru 3-card dashboard.
  - Trainer 4-tile dashboard.
  - AppBar role badges.
- Implement Members CRM list for Trainer.
- Implement chat:
  - Chat list.
  - Conversation.
  - Read receipts.
  - Typing indicator.
  - Quick replies.
  - Empty state with `Say hi`.
- Implement scheduler:
  - Calendar next 3 days.
  - 30-minute slots.
  - 140-character note.
  - My Requests screen.
  - Trainer Requests screen.
  - Approve/decline flow.
  - Conflict validation.
- Implement Upcoming Calls for both apps.
- Implement 100ms token fetch and Flutter SDK join path.
- Implement basic in-call controls.
- Implement session log creation on call end.
- Keep AI ledger updated.

## P1 — important

- Session log filters.
- Rating and notes sheets.
- DevPanel with logs and masked env.
- Snackbars with human copy and copy-error action.
- Widget/unit tests:
  - Message serialization.
  - Scheduler past-time validation.
  - Log duration calculation.
- README run instructions.
- Demo checklist.

## P2 — optional/stretch

- Image attachments.
- Push/local reminders.
- Offline send queue.
- Light/dark theme toggle.
- Export/share session summary.

## Execution priority

1. Docs and scaffold.
2. Models and persistence.
3. Auth/onboarding and dashboards.
4. Chat.
5. Scheduler and My Requests.
6. Upcoming Calls.
7. 100ms.
8. Session logs.
9. DevPanel and tests.
10. Demo polish.
