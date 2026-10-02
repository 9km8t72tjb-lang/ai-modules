---
title: Claude output style selection
created: 2026-10-01
updated: 2026-10-02
checked: 2026-08-10
type: concept
tags: [claude, output-style, deployment, verification-gap]
confidence: high
---

# Claude output style selection

## Definition

Selecting a Claude output style means setting the `outputStyle` settings key to
the style's name. Which settings file a route writes decides the scope of the
choice. What a style is, where its file lives, and the two delivery modes a
selection serves are on [Claude output styles](claude-output-styles.md).

Each passage below names the date and the source it was checked against. The
oldest claim still standing was checked on 10 August 2026 against build 2.1.226.
Re-verify before relying on any of them.

## Current state of knowledge

### The key and its precedence

Selection is the `outputStyle` settings key, and project and local settings
outrank the user-level key that the global mode sets, on the three-file order
recorded under `### Configuration roots` on
[Anthropic Claude Code](../entities/anthropic-claude-code.md).

### A headless worker honours a project selection

A `claude -p` worker loads a style staged in its working directory's
`.claude/output-styles/` and named by `outputStyle` in that directory's
`.claude/settings.json`, and the project value outranks a user-level selection.
That was observed on 2 October 2026 against build 2.1.226 with a marker style
whose reply token showed whether it had loaded. The token appeared with the
sandbox as its own git root, with the sandbox nested inside an outer repository,
and under `--setting-sources project,local`, and it was missing from a control
sandbox. A malformed project settings file drops the selection without an error,
which [Anthropic Claude Code](../entities/anthropic-claude-code.md) records
beside the setting sources.

### Every interactive route writes local scope

Running `/config` and choosing Output style writes the pick to
`.claude/settings.local.json` at local project scope, so an operator who selects
a style that way has bound one project rather than the machine. The picker
offers no scope choice at all, which sets it apart from the permission-rules
editor in the same dialog, where a rule can be filed at user, project, or local
scope. Both facts were re-verified on 10 August 2026 against build 2.1.226, from
the picker's own write target and from observed behaviour where a project-local
value beat a user-level one.

Two newer routes write the same file. The `/output-style [name]` command returned
in v2.1.269 and also runs in headless and Agent SDK sessions. The VS Code
extension gained an Output styles menu in v2.1.257 that lists custom styles too.
The docs page read on 1 October 2026 states that the command and both menus save
the choice to `.claude/settings.local.json`.

### The deployment consequence

The consequence for deployment is that a machine-wide style has no interactive
route. No picker, menu, command, or CLI subcommand writes the user-level key, so
writing the user-level settings file is the only way to set it. A project holding
its own local `outputStyle` keeps overriding that value until the key is removed
there. The docs page read on 1 October 2026 gives the same instruction for a
default across projects. `claude config`, once a documented route, is no longer
a CLI subcommand at all, as
[Anthropic Claude Code](../entities/anthropic-claude-code.md) records.

### When a switch takes effect

Since v2.1.251, a switch through the command or a menu takes effect from the next
message. Before that release it waited for `/clear` or a new session. A created
or edited style file still needs a restart, because the terminal reads style
files when it starts. Both facts come from the docs page read on 1 October 2026.

### The command was retired and restored

The standalone `/output-style` command was retired and later restored. The
changelog records its deprecation in v2.1.73 in favour of `/config`, together
with fixing the style at session start for prompt caching. The 7 August pass
also recorded a removal in v2.1.91, but that release's changelog section carries
no such entry, so the removal version is unverified. Build 2.1.226 defines no
such command, which was confirmed on 10 August 2026 and again on 1 October 2026.
The changelog records `/output-style [name]` as added again in v2.1.269. Build
2.1.284 defines it as a local command that lists the styles or switches to one,
and it supports non-interactive sessions, as read on 1 October 2026. An
instruction naming the command therefore works on current builds and fails on
any build older than v2.1.269.

### The desktop route

`/config` is an interactive terminal dialog, so a desktop-application session
cannot reach the picker. The docs page read on 1 October 2026 now documents the
desktop route: set `outputStyle` in a settings file, because `/config` there
opens the application's Claude Code settings instead of a menu. That settles the
route the 7 August pass observed and an operator later reported.

## Open questions

Three questions stay open, and they are why this page carries the
`verification-gap` tag. The docs say the restored command works in Agent SDK
sessions, but they do not list it among the desktop routes, and nobody has tried
it in a desktop session. The desktop harness also names output style among the
Code tab preferences it can change, and what that preference writes was not
checked. Whether a hand edit of the settings key applies mid-session was not
checked either.

## Related concepts

- [Claude output styles](claude-output-styles.md), for what a style is, where its
  file lives, and the two delivery modes.
- [The deployment model](deployment-model.md), for the silent override a
  project-local key imposes on a deployed style.
- [Output style delivery design](output-style-delivery-design.md), for what the
  deploy writes on Claude and how it picks the active style.

## Derived from

- `code.claude.com/docs/en/output-styles`, read on 7 August 2026 and again as raw
  Markdown on 1 October 2026.
- The full Claude Code changelog, read on 1 October 2026.
- Claude Code build 2.1.226, checked on 10 August 2026 for the picker's write
  target and searched again on 1 October 2026 for the command definition.
- Claude Code build 2.1.284, searched on 1 October 2026 for the command
  definition.
- Claude Code build 2.1.226 on one machine, probed on 2 October 2026 with a
  marker style in throwaway sandboxes, for headless selection.
- The desktop application bundle installed on 7 August 2026.
