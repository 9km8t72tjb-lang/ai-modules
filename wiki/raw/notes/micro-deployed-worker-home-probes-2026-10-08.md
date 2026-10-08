---
ingested: 2026-10-08
sha256: bff9bb84d5619dcc7a5a838b8bc272014b46d91ed80ae475746b7d68c7edc457
---

# Micro-deployed worker home probes, 2026-10-08

This note records probes run on 2026-10-08 that asked which copy of a skill a print-mode worker loads when the prompt names the skill but gives no path. The record is a set of local stream captures outside the repository, and their content is excerpted below as the authoritative copy. No machine path, scratch path, or session id from the probes is given.

Every probe staged the `language_humanizer` eval's `write_path` notes under a fresh root in the system temporary directory, outside the home directory and outside any git repository. A deployed copy of every repository skill sat in the user's Cursor and Claude skill directories throughout. Cursor ran as the `agent` CLI 2026.10.01 in print mode with `--force`, `--sandbox disabled`, `--model auto`, and `--output-format stream-json`. Claude ran as `claude` 2.1.289 in print mode with `--permission-mode bypassPermissions`, `--model sonnet`, and `--output-format stream-json --verbose`.

## Facts

- **Project copy beside a deployed copy (Cursor).** With every repository skill copied into the workspace's `.cursor/skills/` and the request asking for the document with no skill named, the worker read the deployed user-level copies of `language_humanizer` and `format_markdown`, not the project copies.
- **Scratch config directory (Cursor).** With `CURSOR_CONFIG_DIR` naming an empty scratch directory, the worker authenticated, and it still read the deployed user-level skills from the home directory. The CLI bundle reads `CURSOR_CONFIG_DIR`, then `XDG_CONFIG_HOME`, for its configuration directory, and lists skill directories under `.cursor`, `.claude`, `.codex`, `.grok`, and `.agents` beside its built-in `skills-cursor`.
- **Scratch home (Cursor).** With `HOME` naming an empty scratch directory, the CLI refused to start and asked for `agent login` or `CURSOR_API_KEY`. With the scratch home's `Library` linked to the real one, it authenticated, and the scratch home gained its own `.cursor` state.
- **Micro-deployed scratch home (Cursor).** With every repository skill copied into the scratch home's `.cursor/skills/` and the prompt asking for `language_humanizer` by name, the worker read the scratch home's copy of that skill.
- **Scratch config directory (Claude).** With `CLAUDE_CONFIG_DIR` naming a scratch directory and `CLAUDE_SECURESTORAGE_CONFIG_DIR` set to the empty string, the worker authenticated. Its init event listed the skills copied into the project's `.claude/skills/`, the built-in skills, and organisation-managed skills, while the user's deployed agents were absent and only built-in agents appeared.
- **Micro-deployed config directory (Claude).** With every repository skill copied into the scratch config directory's `skills/` and the prompt asking for `language_humanizer` by name, the worker invoked the Skill tool for that skill, and the marker line added to the scratch copy appeared in the stream.

## Consequence

A project copy does not displace a deployed copy of the same skill on Cursor. A scratch home on Cursor and a scratch config directory on Claude each take the deployed copies out of view, so a skill deployed into that scratch location is the copy the worker loads, by name and without a path.
