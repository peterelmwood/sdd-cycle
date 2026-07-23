# Quickstart: Verify Extension Readiness

Validation scenarios that prove the feature works end-to-end. Run from the
repository root.

## Prerequisites

- `specify` CLI installed (`specify --version`; verified against 0.12.2).
- PowerShell 7+ (`pwsh`).
- A clean checkout of this repository.

## Scenario A — The bundle validates (US2, US3)

```powershell
pwsh ./scripts/validate-bundle.ps1
```

**Expected**: exit code `0`; summary shows version-match, floor-consistency,
file-reference, and constitution checks all `PASS`. See
[contracts/validation-check.md](./contracts/validation-check.md).

## Scenario B — The check catches regressions (US3)

1. Edit `bundle.yml` so the `sdd` workflow is pinned to a wrong version (e.g.
   `9.9.9`).
2. Run `pwsh ./scripts/validate-bundle.ps1`.

**Expected**: non-zero exit; a line names the version mismatch. Revert the edit
and re-run → exit `0`.

## Scenario C — Manifests are internally consistent (US2)

Inspect the four manifests and confirm:

- The version `bundle.yml` pins for the `sdd` workflow equals
  `workflows/sdd/workflow.yml`'s `workflow.version`.
- The version `bundle.yml` pins for the `sdd` extension equals
  `extensions/sdd/extension.yml`'s `extension.version`.
- The `speckit_version` floors agree across manifests.

**Expected**: no contradictions (this is what Scenario A automates).

## Scenario D — Constitution is real (US2)

Open `.specify/memory/constitution.md`.

**Expected**: named principles, a governance section, and a
`Version | Ratified | Last Amended` line — zero `[PLACEHOLDER]` tokens.

## Scenario E — Install path works as documented (US1)

Follow the README **Install** section verbatim against a separate Spec Kit
project:

```bash
specify workflow add /path/to/sdd-cycle/workflows/sdd/workflow.yml
cp /path/to/sdd-cycle/commands/speckit-sdd-run.md .claude/commands/
```

Then `specify workflow list` and `specify workflow info sdd`.

**Expected**: every command succeeds; `sdd` is listed; the step graph matches the
documented `specify → plan → tasks → analyze → apply → gate → implement` order.

## Scenario F — Distributable artifact (US3)

```powershell
specify bundle build
```

**Expected**: a versioned bundle archive is produced under `dist/` (git-ignored).
