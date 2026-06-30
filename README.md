# SDD Cycle — reusable Spec Kit components

Chains the spec-driven development cycle behind one launcher, with a single
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

## Install

Clone this repository (or copy the `sdd-cycle/` directory) onto the machine,
then, from the target Spec Kit project:

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

> **Why a clone, not a raw URL?** `specify extension add <name> --from <url>`
> expects a published extension **archive** (e.g.
> `specify extension add sdd --from https://…/sdd.zip`) — not a repository
> directory URL. This project does not publish such an archive, so install from
> a clone with `--dev` as shown above.
>
> Likewise, `specify bundle install` is **not** the install path: a Spec Kit
> bundle resolves its components through a catalog this project does not publish.
> `bundle.yml` exists only so `specify bundle build` can emit a versioned `.zip`
> and to document the pinned component set.
