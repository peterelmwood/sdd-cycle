# Data Model: Mandatory Branch-Creation Step in the SDD Workflow

This feature has no runtime data store. The "entities" are the declarative
configuration objects and documents that describe the SDD cycle. Modeling them
makes the consistency requirements (Constitution II) explicit.

## Entity: SDD Workflow Step

A single ordered step in `workflows/sdd/workflow.yml`.

| Field | Meaning | Notes |
|-------|---------|-------|
| `id` | Unique step identifier | New value: `branch` |
| `command` / `type` | What the step invokes (a command) or its kind (`gate`, `prompt`) | Branch step invokes `speckit.git.feature` |
| position | Order within `steps[]` | Branch step is **first**, before `specify` |
| mandatory | Whether the step may be skipped | Branch step is **required** (non-optional) |

**Validation rules**:
- The `branch` step MUST precede the `specify` step.
- The `branch` step MUST be non-optional.
- Existing steps (`specify → plan → tasks → analyze → apply-analysis →
  review-before-implement → implement`) MUST retain their relative order and
  meaning (FR-009).

**State transition (cycle start)**:
```
on shared/integration branch ──[branch step]──▶ on feature branch ──▶ specify …
already on valid feature branch ──[branch step: reuse]──▶ same branch ──▶ specify …
git unavailable ──[branch step: warn]──▶ warning surfaced, no false success
```

## Entity: Feature Branch

An isolated line of work created by the branch step.

| Field | Meaning | Notes |
|-------|---------|-------|
| name | Branch identifier | `NNN-<short-name>` or `YYYYMMDD-HHMMSS-<short-name>`, or explicit `GIT_BRANCH_NAME` |
| number/prefix | Ordering prefix | Sequential (default) or timestamp |
| schema | Naming convention in force | From `feature_numbering` / `branch_numbering` |

**Validation rules**:
- name MUST conform to an accepted schema (FR-003).
- prefix MUST NOT collide with an existing feature branch/directory (FR-004).
- On collision or "already exists", resolve to reuse (same feature) or next
  available (different feature), never overwrite (edge cases).

## Entity: Cycle-Order Description

Any human- or machine-readable statement of the canonical cycle order.

| Instance | Location |
|----------|----------|
| Governance enumeration | `.specify/memory/constitution.md` (Principle IV) |
| Workflow description | `.specify/workflows/sdd/workflow.yml` (`workflow.description`) |
| Extension description | `.specify/extensions/sdd/extension.yml` |
| Bundle description | `bundle.yml` (`bundle.description`) |
| Launcher step listing | `.claude/commands/speckit-sdd-run.md` (+ matching skill) |

**Validation rule (consistency invariant)**: All instances MUST describe the same
ordered set of steps, now including the mandatory branch step (FR-007, FR-008).

## Entity: Manifest Version Pin

Version relationships enforced by `validate-bundle.ps1`.

| Relationship | Rule |
|--------------|------|
| `bundle.yml` workflow pin ↔ `workflow.yml` version | MUST be equal (assertion 2) |
| `speckit_version` floors across manifests | MUST be mutually compatible (assertion 3) |
| Referenced files | MUST exist (assertion 4) |
| Constitution | MUST be ratified: Version line present, no placeholder tokens (assertion 5) |

**Change for this feature**: workflow version `1.1.0 → 1.2.0`; bundle pin updated
to match; constitution version `1.0.0 → 1.1.0` (still ratified).
