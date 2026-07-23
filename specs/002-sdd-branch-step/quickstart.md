# Quickstart: Validate the Mandatory Branch Step

Runnable checks that prove the feature works end-to-end. Run from the repository
root on a supported `specify` CLI with PowerShell 7 available.

## Prerequisites

- A local clone of this bundle.
- `pwsh` (PowerShell 7+) on PATH.
- `git` available (for the branch-behavior check).

## 1. Guardrail passes (contract C5)

```bash
pwsh ./scripts/validate-bundle.ps1
echo "exit=$?"
```

**Expected**: prints success and `exit=0`. Fails loudly (non-zero) if any
manifest is inconsistent, a referenced file is missing, or the constitution is
unratified.

## 2. Workflow declares the mandatory branch step first (contract C1)

Inspect `.specify/workflows/sdd/workflow.yml`:

**Expected**:
- The first entry under `steps:` has `id: branch` and invokes
  `speckit.git.feature`.
- The following step ids are, in order: `specify`, `plan`, `tasks`, `analyze`,
  `apply-analysis`, `review-before-implement`, `implement`.
- `workflow.version` is `1.2.0`.

## 3. Bundle pin matches workflow version (contract C2)

**Expected**: `bundle.yml` pins the `sdd` workflow at the same version shown in
`workflow.yml` (`1.2.0`). (Also asserted by step 1.)

## 4. Cycle-order descriptions agree (contract C3)

Confirm the branch step appears, in the same position, in each cycle-order
description: constitution Principle IV, `workflow.yml` description,
`sdd/extension.yml` description, `bundle.yml` description, and the
`speckit-sdd-run` launcher (command + skill).

**Expected**: every instance includes the branch step; none shows the old order
without it.

## 5. Governance amended and ratified (contract C4)

Inspect `.specify/memory/constitution.md`:

**Expected**: Principle IV's canonical order includes the branch step; the
`Version` line reads `1.1.0` with an updated `Last Amended` date; no placeholder
tokens remain. `CHANGELOG.md` records the amendment.

## 6. Branch creation behaves correctly (contract C6)

Dry-run the underlying branch command (does not create a branch):

```bash
pwsh .specify/extensions/git/scripts/powershell/create-new-feature-branch.ps1 \
  -Json -DryRun -ShortName "demo-feature" "demo feature"
```

**Expected**: JSON with a `BRANCH_NAME` following the numerical schema
(`NNN-demo-feature`) and a `FEATURE_NUM` that does not collide with existing
feature directories. Re-running while already on a valid feature branch reuses it
(no renumber); in a non-git directory the command warns and does not report a
false success.

## Done when

- Steps 1–6 all meet their expected outcomes.
- `validate-bundle.ps1` exits `0`.
