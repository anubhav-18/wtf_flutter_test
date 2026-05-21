# Architecture

The system is a local-first mono repo containing two Android Flutter apps, one shared Dart/Flutter package, and one local 100ms token server.

## System components

```text
wtf_flutter_test/
├── guru_app/
├── trainer_app/
├── shared/
└── token_server/
```

## Runtime architecture

The apps are separate Android processes, so memory cannot be shared directly. The live UX is implemented by polling persisted Hive data and then emitting changes through in-process streams.

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

## Storage layer

Hive is the source of truth for local data:

- `users`
- `messages`
- `call_requests`
- `room_meta`
- `session_logs`
- `app_state`

Repositories own reads/writes and watcher lifecycle.

## Repository layer

Repositories provide:

- Synchronous writes to Hive.
- Snapshot reads from Hive.
- 300ms polling watchers.
- Change detection before emitting.
- Broadcast streams consumed by Riverpod.
- `dispose()` methods that cancel timers and close controllers.

## Stream layer

Each watched entity has a broadcast stream:

- Messages stream.
- Call requests stream.
- Room metadata/upcoming calls stream.
- Session logs stream.

Streams are process-local, but updates are sourced from persisted Hive snapshots so both apps can observe changes through polling.

## State management

Riverpod providers expose:

- Current user/session state.
- Chat list and conversation messages.
- Call requests and My Requests.
- Upcoming calls.
- Session logs.
- Dev logs.

## Shared package structure

```text
shared/
├── lib/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   ├── providers/
│   ├── widgets/
│   └── utils/
└── pubspec.yaml
```

## Guru app flow

```text
Splash
→ Onboarding
→ DK Profile
→ Dashboard
→ Chat / Schedule / My Requests / Upcoming Calls / Sessions
```

## Trainer app flow

```text
Splash
→ Mock Login
→ Dashboard
→ Members / Chats / Requests / Upcoming Calls / Sessions
```

## Scheduler and calls

- DK creates `CallRequest.pending`.
- Trainer approves or declines.
- Approval creates `RoomMeta` and system message.
- Upcoming Calls reads approved requests with room metadata.
- Join opens pre-join and fetches token from local token server.
- 100ms handles live RTC.
- End call creates `SessionLog`.

## 100ms token server

`token_server/` exposes:

```text
GET /token?userId=&role=
```

Secrets are loaded from `.env`:

- `HMS_ACCESS_KEY`
- `HMS_SECRET`
- `HMS_ROOM_ID` or documented room creation shortcut

## Security

- No live secrets in source.
- `.env.example` contains placeholders.
- DevPanel masks environment values.
- Logs avoid token/secret output.

## Known local-first constraint

Android app sandboxes normally isolate storage. For demo mode, the apps must use a documented shared local storage approach or a deterministic local demo bridge. If the exact storage path differs on emulator, the fallback must be documented with reviewer steps.
