# Phase 1 Data Model: Extension Readiness

These are the artifacts and the consistency relationships the validation check
enforces. "Fields" are the manifest keys that matter for readiness.

## Bundle manifest — `bundle.yml`

- `bundle.id` (string) — must equal the repo's bundle identity (`sdd-cycle`).
- `bundle.version` (semver) — the release version of the bundle.
- `provides.extensions[]` — each `{id, version}` the bundle ships.
- `provides.workflows[]` — each `{id, version}` the bundle ships.
- `requires.speckit_version` (range) — declared floor.

**Relationships**:
- For each `provides.extensions[i]`: `version` MUST equal the version in that
  extension's own manifest (see Extension manifest).
- For each `provides.workflows[i]`: `version` MUST equal the version in that
  workflow's own manifest (see Workflow manifest).

## Extension manifest — `extensions/sdd/extension.yml`

- `extension.id` (string) — MUST equal the `provides.extensions[].id` that pins it.
- `extension.version` (semver) — MUST equal the bundle's pinned version for it.
- `requires.speckit_version` (range) — MUST be compatible with the bundle floor.
- `provides.commands[].file` (path) — MUST reference a file that exists on disk.

## Workflow manifest — `workflows/sdd/workflow.yml`

- `workflow.id` (string) — MUST equal the `provides.workflows[].id` that pins it.
- `workflow.version` (semver) — MUST equal the bundle's pinned version for it.
- `requires.speckit_version` (range) — MUST be compatible with the bundle floor.
- `requires.integrations.any[]` — the integrations the workflow supports.
- `steps[]` — the step graph; order is documentation-visible and must match README.

## Extensions registry — `.specify/extensions.yml`

- `installed[]` — extensions active in this project.
- `hooks.*[]` — lifecycle hooks; each `{extension, command, enabled, optional}`.

**Relationship**: informational for readiness; the validation check confirms it
parses. Not version-pinned by the bundle.

## Constitution — `.specify/memory/constitution.md`

- MUST contain ratified principles and a concrete
  `Version | Ratified | Last Amended` line.
- MUST NOT contain template placeholder tokens (`[PROJECT_NAME]`,
  `[PRINCIPLE_*]`, `[SECTION_*]`, `[GOVERNANCE_RULES]`, etc.).

## Validation check — `scripts/validate-bundle.ps1`

- Inputs: the manifests and constitution above (read-only).
- Output: exit code (0 pass / non-zero fail) + human-readable summary naming each
  assertion checked and any that failed.

## Publishable metadata

- `LICENSE` (exists), `CHANGELOG.md` (new), `CONTRIBUTING.md` (new), `README.md`
  (updated). No version constraints; presence + accuracy only.

## Consistency invariants (what "ready" means, formally)

1. `∀ component ∈ provides`: `component.version == component's own manifest version`.
2. `∀ manifest`: `speckit_version` floors are mutually compatible.
3. `∀ file-reference ∈ manifests`: the referenced path exists.
4. `constitution` has no placeholder tokens.
5. `∀ command shown in README install section`: the referenced path exists.
