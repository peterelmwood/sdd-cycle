---
description: "Task list for: Mandatory Branch-Creation Step in the SDD Workflow"
---

# Tasks: Mandatory Branch-Creation Step in the SDD Workflow

**Input**: Design documents from `/specs/002-sdd-branch-step/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: No automated test suite is requested. This is a bundle
configuration/governance feature; its verification surface is the existing
`scripts/validate-bundle.ps1` guardrail (Constitution V) plus the `quickstart.md`
inspection steps. Those verification tasks appear in Setup and Polish.

**Organization**: Tasks are grouped by user story. Foundational work (the actual
workflow-definition edit) blocks all stories.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are included in each task.

## Path Conventions

This bundle has no application source tree. The "surface" is workflow
definitions, manifests, docs, and governance files at the repository root and
under `.specify/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a known-good starting point before editing.

- [ ] T001 Establish green baseline: run `pwsh ./scripts/validate-bundle.ps1` from the repo root and confirm exit code 0. Record the baseline `sdd` workflow version (`1.1.0`) and constitution version (`1.0.0`).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the mandatory branch step to the workflow definition. Every user
story depends on this edit existing.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T002 Add a mandatory `branch` step as the FIRST entry under `steps:` in `.specify/workflows/sdd/workflow.yml`, invoking the git extension command `speckit.git.feature`, positioned before the `specify` step. Preserve the order and meaning of all existing steps (`specify → plan → tasks → analyze → apply-analysis → review-before-implement → implement`) and the single gate (FR-001, FR-009; contract C1).
- [ ] T003 Bump `workflow.version` from `1.1.0` to `1.2.0` in `.specify/workflows/sdd/workflow.yml`, and update the pinned `sdd` workflow version under `provides.workflows` in `bundle.yml` to `1.2.0` so the pin equals the component version (Constitution II; contract C2).

**Checkpoint**: The workflow now declares a mandatory branch step and manifests
are version-consistent.

---

## Phase 3: User Story 1 - Branch is always created before spec artifacts (Priority: P1) 🎯 MVP

**Goal**: The cycle creates and switches to a correctly-named feature branch
before any specification artifact is written.

**Independent Test**: Inspect `workflow.yml` and confirm the `branch` step runs
before `specify` and delegates to `speckit.git.feature`; dry-run the branch
command (quickstart step 6) and confirm a schema-conformant `BRANCH_NAME`.

- [ ] T004 [US1] In `.specify/workflows/sdd/workflow.yml`, confirm the `branch` step delegates to `speckit.git.feature` (which uses the project-configured sequential `NNN-<short-name>` / timestamp schema and honors `GIT_BRANCH_NAME`), so no new branch mechanism is introduced (FR-003; research D1/D3).
- [ ] T005 [US1] Verify step ordering against contract C1 by reading `.specify/workflows/sdd/workflow.yml`: `steps[0].id == branch`, followed in order by `specify, plan, tasks, analyze, apply-analysis, review-before-implement, implement` (FR-001, FR-009).

**Checkpoint**: The isolation guarantee (branch-before-artifacts) is declared and
inspectable.

---

## Phase 4: User Story 2 - Branch step cannot be silently skipped (Priority: P1)

**Goal**: The branch step is mandatory and its unavailable-git behavior is a loud
warning, never a silent proceed-on-shared-branch.

**Independent Test**: Inspect the workflow definition and confirm the branch step
is non-optional; confirm the degradation behavior is documented and matches the
underlying script's warn-without-false-success behavior.

- [ ] T006 [US2] Ensure the `branch` step in `.specify/workflows/sdd/workflow.yml` is declared mandatory (not optional) and that no configuration path allows proceeding to `specify` on a shared branch without warning (FR-002; contract C1). Add a brief inline note documenting its required status.
- [ ] T007 [US2] Document the graceful-degradation contract next to the step (in `.specify/workflows/sdd/workflow.yml` and/or the launcher): when git is unavailable the step surfaces a clear warning and does not report false success (FR-005; contract C6; research D6).

**Checkpoint**: The mandatory nature and degradation behavior are explicit and
verifiable.

---

## Phase 5: User Story 3 - Consistency across definitions, docs, and governance (Priority: P2)

**Goal**: Every cycle-order description and both entry points name the mandatory
branch step in the same position, and governance is amended to match.

