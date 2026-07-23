# Contract: Mandatory Branch Step in the SDD Workflow

This contract defines the observable, verifiable guarantees the feature adds. It
is the acceptance surface for `/speckit-tasks` and the quickstart.

## C1. Workflow definition declares a mandatory branch step

**Given** `.specify/workflows/sdd/workflow.yml`
**Then**:
- `steps[0].id == "branch"` (the branch step is first).
- The branch step invokes the git feature command (`speckit.git.feature`) —
  i.e. it delegates to the existing extension, not a new script.
- The branch step is not marked optional; nothing in the definition permits
  skipping it and proceeding to `specify`.
- The steps that follow are, in order: `specify`, `plan`, `tasks`, `analyze`,
  `apply-analysis`, `review-before-implement` (gate), `implement` — unchanged in
  order and meaning.
- `workflow.version == "1.2.0"`.

## C2. Bundle pin matches workflow version

**Given** `bundle.yml`
**Then** the pinned `sdd` workflow version equals `workflow.yml`'s version
(`1.2.0`), so `validate-bundle.ps1` assertion 2 passes.

## C3. Cycle-order descriptions are consistent

**Given** every cycle-order description instance (constitution Principle IV,
`workflow.yml` description, `sdd/extension.yml` description, `bundle.yml`
description, launcher command + skill)
**Then** each names the mandatory branch step in the same position, and no
instance describes the old order without it. (Discrepancy count == 0.)

## C4. Governance amended and still ratified

**Given** `.specify/memory/constitution.md`
**Then**:
- Principle IV's canonical order includes the branch step.
- The `Version` line is present and bumped (`1.1.0`); `Last Amended` updated.
- No placeholder tokens remain (still ratified) — `validate-bundle.ps1`
  assertion 5 passes.
- `CHANGELOG.md` records the workflow and constitution amendments.

## C5. Guardrail passes

**Given** the repository after all edits
**When** `pwsh ./scripts/validate-bundle.ps1` runs
**Then** it exits `0` with no manifest parse error, version inconsistency,
missing file reference, or unratified-constitution error.

## C6. Branch creation behavior (reuse & degradation)

**Given** the branch step runs
**Then**:
- Starting on a shared/integration branch in a git repo → a new correctly-named
  feature branch is active before `specify` produces artifacts.
- Already on a valid feature branch for the current feature → that branch is
  reused (no duplicate/renumbered branch).
- Git unavailable / not a repo → a clear warning is surfaced and no false
  success is reported; the cycle does not silently create artifacts as if
  isolated.

## Verification method

- C1–C4: inspection / parse of the named files (can be asserted mechanically).
- C5: run `scripts/validate-bundle.ps1`.
- C6: `speckit.git.feature` dry-run / behavioral check per `quickstart.md`;
  reuse and degradation are existing, tested behaviors of the underlying script.
