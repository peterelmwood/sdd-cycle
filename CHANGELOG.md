# Changelog

All notable changes to the **SDD Cycle** bundle are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