**Independent Test**: Compare all cycle-order descriptions and the two entry
points; confirm zero discrepancies (contract C3) and a ratified, amended
constitution (contract C4).

- [ ] T008 [P] [US3] Update `workflow.description` in `.specify/workflows/sdd/workflow.yml` to include the branch step in the cycle-order string (FR-008; contract C3).
- [ ] T009 [P] [US3] Update the `extension.description` and the `speckit.sdd.run` command description in `.specify/extensions/sdd/extension.yml` to include the branch step in the cycle-order string (FR-008; contract C3).
- [ ] T010 [P] [US3] Update `bundle.description` in `bundle.yml` to include the branch step, and align the string to include `apply`/`gate` consistently with the other manifests (FR-008; contract C3). Bump `bundle.version` if the description/behavior change warrants it.
- [ ] T011 [US3] Update the launcher to name the mandatory branch step as an explicit first step in `.claude/commands/speckit-sdd-run.md` and the matching skill text under `.claude/skills/speckit-sdd-run/` so both entry points agree with `workflow.yml` (FR-007; contract C3).
- [ ] T012 [US3] Amend Principle IV canonical order in `.specify/memory/constitution.md` to include the branch step; bump `Version` `1.0.0 → 1.1.0` and update `Last Amended` to 2026-07-23; ensure no placeholder tokens remain (FR-008; contract C4; research D5).
- [ ] T013 [US3] Record the workflow version bump and the constitution amendment in `CHANGELOG.md` per the Governance section (contract C4).

**Checkpoint**: All descriptions, both entry points, and governance are mutually
consistent.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Defend correctness mechanically and validate end-to-end.

- [ ] T014 Review `scripts/validate-bundle.ps1`: if the canonical cycle-order is to become a machine-verified rule, add that assertion; otherwise confirm no change is needed and note why (Constitution V).
- [ ] T015 Run `pwsh ./scripts/validate-bundle.ps1` from the repo root and confirm exit code 0 with no parse error, version inconsistency, missing file reference, or unratified-constitution error (contract C5).
- [ ] T016 Execute `specs/002-sdd-branch-step/quickstart.md` steps 1–6 and confirm each expected outcome, including the branch-command dry-run (contract C6).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — run first to confirm a green baseline.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories (adds the branch step + version consistency).
- **User Stories (Phase 3–5)**: All depend on Foundational.
  - US1 and US2 both refine the `workflow.yml` branch step; US2 builds on US1's step existing.
  - US3 propagates the change outward and can largely proceed once the step exists.
- **Polish (Phase 6)**: Depends on all desired stories being complete.

### User Story Dependencies

- **US1 (P1)**: After Foundational. Delivers the inspectable isolation guarantee — the MVP.
- **US2 (P1)**: After US1 (same file — the branch step must exist to mark it mandatory / document degradation).
- **US3 (P2)**: After Foundational; T008–T010 are parallel-safe (different files); T011–T013 follow.

### Within Each User Story

- Edit the definition before verifying it.
- Governance/changelog (T012–T013) after the manifest edits they describe.

### Parallel Opportunities

- T008, T009, T010 touch different files and can run in parallel.
- T004 and T005 are read/verify tasks and can run alongside US3 doc edits once T002–T003 land.

---

## Parallel Example: User Story 3

```bash
# Cycle-order description updates in separate files, run together:
Task: "Update workflow.description in .specify/workflows/sdd/workflow.yml"
Task: "Update descriptions in .specify/extensions/sdd/extension.yml"
Task: "Update bundle.description in bundle.yml"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Setup (green baseline).
2. Phase 2: Foundational (add branch step + version consistency).
3. Phase 3: US1 — branch declared before specify.
4. **STOP and VALIDATE**: dry-run the branch command; confirm ordering.

### Incremental Delivery

1. Setup + Foundational → workflow declares the mandatory step.
2. US1 → isolation guarantee inspectable (MVP).
3. US2 → mandatory + degradation explicit.
4. US3 → all docs/manifests/governance consistent.
5. Polish → guardrail green, quickstart validated.

---

## Notes

- No automated test tasks: the guardrail script and quickstart inspection are the
  verification surface (none requested in the spec).
- Reuse over reinvent: the branch step delegates to `speckit.git.feature`; no new
  branch script is authored (research D1).
- Keep manifests version-consistent at every step — `validate-bundle.ps1` is the
  backstop.
- Commit after each phase or logical group.
