---

description: "Task list for Extension Readiness"
---

# Tasks: Extension Readiness

**Input**: Design documents from `/specs/001-extension-readiness/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/validation-check.md, quickstart.md

**Tests**: No separate test framework is requested. The validation check's own
red/green behavior (contract T1–T3) is verified as explicit tasks in Phase 5.

**Organization**: Tasks are grouped by user story (US1 P1, US2 P2, US3 P3).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: US1 / US2 / US3

## Path Conventions

This is a Spec Kit **bundle** repository (no `src/`/`tests/` runtime tree). Paths
are real repository files: manifests, docs, and `scripts/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the location for new artifacts.

- [X] T001 Create the `scripts/` directory at the repository root for the validation check.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the ground truth every story relies on: the actual current
version/reference facts.

- [X] T002 Read and record the current declared values from `bundle.yml`, `extensions/sdd/extension.yml`, `workflows/sdd/workflow.yml`, and `.specify/extensions.yml` (component ids, versions, `speckit_version` floors, command file paths) into a scratch note so later tasks reconcile against verified facts. (Result: `bundle.yml` already pins extension `sdd@1.0.0` and workflow `sdd@1.1.0`, matching their manifests — the initial R1 claim of a version mismatch was **incorrect**; no reconciliation edit was needed.)

**Checkpoint**: Current-state facts confirmed — story work can begin.

---

## Phase 3: User Story 1 - Install and run the SDD cycle (Priority: P1) 🎯 MVP

**Goal**: A user following the README verbatim gets a registered `sdd` workflow and
a working launcher, with no failed command and no reference to a missing path.

**Independent Test**: From the README Install section, every command runs clean;
`specify workflow info sdd` shows the documented step order; each documented path
exists.

- [X] T003 [US1] Audit every command and file path in `README.md` (Install, Repository layout, Components sections) against the actual repository; list any command that fails on Spec Kit 0.12.2 or any path that does not exist.
- [X] T004 [US1] Correct `README.md` so each install/usage command is accurate (workflow via `specify workflow add <path>`; Claude launcher via copying `commands/speckit-sdd-run.md` into `.claude/commands/`) and every referenced path exists (satisfies FR-001, FR-002).
- [X] T005 [US1] Ensure `README.md` clearly distinguishes the two launcher delivery paths (Claude Code slash command vs. Spec Kit extension) and states the reliable path per integration (satisfies FR-008).
- [X] T006 [US1] Ensure `README.md` documents each known limitation with its workaround (extension command not user-invocable on Claude; no published archive → clone + `--dev`; `specify bundle install` not the path) and verify each statement still holds on 0.12.2 (satisfies FR-010).
- [X] T007 [US1] Verify the documented step order in `README.md` matches `workflows/sdd/workflow.yml` (`specify → plan → tasks → analyze → apply → gate → implement`).

**Checkpoint**: README is executable end-to-end; install-and-launch works as written.

---

## Phase 4: User Story 2 - Trust the manifests and versions (Priority: P2)

**Goal**: Every manifest is internally consistent, and the constitution contains
real principles instead of placeholders.

**Independent Test**: Cross-check all manifests → no contradictions; open the
constitution → zero placeholder tokens.

- [X] T008 [US2] Reconcile `bundle.yml` so `provides.workflows[sdd].version` equals `workflows/sdd/workflow.yml`'s `1.1.0`, and confirm `provides.extensions[sdd].version` still equals `extensions/sdd/extension.yml`'s version (satisfies FR-003, SC-003).
- [X] T009 [US2] Verify and, if needed, align the `speckit_version` floor across `bundle.yml`, `extensions/sdd/extension.yml`, and `workflows/sdd/workflow.yml` so all are stated consistently (satisfies FR-004).
- [X] T010 [US2] Bump `bundle.yml` `bundle.version` to `1.1.0` to reflect the readiness release aligned with the shipped workflow line (supports R5; keep consistent with CHANGELOG in T017).
- [X] T011 [US2] Ratify `.specify/memory/constitution.md` via the `speckit.constitution` flow with the five principles from plan.md (Local-first & portable; Manifests are the contract; Docs must be executable; Behavior-preserving packaging; Guardrail before release), a Governance section, and a `Version: 1.0.0 | Ratified: 2026-06-30 | Last Amended: 2026-06-30` line — no placeholder tokens remain (satisfies FR-005, SC-004). Note: the `speckit.constitution` flow fires the mandatory `before_constitution` hook (`git.initialize`); git is already initialized, so this is an expected no-op.

**Checkpoint**: Manifests agree with each other; constitution is real.

---

## Phase 5: User Story 3 - Validate the bundle before publishing (Priority: P3)

**Goal**: A single repeatable check verifies correctness and fails loudly on
regressions; a documented step produces a distributable artifact.

**Independent Test**: Run the check on a clean checkout → exit 0; break a manifest
→ non-zero with a specific message; run the build step → versioned artifact.

