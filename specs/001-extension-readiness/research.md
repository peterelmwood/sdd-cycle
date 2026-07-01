# Phase 0 Research: Extension Readiness

## R1 — Concrete manifest/version inconsistencies present today

**Decision**: Treat version reconciliation as a known, enumerated fix set, not an
open question.

**Findings** (read from the repo):

- `bundle.yml` → `provides.workflows[sdd].version: 1.0.0`, but
  `workflows/sdd/workflow.yml` → `workflow.version: 1.1.0`. **Mismatch** (FR-003).
- `bundle.yml` → `provides.extensions[sdd].version: 1.0.0` and
  `extensions/sdd/extension.yml` → `extension.version: 1.0.0`. **Consistent.**
- `speckit_version` floor: `bundle.yml` `>=0.8.5`, `extension.yml` `>=0.8.5`,
  `workflow.yml` `requires.speckit_version >=0.8.5`. **Consistent.**

**Rationale**: The bundle must pin the true component versions. The bundle already
being `1.0.0` while it ships workflow `1.1.0` is exactly the drift FR-003/SC-003
target.

**Decision**: Align `bundle.yml` to pin workflow `sdd` at `1.1.0`. Bundle's own
version is a separate concern; bump it (see R5).

**Alternatives considered**: Downgrade the workflow to 1.0.0 — rejected, the 1.1.0
step graph is the shipped/installed one.

## R2 — What "installable & documented" must guarantee

**Decision**: The README is the source of truth for install; every command in it
must run clean on Spec Kit `0.12.2`.

**Findings**: The correct install verbs (validated live earlier this session) are
`specify workflow add <path>` for the workflow and, on Claude, copying
`commands/speckit-sdd-run.md` into `.claude/commands/`. `specify extension add`
resolves catalog names/local dirs, not a workflow `.yml` path. The README already
documents this but must stay exact.

**Rationale**: FR-001/FR-002/SC-001/SC-002 — first-run success requires zero
broken commands and no references to nonexistent paths.

**Alternatives considered**: Auto-generating docs — overkill for ~1 README.

## R3 — Constitution ratification

**Decision**: Replace the placeholder constitution via `speckit.constitution` with
five principles (listed in plan.md Constitution Check), versioned `1.0.0`,
ratified 2026-06-30.

**Rationale**: FR-005/SC-004 require zero placeholders; a bundle that sells SDD
should itself be governed.

**Alternatives considered**: Deleting the constitution — rejected; Spec Kit
commands read it, and it is a credibility signal for an SDD extension.

## R4 — Validation check design

**Decision**: One PowerShell script `scripts/validate-bundle.ps1` that:
1. Parses `bundle.yml`, `extensions/sdd/extension.yml`,
   `workflows/sdd/workflow.yml`, `.specify/extensions.yml` (fail on parse error).
2. Asserts each component version in its own manifest equals the version
   `bundle.yml` pins.
3. Asserts `speckit_version` floors are mutually consistent.
4. Asserts every file referenced by a manifest (extension command files, workflow
   path) exists on disk.
5. Asserts the constitution has no `[PLACEHOLDER]`/template tokens.
6. Exits `0` on success with a summary; non-zero with a specific message on any
   failure.

**Rationale**: FR-006/FR-007/SC-005 — repeatable, fast, self-describing,
fails loudly. PowerShell chosen because `init-options.json` sets `script: ps`;
Windows is the authoring platform.

**Alternatives considered**: Bash script (documented as future parity), or a
hosted CI-only check — rejected as heavier than needed; the script can be wired
into CI later but must run locally standalone.

## R5 — Versioning & release metadata

**Decision**: Bump `bundle.yml` bundle version to reflect the readiness release
(1.0.0 → 1.1.0 to match the shipped workflow line), add `CHANGELOG.md` and
`CONTRIBUTING.md`. Document the build step `specify bundle build` (already the
supported artifact path per README).

**Rationale**: FR-009/FR-011/SC-006 — a stranger can adopt/contribute; a
maintainer can cut a versioned artifact in one step.

**Alternatives considered**: Publishing to a public catalog/archive host —
explicitly out of scope per spec Assumptions.

## R6 — Known limitations to keep documented

**Decision**: Preserve and keep current the README notes that (a) the extension
command is not user-invocable on Claude (use the slash command), (b) no published
archive exists (install from clone with `--dev`), (c) `specify bundle install` is
not the install path. Verify each statement still holds on 0.12.2.

**Rationale**: FR-008/FR-010 — users must never be left without a working path.
