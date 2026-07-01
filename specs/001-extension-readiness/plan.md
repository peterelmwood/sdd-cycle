# Implementation Plan: Extension Readiness

**Branch**: `001-extension-readiness` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-extension-readiness/spec.md`

## Summary

Make this repository trustworthy and frictionless to adopt as a Spec Kit bundle
(an `sdd` workflow + a launcher extension). The work is packaging and correctness,
not behavior change: reconcile manifest versions, ratify a real constitution,
tighten the documentation so every command works and every known limitation has a
stated workaround, add publishable-project metadata, and ship a single repeatable
validation check (plus a documented build step) that keeps the bundle installable
over time.

## Technical Context

**Language/Version**: YAML 1.x manifests; Markdown docs; PowerShell 7+ validation
script (project is configured with `script: ps` in `init-options.json`). Bash
parity documented, not required.

**Primary Dependencies**: `specify` CLI (Spec Kit) `0.12.2` installed, floor
declared `>=0.8.5`; `git` extension already installed; no third-party runtime
libraries.

**Storage**: N/A (files in the repository only).

**Testing**: A repeatable validation script that parses every manifest,
cross-checks versions/IDs/requirements, and asserts referenced files exist. It is
both the test and the CI guardrail; it must exit non-zero on any inconsistency.

**Target Platform**: Any machine with `specify` installed; authored/verified on
Windows PowerShell.

**Project Type**: Spec Kit bundle (distributable extension + workflow), not an
application. Single repository, no `src/` runtime tree.

**Performance Goals**: Validation check completes in under one minute (SC-005).

**Constraints**: No change to the SDD cycle's steps, gate, or semantics. Docs must
reference only paths that exist. Versions must be internally consistent.

**Scale/Scope**: Small — ~8 manifest/doc files, one new validation script, one new
constitution, plus standard OSS metadata. Local-clone install path only; external
catalog/archive publishing out of scope.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) is currently the
**unfilled template** — there are no ratified principles to check against yet.
This is itself a spec requirement (**FR-005**). Therefore:

- **Initial gate**: PASS with the explicit note that this feature ratifies the
  constitution as part of its scope. No principle can be violated because none is
  yet ratified.
- **Principles this feature will ratify and immediately comply with** (drafted in
  research, finalized via `speckit.constitution`):
  1. *Local-first & portable* — components install from a clone and work without a
     hosted catalog.
  2. *Manifests are the contract* — every declared version/ID/requirement must be
     internally consistent and machine-verifiable.
  3. *Docs must be executable* — every documented command must succeed as written.
  4. *Behavior-preserving packaging* — readiness work never alters the SDD cycle's
     semantics.
  5. *Guardrail before release* — a repeatable validation check gates correctness.
- **Post-design re-check**: performed at the end of Phase 1 below.

No violations requiring Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-extension-readiness/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (manifest/entity relationships)
├── quickstart.md        # Phase 1 output (how to verify readiness)
├── contracts/
│   └── validation-check.md   # What the validation check must assert
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
.
├── bundle.yml                          # bundle manifest (pins components)
├── extensions/sdd/
│   ├── extension.yml                   # launcher extension manifest
│   └── commands/speckit.sdd.run.md
├── workflows/sdd/workflow.yml          # sdd workflow (step graph)
├── commands/speckit-sdd-run.md         # Claude Code slash command launcher
├── .specify/
│   ├── extensions.yml                  # installed extensions + lifecycle hooks
│   └── memory/constitution.md          # ← to be ratified (FR-005)
├── scripts/
│   └── validate-bundle.ps1             # ← new: the repeatable validation check (FR-006/007)
├── README.md                           # ← tightened (FR-001/002/008/009/010)
├── CHANGELOG.md                        # ← new: publishable metadata (FR-011)
├── CONTRIBUTING.md                     # ← new: publishable metadata (FR-011)
└── LICENSE                             # existing
```

**Structure Decision**: This is a bundle repository, not an app, so there is no
`src/`/`tests/` runtime tree. The "code" under change is the manifest/doc set plus
one PowerShell validation script under `scripts/`. All paths above are real
existing files except those marked "new" / "to be ratified".

## Complexity Tracking

> No Constitution Check violations. Section intentionally empty.
