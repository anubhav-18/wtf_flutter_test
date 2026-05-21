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

## ADR-2: Storage = Hive

**Status**: Accepted

**Decision**: Use Hive for local persistence.

**Rationale**:

- Fast local key-value persistence.
- Simple setup compared with SQLite schema migrations.
- Good fit for local-first demo data.
- Supports app state, messages, call requests, room metadata, and logs.

**Consequences**:

- Repositories own Hive box access.
- Tests must cover serialization and persistence rules.
- Cross-app updates require polling because streams cannot cross process boundaries.

---

## ADR-3: Realtime UX = Hive polling + StreamController

**Status**: Accepted

**Decision**: Use `Timer.periodic(Duration(milliseconds: 300))` watchers in repositories, then emit updates through `StreamController.broadcast()`.

**Rationale**:

- Guru and Trainer apps are separate Android processes.
- Pure in-memory streams are insufficient across apps.
- The assignment requires local-first behavior and does not require a websocket server.
- 300ms polling satisfies the chat render target of ≤400ms simulated.

**Consequences**:

- Watchers must diff snapshots to avoid unnecessary rebuilds.
- Timers must be disposed correctly.
- Storage path assumptions must be documented.

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
