---
description: Log the push in the git_review push_approval fixture and keep the run's report draft in the sandbox, so eval 41 grades warning-before-push and post-push re-reads deterministically.
scope: tests/git_review
created: 2026-10-02T10:23:20
updated: 2026-10-02T10:23:20
status: open
reported-by: Andreas Hoffmann
---

# Grade the git_review push-warning order from logs

## Goal

Eval 41 in the `git_review` harness proves the order the parent task's push-approval acceptance item names: the warning about the at-risk approval exists before the push runs, and the checks and the merge state are read after it. The grader reads both facts from artifacts the run leaves behind, a push line in `gh_calls.log` and the report draft's modification time, so neither one stays an `agent-attest` line.

## Context

The fixture `tests/git_review/evals/fixtures/push_approval/setup.sh` stages an approved pull request, a ruleset with `dismiss_stale_reviews_on_push`, and one unpushed commit. The stub `gh` logs every forge call to `gh_calls.log`, but the push itself travels to the fixture's bare origin through an `insteadOf` rewrite and leaves no line in any log. The `41)` case in `tests/git_review/evals/grade.sh` counts check reads and leaves the warning order as an attest line.

The skill's `<draft_the_report_to_a_file>` writes `report.md` into the collector's evidence directory before any side-effecting stage, a push included. The collector creates that directory with `mktemp` under `${TMPDIR:-/tmp}`, outside the eval target, so the grader cannot find it. `tests/git_review/evals/run.py` folds every line of a fixture's `gh_env` file into the worker environment. One audited run on 2026-10-01 shows the signal is there to read: its `report.md`, carrying the warning, was written three seconds before the origin ref moved.

## Approach

Install a `post-receive` hook in the fixture's bare origin that appends one line per updated ref to `gh_calls.log`, carrying the ref, the old and new SHAs, and an epoch timestamp, so the log orders the push among the forge calls. Have the fixture add a `TMPDIR` line to its `gh_env` that points into the eval target, so the evidence directory and `report.md` land inside the sandbox for this eval alone.

Extend the `41)` case in `grade.sh` with three checks. The log carries the push line. At least one checks or merge-state read follows the push line in the log. A `report.md` under the eval target contains the dismissal warning, and its modification time precedes the push line's timestamp. Read modification times through `python3`, because `stat` flags differ between macOS and Linux. Rewrite the eval 41 expectations in `evals.json`, its entry in `tests/git_review/evals/README.md`, and the `push_approval` fixture row in place to match.

## Acceptance

- A push to a staged `push_approval` origin appends one line naming `refs/heads/feature/export` to `gh_calls.log`, after the forge calls made before it.
- A collector run inside an eval 41 worker environment writes its evidence directory under the eval target.
- Grading a staged sandbox whose log has no checks read after the push line fails the re-read check, and grading one whose `report.md` is newer than the push line fails the warning-order check.
- Eval 41 passes on a fresh run with both new checks in place of the attest line.
