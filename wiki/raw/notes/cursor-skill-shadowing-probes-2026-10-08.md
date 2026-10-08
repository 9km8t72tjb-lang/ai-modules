---
ingested: 2026-10-08
sha256: 0f165e946176a045a72974cf93e2a030b708d35c5ba918c6bcc1379a84c0b7a3
---

# Cursor skill-shadowing probes, 2026-10-08

This note records diagnostic probes run on 2026-10-08 while isolating the `language_humanizer` eval worker. The probe record is a set of local stream captures outside the repository, and their content is excerpted below as the authoritative copy. No machine path, scratch path, or session id from the probes is given.

Every probe staged one eval fixture (`write_path` or `fidelity_padded`) under a fresh root in the system temporary directory, outside the home directory and outside any git repository, and gave the worker the eval's standard prompt, which names the staged `SKILL.md` path to read first. A deployed user-level copy of the same skill, byte-identical to the staged one, sat in the user's Cursor skills directory throughout. The Cursor probes ran the `agent` CLI 2026.10.01 in print mode with `--force`, `--sandbox disabled`, `--model auto`, and `--output-format stream-json`, and the reads below come from the `readToolCall` arguments in that stream. The Claude probe ran `claude` 2.1.289 in print mode with `--permission-mode bypassPermissions`, `--model sonnet`, `--setting-sources project,local`, and `--output-format stream-json --verbose`.

## Facts

- **Path-read copy outside the workspace (Cursor, one run).** The copy sat at `<root>/artefacts/.cursor/skills/<name>/SKILL.md`, and `--workspace` named the project directory beneath the root. The worker read the deployed user-level `SKILL.md` of the same name, three times, and never opened the staged copy.
- **Project skill of the workspace (Cursor, two runs).** The copy sat at `<root>/.cursor/skills/<name>/SKILL.md`, with `--workspace <root>` and the working directory at the project directory beneath it. In both runs the worker read the staged copy and no other `SKILL.md`.
- **Project skill under Claude Code (one run).** The copy sat at `<root>/.claude/skills/<name>/SKILL.md`, with the working directory at the project directory beneath it. The init event listed a skill of that name, and the worker read the staged copy as the prompt instructed.

## Consequence

A Cursor eval that path-reads a staged skill copy from outside its workspace can silently measure the deployed skill instead of the one under test. The swap stays invisible while the two copies match and gives a wrong result as soon as the copy under test changes. Staging the copy as a project skill of the workspace avoided the swap in every traced run.
