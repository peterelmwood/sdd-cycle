# Contract: Bundle Validation Check

The interface this feature exposes to maintainers/CI. Implemented as
`scripts/validate-bundle.ps1`.

## Invocation

```powershell
pwsh ./scripts/validate-bundle.ps1
```

- No required arguments. Runs from the repository root.
- Read-only: MUST NOT modify any file.

## Exit codes

| Code | Meaning |
|------|---------|
| `0`  | All assertions passed. |
| non-`0` | At least one assertion failed; details printed to output. |

## Output

- On success: a summary listing each assertion group checked and `PASS`.
- On failure: for each failed assertion, a line naming the artifact and the
  specific problem (e.g., `bundle.yml pins workflow sdd@1.0.0 but
  workflows/sdd/workflow.yml declares 1.1.0`).

## Assertions (MUST all hold for exit 0)

1. **Parse**: `bundle.yml`, `extensions/sdd/extension.yml`,
   `workflows/sdd/workflow.yml`, and `.specify/extensions.yml` all parse as valid
   YAML.
2. **Extension version match**: for every `provides.extensions[]` entry in
   `bundle.yml`, the pinned `version` equals the `extension.version` in that
   extension's manifest.
3. **Workflow version match**: for every `provides.workflows[]` entry in
   `bundle.yml`, the pinned `version` equals the `workflow.version` in that
   workflow's manifest.
4. **Spec Kit floor consistency**: the `speckit_version` (or
   `requires.speckit_version`) in `bundle.yml`, `extension.yml`, and
   `workflow.yml` are all present and mutually compatible.
5. **File references exist**: every `provides.commands[].file` in `extension.yml`
   resolves to an existing file; the workflow path the bundle ships exists.
6. **Constitution ratified**: `.specify/memory/constitution.md` contains no
   template placeholder tokens and includes a version/ratified line.

## Behavioral tests (quickstart proves these)

- **T1 (green)**: on the corrected repository, the check exits `0`.
- **T2 (red)**: temporarily editing `bundle.yml` to pin a wrong workflow version
  causes a non-zero exit naming the mismatch; reverting restores exit `0`.
- **T3 (red)**: temporarily pointing an `extension.yml` command `file` at a
  missing path causes a non-zero exit naming the missing file.