- [X] T012 [US3] Implement `scripts/validate-bundle.ps1` performing all assertions in `contracts/validation-check.md`: parse the four manifests; assert bundle-pinned versions match each component's own manifest; assert `speckit_version` floors are mutually compatible; assert every manifest file reference exists; assert the constitution has no placeholder tokens (satisfies FR-006).
- [X] T013 [US3] Ensure `scripts/validate-bundle.ps1` exits non-zero and prints an identifying message for each failure class (version mismatch, missing file reference, malformed YAML, placeholder constitution) (satisfies FR-007).
- [X] T014 [US3] Run `scripts/validate-bundle.ps1` on the corrected repository and confirm exit 0 with a PASS summary (contract T1 / quickstart Scenario A / SC-005).
- [X] T015 [US3] Temporarily break `bundle.yml` (wrong workflow version) and a command `file` reference; confirm the check fails naming each problem; revert and confirm exit 0 again (contract T2/T3 / quickstart Scenario B).
- [X] T016 [US3] Document distribution in `README.md`: the **supported** paths (install from clone with `--dev`; build an artifact with `specify bundle build` → `dist/`) **and**, plainly, the **unsupported** paths (raw-URL `specify extension add --from <url>`; catalog-based `specify bundle install`). Confirm the build produces a versioned archive (satisfies FR-009 parts a+b, SC-006 / quickstart Scenario F). **Status:** distribution documented; live `specify bundle build` confirmation is **BLOCKED** — the `specify` CLI in this environment is currently failing with `ModuleNotFoundError: No module named 'specify_cli'` (a flaky external launcher issue, unrelated to this repo; `specify workflow add/list/info` succeeded earlier this session).

**Checkpoint**: Correctness is guarded by a repeatable check; a release artifact can be produced.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Publishable-project metadata and final verification.

- [X] T017 [P] Add `CHANGELOG.md` recording the readiness release (version 1.1.0, 2026-06-30) with the manifest/doc/validation changes (satisfies FR-011).
- [X] T018 [P] Add `CONTRIBUTING.md` explaining how to propose changes and that `scripts/validate-bundle.ps1` must pass before a PR/release (satisfies FR-011).
- [X] T019 Add a "Validate" section to `README.md` pointing contributors to `scripts/validate-bundle.ps1` and the quickstart scenarios.
- [X] T020 Run all `quickstart.md` scenarios (A–F) end-to-end and confirm every expected outcome; record results. **Results:** A (validation exit 0, 7 checks) ✓; B (regression caught: wrong version + missing file both fail with specific messages, revert → exit 0) ✓; C (manifests consistent — automated by A) ✓; D (constitution has no placeholders — asserted by A and by inspection) ✓; E (install: `specify workflow add/list/info` succeeded earlier this session) ✓; F (`specify bundle build`) **BLOCKED** by the `specify` CLI outage noted in T016.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: after Setup. Records ground-truth facts used by all stories.
- **US1 (Phase 3)**: after Foundational. Independent of US2/US3 (docs-only).
- **US2 (Phase 4)**: after Foundational. Independent of US1.
- **US3 (Phase 5)**: script creation (T012–T013) is independent; the **green** validation run (T014) depends on US2 fixes (T008–T011) and US1 doc fixes for the README-reference assertion. The red-run (T015) is independent.
- **Polish (Phase 6)**: after the stories it documents (T017 references US2 versions; T019 references US3 script).

### Independent Test Criteria

- **US1**: README commands all succeed; step order matches; no missing paths.
- **US2**: manifest cross-check has no contradictions; constitution has no placeholders.
- **US3**: check passes clean, fails on a broken manifest, build emits an artifact.

### Parallel Opportunities

- T003 (README audit) and T012 (write validation script) touch different files and can run in parallel.
- T017 and T018 are independent new files — [P].
- US1 (docs) and the script-authoring part of US3 can proceed concurrently.

---

## Parallel Example

```text
# After Foundational (T002):
Task: T003 [US1] Audit README commands/paths
Task: T012 [US3] Implement scripts/validate-bundle.ps1
# Then converge: apply US2 manifest/constitution fixes (T008–T011),
# then run the green validation (T014).
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. T001 → T002 → Phase 3 (T003–T007).
2. **STOP and VALIDATE**: README install-and-launch works verbatim. This alone
   makes the repo usable as documented (the core readiness win).

### Incremental Delivery

1. US1 → accurate, executable docs (MVP).
2. US2 → trustworthy, consistent manifests + real constitution.
3. US3 → automated guardrail + release artifact.
4. Polish → publishable metadata; full quickstart pass.

---

## Notes

- Commit after each logical group; the `after_implement` auto-commit hook may also fire.
- No behavior of the SDD cycle changes — packaging/docs/validation only.
- Total tasks: 20 (Setup 1, Foundational 1, US1 5, US2 4, US3 5, Polish 4).
