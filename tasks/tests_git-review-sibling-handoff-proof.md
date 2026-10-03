---
description: Stage logging copies of git_checkout and git_commit in the git_review eval sandbox and grade evals 10, 12, and 48 on the sibling helper calls instead of attest lines.
scope: tests/git_review
created: 2026-10-02T10:23:20
updated: 2026-10-03T13:01:20
status: open
reported-by: Andreas Hoffmann
---

# Make git_review's sibling handoffs observable in its harness

## Goal

The `git_review` harness proves the two handoffs the parent task's acceptance names: a run asked to be put onto a remote-only branch switches through `git_checkout`, and a run asked to commit a fix commits through `git_commit`. Evals 10 and 12 grade the `git_checkout` helper call, and eval 48 grades the `git_commit` helper call, each from the sandbox's script log, so a run that hand-runs `git switch` or `git commit` fails.

## Context

`tests/git_review/evals/stage.sh` copies the skill under test into the eval target through `stage_skill_copy` and replaces each bundled script with a logging shim that appends to `script_calls.log` and then runs the real script. It shims only `git_review`'s own `scripts/`. The `WORKER_PROMPT` in `tests/git_review/evals/run.py` names only the `git_review` copy, so the worker reaches the siblings by whatever route its harness offers, and no shim sees the call.

The `10)` and `12)` cases in `tests/git_review/evals/grade.sh` leave the `git_checkout` handoff as an `agent-attest` line, and no recorded eval 10 or 12 response names `git_checkout`. The `48)` case checks the commit subject's `file name -> concrete change` form, but the fixture's own history already uses that form, so a hand-run commit that copies it passes too. The sibling helpers are `scripts/checkout_branch.sh` in `git_checkout`, and `scripts/prepare_commit_context.sh` and `scripts/commit_with_message.sh` in `git_commit`.

The cache key in `run.py`, built by `source_roots_for`, already hashes both sibling source directories, so the cache needs no change for the copies. The runner is vendor-aware; fresh proof runs use `--vendor cursor` per `TESTING.md`. A change to `WORKER_PROMPT` moves every eval's cache key, so the regression re-run after this change covers the whole suite once under that vendor.

## Approach

Extend `stage_skill_copy` in `stage.sh` so it stages `git_checkout` and `git_commit` beside the `git_review` copy under the eval target, shimming every bundled script in both the same way. Rewrite `WORKER_PROMPT` in `run.py` so it names the staged sibling `SKILL.md` paths as the copies to use whenever the skill hands work to a sibling. The skill itself names its siblings by name only, per the standing repo rule on deployment-agnostic cross-references, so the harness supplies the paths.

Replace the `git_checkout` attest lines in the `10)` and `12)` cases with `script_called "checkout_branch.sh"`, and replace the `git_commit` attest line in the `48)` case with `script_called "commit_with_message.sh"`. Rewrite the matching expectations in `evals.json`, the eval entries in `tests/git_review/evals/README.md`, and the staging notes in `tests/git_review/RUNBOOK.md` in place.

## Acceptance

- A staged eval target carries shimmed copies of `git_checkout` and `git_commit` beside the `git_review` copy, and running a shimmed `checkout_branch.sh --help` appends one line to `script_calls.log` and prints the real script's usage.
- The worker prompt `run.py` builds for any eval names both staged sibling `SKILL.md` paths.
- Staging eval 10 and grading it against an empty `script_calls.log` fails the new `checkout_branch.sh` check, and the same holds for eval 48 and `commit_with_message.sh`.
- Evals 10, 12, and 48 each pass on a fresh `python3 tests/git_review/evals/run.py --vendor cursor <id>` run, with the sibling helper call in that run's script log.
