# Research: Mandatory Branch-Creation Step in the SDD Workflow

Phase 0 resolves the design decisions the plan depends on. There were no
`NEEDS CLARIFICATION` markers in the spec; the open questions here are design
choices, each resolved with a decision, rationale, and rejected alternatives.

## D1. How should the mandatory branch step be realized?

**Decision**: Add an explicit `branch` step as the **first** step in
`workflows/sdd/workflow.yml`, delegating to the existing git extension command
`speckit.git.feature`. Do **not** author a new branch-creation script.

**Rationale**:
- The git extension already provides tested, cross-platform (PowerShell + Bash)
  branch creation with sequential/timestamp numbering, GitHub 244-byte-limit
  handling, and `GIT_BRANCH_NAME` override. Reusing it honors Local-First &
  Portable (I) and avoids a second, competing mechanism.
- Making it a named step (not a hidden hook effect) is precisely what the
  feature asks for: a visible, mandatory *step* in the workflow.

**Alternatives considered**:
- *New dedicated branch script*: rejected — duplicates a solved problem and adds
  a maintenance/consistency burden (violates the spirit of Principle II).
- *Leave branch creation only in the `before_specify` hook*: rejected — the hook
  is invisible in the workflow definition, so the cycle's declarative contract
  never states the guarantee; fails the "mandatory step in the workflow" intent.

## D2. Relationship between the new step and the existing `before_specify` hook

**Decision**: Keep the `before_specify` git hook (it also serves standalone
`/speckit-specify` outside the cycle). Treat branch creation as **idempotent by
reuse**: when the cycle is already on a valid feature branch for the current
feature, branch creation reuses it rather than allocating a new number.

**Rationale**:
- Removing the hook would regress standalone specify (branch creation is a
  general Spec Kit convenience, not cycle-only). Out of scope to change that.
- In the **supported in-session launcher path**, the branch is created exactly
  once (by the `before_specify` hook when `speckit.specify` runs); the new
  workflow step is the *declarative statement* of that mandatory behavior.
- In the **declarative `specify workflow run` path**, the explicit `branch` step
  runs first; the subsequent specify hook must not create a second branch. The
  reuse guarantee (FR-006) makes a redundant invocation a no-op: already on a
  fresh feature branch → stay on it.

**Alternatives considered**:
- *Remove the hook, rely solely on the new step*: rejected — regresses
  standalone specify branch creation.
- *Add step and keep hook with no reuse guard*: rejected — under
  `specify workflow run` this would create two branches with different numbers.
- *Disable the hook only within the cycle*: rejected — Spec Kit hooks are not
  conditionally scoped per-caller here; adds fragile condition logic.

## D3. Naming schema

**Decision**: Reuse the project's configured schema unchanged — sequential
`NNN-<short-name>` (default) or timestamp `YYYYMMDD-HHMMSS-<short-name>`,
determined by `feature_numbering`/`branch_numbering`; honor an explicit
`GIT_BRANCH_NAME` verbatim. This matches the "speckit predefined schema or the
numerical schema (00x-[feature]-[description])" the request names.

**Rationale**: The requested schemas already exist and are what
`speckit.git.feature` produces. No schema redesign is in scope (spec Assumptions).

**Alternatives considered**:
- *Invent a new naming convention*: rejected — out of scope and would fragment
  existing conventions.

## D4. Version and manifest impact

**Decision**: Bump the `sdd` **workflow** version (minor: `1.1.0 → 1.2.0`) because
its behavior changes, and update the `bundle.yml` workflow pin to the same value.
Update the cycle-order description strings wherever they appear so all manifests
agree. Re-run `validate-bundle` to confirm pin==version and file references hold.

**Rationale**: Constitution II requires the bundle-pinned version to equal the
component's declared version, enforced by `validate-bundle` assertion 2. A
behavioral change to the workflow warrants a version increment for honest
manifests and changelog history.

**Cycle-order strings to keep consistent** (found across the repo):
- `.specify/memory/constitution.md` — Principle IV enumerated order
- `.specify/workflows/sdd/workflow.yml` — `workflow.description`
- `.specify/extensions/sdd/extension.yml` — `extension.description` + command description
- `bundle.yml` — `bundle.description` (note: currently omits `apply`; align while here)
- `.claude/commands/speckit-sdd-run.md` and the matching skill text — step listing

**Alternatives considered**:
- *No version bump*: rejected — hides a behavioral change; risks pin/description
  drift and dishonest history.

## D5. Governance amendment

**Decision**: Amend Constitution **Principle IV** so the canonical order includes
the mandatory branch precondition (e.g. `branch → specify → plan → tasks →
analyze → apply → gate → implement`), bump the constitution version
(`1.0.0 → 1.1.0`), update `Last Amended`, and record the amendment in
`CHANGELOG.md`, per the Governance section.

**Rationale**: Principle IV enumerates the exact step order; leaving it unchanged
while the workflow gains a step creates governance/behavior drift that Principles
II–IV and Governance forbid. Amending in the same change keeps the contract
honest. `validate-bundle` still passes (constitution retains a Version line and
no placeholder tokens).

**Alternatives considered**:
- *Treat branch as outside "cycle semantics" and leave Principle IV untouched*:
  rejected — the request explicitly makes it a workflow step; the governing doc
  must reflect the cycle it governs.

## D6. Graceful degradation & mandatory semantics

**Decision**: "Mandatory" governs intent to always isolate work; it does not
require the impossible. When git is unavailable or the directory is not a repo,
the underlying command already warns and does not report false success (verified
in `create-new-feature-branch.ps1`). The step surfaces that warning; the cycle
does not silently proceed as if isolation succeeded.

**Rationale**: Matches existing, tested behavior and FR-005; avoids inventing new
failure modes.

**Alternatives considered**:
- *Hard-abort the cycle when git is absent*: rejected — too strict for
  non-git contexts and inconsistent with current graceful-degradation behavior;
  a loud warning satisfies the requirement.
