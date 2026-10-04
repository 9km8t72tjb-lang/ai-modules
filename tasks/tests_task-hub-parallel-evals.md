---
description: Run tests/task evals at default 4 workers with per-eval host-tasks fail-safes that stay correct under overlap, using the shared Pattern A helper.
scope: tests/task/evals
created: 2026-10-04T22:11:10
updated: 2026-10-04T22:11:10
status: open
reported-by: Andreas Hoffmann
---

# Parallelize the task-hub behavioral evals without mixing host-tree fail-safes

## Goal

`python3 tests/task/evals/run.py` runs family-hub evals concurrently at default
4 workers. Each eval still fails if the host `tasks/` tree gains a file newer
than that eval's own marker, and concurrent sandboxed workers do not trip that
check for each other. Cursor is the measurement vendor. The user-visible
outcome: hub evals overlap instead of walking the family one id at a time to
keep the filesystem quiet.

## Context

`tests/task/evals/run.py` is sequential "so each worker's sandbox isolation
checks stay unambiguous and the host filesystem quiet." `evals/grade.sh` uses
`find "$REPO_ROOT/tasks" -type f -newer "$marker"` with the marker
`stage.sh` stamps at `$target/.eval_started_at`. `WORKSPACE` is
`tests/task/evals/workspace`. Ids already come from `evals.json` via
`_all_eval_ids()`.

Sandboxed workers that never write the host tree can overlap. The fail-safe must
stay per-eval and marker-scoped. An operator write during a live run still fails
every eval whose marker predates it, which `tests/CLAUDE.md` already documents
under `### Leave the repo's own tasks/ and wiki/ trees alone`.

This task consumes [the shared Pattern A eval runner](tests_shared-pattern-a-eval-runner.md).
Sibling harnesses with the same fail-safe are
[task_create](tests_task-create-parallel-evals.md) and
[task_fix](tests_task-fix-parallel-evals.md).

## Approach

Rewrite `evals/run.py` onto the shared helper: `--workers` 4, workspace
`tests/task/workspace`, per-job `TMPDIR`, serialized host-status hook if the
helper exposes one. Keep `grade.sh`'s host `tasks/` `find -newer` check; stamp
the marker immediately before the worker starts (or keep staging-time stamp if
a plumbing run shows no cross-talk). Rewrite the sequential comment and the
harness RUNBOOK.

Prove with a hermetic case that two overlapping jobs whose sandboxes stay
inside their targets leave host `tasks/` untouched, and that a deliberate newer
file under host `tasks/` fails the eval whose marker predates it.

**Out of scope:** The `script_tests/` and `contract_run.sh` surfaces. Deep
`task_auto_check` repair loops, which
[the auto_check parallel task](tests_task-auto-check-parallel-evals.md) owns.
Live-testing unshipped editorial plugin harnesses.

## Acceptance

- `run.py --help` shows `--workers` defaulting to 4.
- `python3 tests/task/evals/run.py --vendor cursor` at the default prints a
  graded summary over every id from `evals.json`.
- A `--workers 4 --force` run of at least two uncached evals overlaps in
  `timing.json` and leaves `git status --porcelain` of host `tasks/` unchanged,
  recorded under `tests/task/results/`.
- `grade.sh` still fails an eval when a host `tasks/` file is newer than that
  eval's marker.
