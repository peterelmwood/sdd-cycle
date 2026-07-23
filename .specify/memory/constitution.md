# SDD Cycle Constitution

The governing principles for the **SDD Cycle** bundle — a portable Spec Kit
component (an `sdd` workflow plus a single-gate launcher). These principles bind
every change to this repository.

## Core Principles

### I. Local-First & Portable

The bundle MUST install and run from a local clone, without depending on a hosted
catalog, registry, or network service. Its portable core (the `sdd` workflow) MUST
work with any Spec Kit integration; integration-specific launchers (e.g. the
Claude Code slash command) are additive conveniences, never the only path. A user
with a clone and a supported `specify` CLI MUST be able to install and use it.

### II. Manifests Are the Contract

Every declared identifier, version, and requirement across `bundle.yml`,
`extensions/sdd/extension.yml`, `workflows/sdd/workflow.yml`, and
`.specify/extensions.yml` MUST be internally consistent and machine-verifiable.
The version a bundle pins for a component MUST equal the version that component
declares. Declared `speckit_version` floors MUST be mutually compatible. Every
file a manifest references MUST exist. Consistency is not aspirational — it is
enforced by an automated check (Principle V).

### III. Docs Must Be Executable

Every command shown in user-facing documentation MUST succeed as written on the
supported Spec Kit version, and every path it references MUST exist. Known
limitations MUST be documented alongside a working workaround so a user is never
left without a path forward. Documentation drift is treated as a defect.

### IV. Behavior-Preserving Packaging

Readiness, packaging, documentation, and governance work MUST NOT alter the SDD
cycle's semantics — its step order (`specify → plan → tasks → analyze → apply →
gate → implement`), its single pre-implement human gate, or the meaning of any
step. Changes to cycle behavior are a separate, explicit concern from making the
bundle installable and correct.

### V. Guardrail Before Release

A single repeatable validation check MUST exist and MUST pass before any release
or merge that touches manifests, documentation, or the constitution. The check
MUST fail loudly — non-zero exit with a specific, identifying message — on any
manifest parse error, version inconsistency, missing file reference, or
unratified (placeholder) constitution. Correctness achieved once MUST be defended
mechanically against regression.

## Additional Constraints

- **Supported toolchain**: The declared minimum Spec Kit version (`>=0.8.5`) is
  the intended floor. Changes MUST be verified against the toolchain actually
  installed for development.
- **Scope discipline**: External distribution (public catalog publishing, hosted
  archives) is explicitly out of scope unless and until deliberately adopted;
  documentation MUST state plainly which distribution paths are and are not
  supported.

## Governance

This constitution supersedes ad-hoc practice for this repository. Amendments MUST
be made deliberately, recorded in `CHANGELOG.md`, and reflected in the validation
check where they introduce a verifiable rule. Every pull request and release MUST
verify compliance: the validation check (Principle V) MUST pass, and reviewers
MUST confirm the change does not violate Principles I–IV. Complexity that appears
to conflict with a principle MUST be justified explicitly or removed.

**Version**: 1.0.0 | **Ratified**: 2026-06-30 | **Last Amended**: 2026-06-30
