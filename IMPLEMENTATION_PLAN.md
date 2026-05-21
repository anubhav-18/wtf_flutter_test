# Implementation Plan

## 0–30 min

- Create source-of-truth documentation.
- Create AI ledger with seed entries.
- Record architecture decisions.
- Confirm P0 sequence.

## 30–90 min

- Scaffold `shared/` package.
- Scaffold `token_server/`.
- Update both Flutter app dependencies.
- Add base themes and shared constants.
- Add initial route shells.

## 90–180 min

- Implement models and JSON serialization.
- Implement Hive initialization.
- Implement seeded DK and Aarav users.
- Implement repositories with polling watchers.
- Implement Riverpod providers.

## 180–240 min

- Implement Guru splash, onboarding, DK profile, dashboard.
- Implement Trainer splash, mock login, dashboard.
- Implement Trainer Members list.
- Implement role badges and navigation.

## 240–330 min

- Implement chat list and conversation.
- Add message send/read state.
- Add typing simulation.
- Add quick replies.
- Validate cross-app polling flow.

## 330–420 min

- Implement scheduler.
- Implement My Requests.
- Implement Trainer Requests approve/decline.
- Add conflict validation.
- Inject system messages on approval/decline.
- Implement Upcoming Calls.

## 420–510 min

- Implement token server.
- Add 100ms SDK wiring.
- Implement pre-join and call screen.
- Add join, leave, mute, camera toggle, flip, reconnect loader.
- Create logs on call end.

## 510–570 min

- Implement session log filters and detail modal.
- Implement post-call rating/notes.
- Implement DevPanel and structured logs.
- Add minimum tests.

## Hard stop correction

The assessment has a 6-hour hard stop. If time runs short, prioritize:

1. App runs.
2. Chat works.
3. Scheduler works.
4. 100ms join path works.
5. Session logs populate.
6. AI ledger is complete.

Any missing or partial feature must be documented with fallback in README.
