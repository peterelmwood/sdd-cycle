# SDD Cycle — reusable Spec Kit components

A standalone, portable [Spec Kit](https://github.com/github/spec-kit) bundle that
chains the spec-driven development cycle behind one launcher, with a single
human gate before any code is written:

```
specify → plan → tasks → analyze → (apply analysis fixes) → ⛔ gate → implement
```

`analyze` always runs after `tasks` and its remediation suggestions are applied
automatically; the only stop is the approval gate before `implement`.

## Components

- **`sdd` workflow** — the step graph (`specify workflow info sdd`). The portable
  core; works with any Spec Kit integration.
- **`speckit-sdd-run` launcher** — drives the chain in-session with the single
  pre-implement gate. Shipped two ways:
  - `commands/speckit-sdd-run.md` — a **Claude Code slash command**. Copy it into
    `.claude/commands/` for a typeable `/speckit-sdd-run` (this is the working
    path on Claude — see note below).
  - `extensions/sdd/` — a Spec Kit extension that installs the same launcher as a
    *model-invocable* skill, for non-Claude integrations.

## Repository layout

```
.
├── workflows/sdd/workflow.yml          # the sdd workflow (step graph)
├── extensions/sdd/                      # launcher as a Spec Kit extension
│   ├── extension.yml
│   └── commands/speckit.sdd.run.md
├── commands/speckit-sdd-run.md          # launcher as a Claude Code slash command
├── bundle.yml                           # bundle manifest (pins the components)
├── scripts/validate-bundle.ps1          # repeatable consistency/readiness check
├── .specify/memory/constitution.md      # the bundle's governing principles
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Install

Clone this repository onto the machine, then, from the target Spec Kit project
(paths below assume the clone lives at `/path/to/sdd-cycle`):

```bash
# 1. the workflow (all integrations)
specify workflow add /path/to/sdd-cycle/workflows/sdd/workflow.yml

# 2a. Claude Code — copy the slash command so /speckit-sdd-run is typeable
cp /path/to/sdd-cycle/commands/speckit-sdd-run.md .claude/commands/

# 2b. other integrations — install the launcher as an extension instead
specify extension add /path/to/sdd-cycle/extensions/sdd --dev
```

Then run the launcher (Claude): `/speckit-sdd-run <what you want to build>`.
Invoked with no argument, it asks what to build before starting.

> **Why a slash command on Claude, not the extension?** `specify extension add`
> renders an extension's command as a SKILL.md that Claude Code does **not** mark
> `user-invocable`, so it can't be typed as `/speckit-sdd-run` (only
> model-invoked). The `.claude/commands/` file is the reliable, typeable launcher
> on Claude. The extension remains for integrations whose command format is
> directly invocable.

(For which distribution paths are and are not supported, see
[Distribution](#distribution) below.)

## Validate

Before releasing or merging a change to the manifests, docs, or constitution, run
the bundle consistency check:

```powershell
pwsh ./scripts/validate-bundle.ps1
```

It asserts that every bundle-pinned component version matches that component's own
manifest, that the declared `speckit_version` floors agree, that every file a
manifest references exists, and that the constitution is ratified (no placeholder
tokens). It exits non-zero with a specific message on any failure. This check is
required by the project [constitution](.specify/memory/constitution.md)
(Principle V, "Guardrail Before Release").

## Distribution

**Supported:**

- **Install from a clone** — the documented [Install](#install) path (`specify
  workflow add <path>`, copy the slash command, or `specify extension add
  <dir> --dev`).
- **Build a versioned artifact** — `specify bundle build` emits a `.zip` under
  `dist/` (git-ignored) pinned to the `bundle.yml` version. Use this to hand the
  bundle to another machine.

**Not supported (today):**

- `specify extension add <name> --from <url>` — expects a published extension
  **archive**, not a repo directory URL. This project publishes no such archive.
- `specify bundle install` — resolves components through a public catalog this
  project does not publish. `bundle.yml` exists to *build* an artifact and to
  document the pinned component set, not to install from a catalog.

## History

This bundle originated inside the
[`blaiseelmwood.com`](https://github.com/peterelmwood/blaiseelmwood.com) repository
(where it was dogfooded to drive that site's features) and was extracted into its
own repository so it can be reused across projects. The commit history for these
files is preserved from that origin.

## License

[MIT](./LICENSE) © peterelmwood
