---
name: speckit-sdd-run
description: 'Run the full SDD cycle: specify→plan→tasks→analyze→apply→gate→implement'
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: sdd:commands/speckit.sdd.run.md
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
taken. Project/extension hooks (feature branch, auto-commit, agent-context
refresh) may run during specify/plan — that is expected; let them run.

1. `speckit.specify` with the spec.
2. `speckit.plan`.
3. `speckit.tasks`.
4. `speckit.analyze` (always — cross-artifact consistency check).
5. **Apply analysis findings:** apply every remediation suggestion from the
   analyze run that resolves an inconsistency, ambiguity, or gap across
   `spec.md`, `plan.md`, and `tasks.md`, editing those files directly. Do not
   ask for confirmation. If analyze found no issues, make no changes and say so.

## Gate before implementation

STOP here (the workflow's `review-before-implement` gate). Summarize what
specify/plan/tasks produced and the analysis fixes you applied, then ask the
user to **approve** or **reject** starting implementation.

- If rejected: abort. Do not run `speckit.implement`.
- If approved: run `speckit.implement`.