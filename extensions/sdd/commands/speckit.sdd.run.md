---
description: "Run the full SDD cycle: branch→specify→plan→tasks→analyze→apply→gate→implement"
---

# SDD Cycle Launcher

Drive the project's `sdd` workflow to completion **in this session**, with a
single approval gate before implementation. Follow the `sdd` workflow's step
order. Do NOT run `specify workflow run` — that dispatches each step as a
separate headless agent process; instead invoke the Spec Kit commands directly
here.

## Determine the spec

The feature description is: `$ARGUMENTS`

- If that is empty, ask the user: **"What do you want to build?"** and use their
  reply as the spec. Never proceed with an empty spec.
- Otherwise use `$ARGUMENTS` verbatim as the spec.

## Run the chain (no stops until the gate)

Invoke these Spec Kit commands in order, passing the spec where a description is
taken. Project/extension hooks (auto-commit, agent-context refresh) may run
during specify/plan — that is expected; let them run.

1. **Create the feature branch (mandatory).** Ensure the cycle is on a dedicated
   feature branch before producing any artifacts. The `speckit.specify` command's
   mandatory `before_specify` git hook creates it (`speckit.git.feature`,
   sequential `NNN-<short-name>` or timestamp schema; honors `GIT_BRANCH_NAME`).
   This step MUST NOT be skipped — do not produce spec/plan/tasks on a
   shared/integration branch. If already on a valid feature branch it is reused;
   if git is unavailable a clear warning is surfaced and the cycle does not
   silently proceed as if the work were isolated.
2. `speckit.specify` with the spec.
3. `speckit.plan`.
4. `speckit.tasks`.
5. `speckit.analyze` (always — cross-artifact consistency check).
6. **Apply analysis findings:** apply every remediation suggestion from the
   analyze run that resolves an inconsistency, ambiguity, or gap across
   `spec.md`, `plan.md`, and `tasks.md`, editing those files directly. Do not
   ask for confirmation. If analyze found no issues, make no changes and say so.

## Gate before implementation

STOP here (the workflow's `review-before-implement` gate). Summarize what
specify/plan/tasks produced and the analysis fixes you applied, then ask the
user to **approve** or **reject** starting implementation.

- If rejected: abort. Do not run `speckit.implement`.
- If approved: run `speckit.implement`.
