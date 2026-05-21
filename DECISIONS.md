# Architecture Decision Records

## ADR-1: State management = Riverpod

**Status**: Accepted

**Decision**: Use Riverpod for app state and stream consumption.

**Rationale**:

- Works well with immutable state.
- Provides `StreamProvider` for repository streams.
- Keeps UI decoupled from repository implementation.
- Lightweight enough for the 6-hour assessment.

**Consequences**:

- Providers live in `shared/lib/providers`.
- Both apps consume the same shared provider layer.

---

## ADR-2: Storage = Hive (local auth only)

**Status**: Superseded by ADR-5 for shared data; still active for device-local auth state.

**Decision**: Use Hive for local persistence.

**Rationale (original)**:

- Fast local key-value persistence.
- Simple setup compared with SQLite schema migrations.
- Good fit for local-first demo data.

**Consequences (updated)**:

- Hive remains for: `onboarded` flag, `trainerLoggedIn` flag — device-local auth state only.
- Messages, CallRequests, SessionLogs, Users → migrated to REST API per ADR-5.
- Cross-app updates require polling because streams cannot cross process boundaries.

---

## ADR-3: Realtime UX = REST polling + StreamController

**Status**: Accepted

**Decision**: Use `Timer.periodic(Duration(milliseconds: 300))` watchers in repositories, polling the shared REST backend, then emit updates through `StreamController.broadcast()`.

**Rationale**:

- Guru and Trainer apps are separate Android processes.
- Pure in-memory streams are insufficient across apps.
- 300ms polling satisfies the chat render target of ≤400ms simulated.
- Switched from Hive-read polling to HTTP-GET polling after ADR-5 migration.

**Consequences**:

- Watchers must diff snapshots to avoid unnecessary rebuilds.
- Timers must be disposed correctly.
- Both apps must point to the same `tokenServerBaseUrl` (see README).

---

## ADR-4: RTC = 100ms SDK + local token server

**Status**: Accepted

**Decision**: Integrate `hmssdk_flutter` in the apps and provide a local Node/Express token server.

**Rationale**:

- 100ms SDK is mandatory and high scoring.
- Token server keeps secrets out of Flutter apps.
- Local server is aligned with the assignment requirement.

**Consequences**:

- Token server requires `.env` credentials.
- Android permissions must include camera, microphone, internet, and bluetooth/audio where needed.
- Exact 100ms room creation assumptions must be documented if using a dev shortcut.

---

## ADR-5: Migrate shared data from Hive to REST backend

**Status**: Accepted

**Date**: 2026-05-21 (mid-integration, after ADR-2 proved unworkable for multi-device)

**Context**:

During integration testing, we discovered that Hive stores data in the app's private sandbox (`/data/data/<packageName>/`). When running Guru App on a physical device and Trainer App on an emulator (two separate Android OS instances), their Hive boxes are completely isolated. No amount of polling can bridge them.

**Decision**: Extend the existing 100ms token server (Node/Express) to serve as a shared in-memory data store for `users`, `messages`, `call_requests`, `session_logs`, and `room_meta`. Repositories now make HTTP calls to `ApiClient` instead of reading Hive boxes.

**Rationale**:

- Zero new dependencies — the Node server already exists.
- Both apps already know the server URL (`AppConstants.tokenServerBaseUrl`).
- In-memory store is acceptable for a demo with two users.
- Hive remains for auth state (device-local, does not need cross-device sync).

**Consequences**:

- Server must be running before launching apps.
- For physical device + emulator: device must use the PC's LAN IP, emulator uses `10.0.2.2`.
- Data is lost when server restarts (acceptable for assessment demo).
- `token_server/index.js` expanded from ~40 lines to ~350 lines.

