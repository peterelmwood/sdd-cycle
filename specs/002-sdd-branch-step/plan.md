# Implementation Plan: Mandatory Branch-Creation Step in the SDD Workflow

**Branch**: `002-sdd-branch-step` | **Date**: 2026-07-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-sdd-branch-step/spec.md`

## Summary

Make feature-branch creation a first-class, **mandatory step** of the SDD cycle
rather than an implicit side effect of a specify-time git hook. The cycle's two
authoritative descriptions — the declarative `workflows/sdd/workflow.yml` and the
in-session launcher — will name the branch step explicitly and mark it required,
positioned before `specify`. Branch creation continues to reuse the existing,
tested git extension command (`speckit.git.feature`) and its naming schema
(sequential `NNN-<short-name>` or timestamp), so no new branch mechanism is
introduced. Because this deliberately extends the canonical cycle order that the
constitution enumerates, the change is carried through every manifest and the
governance document so they stay mutually consistent, and the existing
`validate-bundle` guardrail must continue to pass.

## Technical Context

**Language/Version**: Declarative YAML/JSON manifests + Markdown docs; PowerShell
7 and Bash helper scripts (already present, reused unchanged where possible).

**Primary Dependencies**: Spec Kit (`specify` CLI, `>=0.8.5`); the installed
`git` extension (`speckit.git.feature`, sequential/timestamp numbering); the
`before_specify` hook wiring in `.specify/extensions.yml`.

**Storage**: N/A (files in the repository).

**Testing**: `scripts/validate-bundle.ps1` (the Principle V guardrail) plus manual
quickstart validation of a dry-run cycle start.

**Target Platform**: Local developer checkout with a supported `specify` CLI;
Windows/macOS/Linux via the PowerShell and Bash script twins.

**Project Type**: Spec Kit bundle (portable workflow + launcher), not an
application. "Source" is manifests, docs, workflow definitions, and scripts.

**Performance Goals**: N/A — correctness and consistency, not throughput.

**Constraints**: Must preserve the meaning and relative order of all existing
steps and the single pre-implement human gate (Constitution IV); all four
manifests must stay internally consistent (Constitution II); `validate-bundle`
must pass (Constitution V).

**Scale/Scope**: One workflow definition, one launcher command doc, four
manifests, one governance document, one changelog. No runtime services.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Assessment |
|-----------|------------|
| **I. Local-First & Portable** | PASS. The branch step lives in the portable `workflow.yml` and reuses the already-bundled git extension. No hosted catalog, registry, or network dependency is added. |
| **II. Manifests Are the Contract** | PASS with required work. Adding the step changes the `sdd` workflow's behavior, so its version is bumped and every pin/description that names the cycle (`bundle.yml`, `sdd/extension.yml`, `workflow.yml`, launcher) is updated in lock-step. `validate-bundle` enforces the pin==version and file-existence rules. |
| **III. Docs Must Be Executable** | PASS. The launcher doc and quickstart show commands that succeed as written; branch step reuses an existing, working command. |
| **IV. Behavior-Preserving Packaging** | DELIBERATE, EXPLICIT CHANGE — not a violation. Principle IV forbids *packaging/docs/governance* work from silently altering cycle semantics; it explicitly permits deliberate cycle-behavior changes as "a separate, explicit concern." This feature is exactly such a change. All existing steps keep their meaning and relative order and the single gate is preserved; only a mandatory precondition step is prepended. The canonical-order enumeration in Principle IV is amended in the same change so governance and behavior stay in sync (recorded in `CHANGELOG.md`, constitution version bumped). |
| **V. Guardrail Before Release** | PASS. `validate-bundle.ps1` must pass after the change; if the canonical-order enumeration becomes a machine-verifiable rule it is added to the check. No release/merge without a green guardrail. |

**Result**: No unjustified violations. The single Principle IV interaction is an
intended, explicitly-scoped cycle change, handled through governance rather than
worked around. Proceed.

## Project Structure

### Documentation (this feature)

```text
specs/002-sdd-branch-step/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── sdd-branch-step.md
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

Files this feature changes or governs (no application source tree; the "surface"
is manifests, workflow definitions, docs, and governance):

```text
.specify/
├── workflows/sdd/workflow.yml        # ADD mandatory `branch` step; bump version
├── extensions/sdd/extension.yml      # update cycle-order description string
├── extensions.yml                    # confirm before_specify hook stays consistent
└── memory/constitution.md            # amend Principle IV canonical order; version bump

bundle.yml                            # bump pinned sdd workflow version; update description
CHANGELOG.md                          # record workflow + constitution amendments
.claude/commands/speckit-sdd-run.md   # document mandatory branch step as explicit Step 1
.claude/skills/speckit-sdd-run/       # keep launcher skill text in sync (if it restates order)
scripts/validate-bundle.ps1           # extend guardrail if canonical-order becomes a checked rule
```

**Structure Decision**: This is a bundle-configuration feature. The work is
concentrated in the `sdd` workflow definition and the documents/manifests that
must agree with it. The branch step **delegates to the existing git extension
command** (`speckit.git.feature`) rather than introducing a new script, keeping
the change minimal and behavior-preserving.

## Complexity Tracking

> No Constitution violations require justification. The Principle IV interaction
> is an intended cycle change carried through governance, not a complexity
> workaround, so no entries are required here.
