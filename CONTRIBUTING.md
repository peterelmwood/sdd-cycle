# Contributing to SDD Cycle

Thanks for your interest in improving the **SDD Cycle** bundle. This is a small,
portable [Spec Kit](https://github.com/github/spec-kit) component (an `sdd`
workflow plus a single-gate launcher). Contributions that keep it correct,
portable, and honestly documented are very welcome.

## Ground rules (from the [constitution](.specify/memory/constitution.md))

1. **Local-first & portable** — it must install and run from a clone, with no
   hosted catalog dependency. The workflow must stay integration-agnostic.
2. **Manifests are the contract** — versions, ids, and requirements across
   `bundle.yml`, `extensions/sdd/extension.yml`, `workflows/sdd/workflow.yml`, and
   `.specify/extensions.yml` must stay internally consistent.
3. **Docs must be executable** — every command shown in the docs must succeed as
   written, and every referenced path must exist. Document limitations with a
   working workaround.
4. **Behavior-preserving packaging** — do not change the SDD cycle's step order or
   its single pre-implement gate as part of packaging/docs work.
5. **Guardrail before release** — the validation check must pass before any merge
   or release.

## Before you open a PR

Run the consistency check and make sure it passes:

```powershell
pwsh ./scripts/validate-bundle.ps1
```

If you changed anything version-related, run through the relevant scenarios in
`specs/001-extension-readiness/quickstart.md`. If your change is user-visible, add
a `CHANGELOG.md` entry under a new version heading.

## Making a change

- Keep edits focused; match the surrounding style.
- If you add a new consistency rule, encode it in `scripts/validate-bundle.ps1` so
  it is enforced, not just documented.
- Bump versions using [SemVer](https://semver.org/): the component's own manifest
  and its pin in `bundle.yml` must move together.

## Releasing

1. Ensure `pwsh ./scripts/validate-bundle.ps1` exits `0`.
2. Update `CHANGELOG.md` and the relevant `version` fields.
3. Build the artifact: `specify bundle build` (emits a versioned `.zip` under
   `dist/`).
