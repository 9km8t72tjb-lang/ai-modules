---
ingested: 2026-10-06
sha256: 8875da4c8400f813ff22167989c47602f144de96144e5c344ca93bfeab84dd97
---

# Cursor style-rule injection probes, 2026-10-06

This note records live print-mode probes of where Cursor injects an
`alwaysApply: true` rule file, run to settle the Cursor output-style deploy
path. The Cursor `agent` CLI build was `2026.10.01`. Every probe used a scratch
workspace with no project `AGENTS.md`, no `CLAUDE.md`, and no other project
rules unless the probe under test placed one. Each probe asked the worker to
quote a distinctive `STYLEPROBE-*` token from its instructions, or to answer
`NONE` when none was present. Probe files were removed after the run.

## Project rules

A `.mdc` file under the scratch project's `.cursor/rules/` with frontmatter
`alwaysApply: true` and token `STYLEPROBE-A7F3` was quoted on the first reply.
A second run with the same project file still quoted the token. Project-scoped
always-apply rules inject in print mode.

## Home-directory rules

The same shape of `.mdc` file under the user configuration tree's `rules/`
folder, with token `STYLEPROBE-B2C9` and no project rules present, produced
`NONE`. Home-directory rule files are not injected into print-mode Agent
context on this build.

## User-local plugin

A plugin was placed under the user configuration tree's `plugins/local/`
directory with a `.cursor-plugin/plugin.json` naming it and a `rules/` file
carrying `alwaysApply: true` and token `STYLEPROBE-C4D1`. The same plugin also
held a `skills/` entry whose description mentioned `STYLEPROBE-SKILL`.

With auto-discovery and again with an explicit `--plugin-dir` pointing at that
plugin:

- The skill was available (`SKILL_PRESENT=yes`).
- The rule token was absent (`RULE_TOKEN=NONE`).

User-local plugins therefore deliver skills into print-mode sessions on this
build, and do not inject their `alwaysApply` rule files into that same
context.

## Adherence slice

A short prose-style rule body was placed as a project always-apply `.mdc` and
exercised with three prompts (a short factual question, a short code
explanation, and a planning preference). Answers led with the point and stayed
compact. That is an adherence smoke check on the project path only, not a
global-path finding.

## What the probes do not settle

No IDE Agent chat after a window reload was run. These results are print-mode
CLI evidence. Documentation elsewhere still names machine-local user rule
files under the user `rules/` folder as storage that does not sync; that
storage claim is separate from injection into Agent context.
