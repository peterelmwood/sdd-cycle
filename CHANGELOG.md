# Changelog

All notable changes to the **SDD Cycle** bundle are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] — 2026-07-23

Deliberate cycle-behavior change: make feature-branch creation a first-class,
**mandatory step** of the SDD cycle rather than an implicit side effect of the
specify-time git hook. The cycle now begins with a `branch` step so spec, plan,
tasks, and implementation always land on a dedicated feature branch, never on a
shared/integration branch.

### Added

- Mandatory `branch` step at the head of `.specify/workflows/sdd/workflow.yml`,
  delegating to the git extension's `speckit.git.feature` (sequential
  `NNN-<short-name>` or timestamp schema; honors `GIT_BRANCH_NAME`). Reuses an
  existing valid feature branch when present; warns without false success when
  git is unavailable.

### Changed

- Bumped the `sdd` workflow to `1.2.0` and the bundle to `1.2.0` (with the
  matching pin in `bundle.yml`) to reflect the behavioral change.
- Updated every cycle-order description to the canonical
  `branch → specify → plan → tasks → analyze → apply → gate → implement`:
  `workflow.yml`, `bundle.yml`, `.specify/extensions/sdd/extension.yml`, and the
  `speckit-sdd-run` launcher (command + skill, in both `.claude/` and the
  extension source). The launcher now names the mandatory branch step as its
  explicit first step.

### Governance

- Amended constitution **Principle IV** (Behavior-Preserving Packaging) to
  include the mandatory branch step in the canonical order and require the
  addition to be reflected consistently across manifests, launcher, and the order
  enumeration. Constitution version bumped `1.0.0 → 1.1.0` (Last Amended
  2026-07-23).

## [1.1.0] — 2026-06-30

Readiness release: make the repository trustworthy and frictionless to adopt as a
Spec Kit bundle. No change to the SDD cycle's behavior (steps, gate, or semantics).

### Added

- `scripts/validate-bundle.ps1` — a repeatable, dependency-free consistency check
  that asserts bundle-pinned versions match component manifests, `speckit_version`
  floors agree, manifest file references exist, and the constitution is ratified.
  Exits non-zero with a specific message on any failure.
- Ratified project constitution (`.specify/memory/constitution.md`) with five
  principles: Local-First & Portable, Manifests Are the Contract, Docs Must Be
  Executable, Behavior-Preserving Packaging, and Guardrail Before Release
  (version 1.0.0).
- README **Validate** and **Distribution** sections documenting the check and the
  supported vs. unsupported distribution paths.
- `CONTRIBUTING.md`.

### Changed

- Bumped bundle version to `1.1.0` to align the bundle with the workflow line it
  ships.
- Tightened README: consolidated distribution caveats, updated the repository
  layout for the new files.

### Verified

- Component version pins in `bundle.yml` already matched their component manifests
  (extension `sdd@1.0.0`, workflow `sdd@1.1.0`); the new check now guards this
  against future drift.
