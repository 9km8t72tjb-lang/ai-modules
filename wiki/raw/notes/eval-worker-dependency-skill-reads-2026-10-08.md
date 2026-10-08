---
ingested: 2026-10-08
sha256: e3834365910f5c5b8e0dc48622f12078b0cf2c54b7b21e37c252fb4ea99b815b
---

# Eval-worker dependency skill reads, 2026-10-08

This note records traced eval runs from 2026-10-08 that checked which skill files a behavioural eval worker reads beyond the copy its harness stages. The record is a set of local stream captures outside the repository, and their content is excerpted below as the authoritative copy. No machine path, scratch path, or session id from the runs is given.

Each run was an unmodified harness runner of this repository, started with `--no-cache` and a tracing stand-in for the worker binary (`--worker-bin`). The stand-in ran the real CLI with streaming output in place of text, recorded every read, glob, and shell path, and handed the runner the final result text. Each harness staged only the skill under test, beside its sandbox and outside the Cursor workspace. A deployed copy of every repository skill sat in the user's Cursor and Claude skill directories. Cursor ran as the `agent` CLI 2026.10.01 with `--model auto`, and Claude as `claude` 2.1.289 with `--model sonnet`.

## Facts

- **`task_create`, eval `reconcile-recorded`, Cursor.** The worker read the staged `task_create` copy, globbed for the base `task` skill, read the deployed user-level `task/SKILL.md` twice, and ran that deployed skill's bundled scripts.
- **`task_create`, eval `reconcile-recorded`, Claude.** The init event listed every deployed user-level skill. The worker read the staged `task_create` copy, tried a `task/SKILL.md` beside it, which the harness had not staged, and then read the deployed user-level `task/SKILL.md`.
- **`skill_doctor`, eval `scope_hub_family`, Cursor.** The worker read the staged `skill_doctor` copy and the fixture's own skill files, then listed the user's skill directories and read the deployed `ai_instruction_formatting` and `ai_instruction_writing` skills.
- **`guardrail_audit`, eval `presence_gate`, Cursor.** The worker read the staged `guardrail_audit` copy, then read the `guardrail` hub skill and one of its references from the repository checkout, which its sandbox inside the repository could reach.
- **Primary-skill swap, Cursor, two further runs.** Repeating the `language_humanizer` probe of the same day, with the copy staged outside the workspace, one run read only the deployed copy and the other read both the deployed and the staged copy. Across that probe's three runs, the deployed copy was read every time and the staged copy in one run only.

## Consequence

A worker reaches the version of a dependency skill that happens to be deployed, or that happens to sit in the checkout, unless the harness stages that dependency too. An edit to such a dependency is therefore not what the eval measures.
