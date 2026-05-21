# WTF Flutter Test

Local-first Flutter assessment project for a Guru ↔ Trainer chat, scheduling, and 100ms video calling workflow.

## Apps

- `guru_app`: Member app for DK.
- `trainer_app`: Trainer app for Aarav.
- `shared`: Shared models, services, repositories, providers, widgets, and utilities.
- `token_server`: Local 100ms token server.

## Source of truth

Read these first:

- `plan.md`
- `REQUIREMENTS.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `TASK_BREAKDOWN.md`
- `IMPLEMENTATION_PLAN.md`
- `AI_LEDGER.md`

## Required local services

The 100ms token server requires environment variables in `token_server/.env`:

```text
HMS_ACCESS_KEY=your_access_key
HMS_SECRET=your_secret
HMS_ROOM_ID=your_room_id_or_dev_room
PORT=4000
```

Do not commit `.env`.

## Build status

Implementation is in progress. The target is Android-only local execution.

## Demo path

1. Start token server.
2. Launch Trainer App and login as Aarav.
3. Launch Guru App and onboard DK.
4. Send chat both ways.
5. Schedule call and approve from Trainer.
6. Confirm My Requests and Upcoming Calls.
7. Join 100ms call.
8. End call and verify Session Logs.

## Missing-feature fallback rule

If a feature is incomplete at submission time, document why and provide the fallback behavior here before demo/submission.
