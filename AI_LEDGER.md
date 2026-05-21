# AI Ledger

This ledger records AI-assisted work for the WTF Flutter Engineer assessment. Target: 15 meaningful entries covering architecture, generation, debugging, refactor, tests, and docs.

## Prompt #1

**Timestamp**: 2026-05-21 15:28 IST

**Tool**: Cascade

**Intent**: Architecture planning

**Prompt**: Analyze the assessment and create a source-of-truth implementation plan for the local-first Guru ↔ Trainer system.

**Output Summary**: Produced plan aligned with the assignment, including docs, scaffold, Hive, polling watcher, Riverpod, scheduler, 100ms, logs, DevPanel, tests, and demo checklist.

**Files Modified**: `plan.md`

**Commit**: Pending

**Decision**: Follow the assessment as source of truth and avoid stretch features until P0 is complete.

---

## Prompt #2

**Timestamp**: 2026-05-21 15:36 IST

**Tool**: Cascade

**Intent**: Requirement correction

**Prompt**: Re-read the assessment and add missing My Requests and Upcoming Calls modules.

**Output Summary**: Confirmed My Requests and Upcoming Calls are required from the assessment and updated the plan to make them first-class modules.

**Files Modified**: `plan.md`

**Commit**: Pending

**Decision**: My Requests and Upcoming Calls are required, not optional subfeatures.

---

## Prompt #3

**Timestamp**: 2026-05-21 15:43 IST

**Tool**: Cascade

**Intent**: Documentation generation

**Prompt**: Start implementation step by step according to the plan, including AI ledger and commits.

**Output Summary**: Created root documentation files and seeded AI ledger before code scaffold.

**Files Modified**: `README.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `TASK_BREAKDOWN.md`, `IMPLEMENTATION_PLAN.md`, `AI_LEDGER.md`

**Commit**: Pending

**Decision**: Complete documentation and ledger baseline before writing app code.

---

## Prompt #4

**Timestamp**: 2026-05-21 15:48 IST

**Tool**: Cascade

**Intent**: Generation

**Prompt**: Continue implementation chunk by chunk according to the plan.

**Output Summary**: Scaffolded the shared package, token server, base models, utilities, polling repository base, concrete repositories, services, Riverpod providers, and shared widgets. Resolved dependency setup and verified shared package analysis passes.

**Files Modified**: `shared/`, `token_server/`, `guru_app/pubspec.yaml`, `trainer_app/pubspec.yaml`, `AI_LEDGER.md`

**Commit**: Pending

**Decision**: Implemented models manually with immutable classes, JSON helpers, `copyWith`, equality, and no code generation to reduce setup time.

---

## Prompt #5

**Timestamp**: TBD

**Tool**: TBD

**Intent**: Debugging

**Prompt**: TBD

**Output Summary**: TBD

**Files Modified**: TBD

**Commit**: TBD

**Decision**: TBD
