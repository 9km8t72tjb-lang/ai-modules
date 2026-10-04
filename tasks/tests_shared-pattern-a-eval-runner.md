---
description: Extract one shared Pattern A eval-runner helper with default 4 workers, per-job isolation hooks, and the common vendor/cache/timeout loop so every sequential harness can stop copying run.py.
scope: tests/lib
created: 2026-10-04T22:11:10
updated: 2026-10-04T22:11:10
status: open
reported-by: Andreas Hoffmann
---

# Extract a shared Pattern A eval runner with default four workers

## Goal

`tests/lib/` ships one Pattern A eval-runner helper that every isolated-sandbox
behavioral harness imports. The helper runs evals through a thread pool whose
`--workers` default is `vendor.DEFAULT_PARALLEL_WORKERS` (4), stages each job
with its own sandbox and its own `TMPDIR`, records cache hits the way
`tests/lib/eval_cache.py` already does, and decodes worker output through
`tests/lib/worker_io.py`. Cursor and Claude differ only in `tests/lib/vendor.py`.
The user-visible outcome: adding parallelism or a vendor flag happens in one
module, and a copied `run.py` loop is no longer the way a harness grows.

## Context

Two runners already parallelize with that default: `tests/wiki/layer2/run.py`
(scenarios concurrent, passes of one scenario sequential) and
`tests/language_humanizer/evals/run.py` (one staged sandbox per pass). Every
other Pattern A `evals/run.py` still walks evals in a dict comprehension or a
`for` loop and comments that this is on purpose.

The copies have drifted. Workspace roots split between `tests/<skill>/workspace`
and `tests/<skill>/evals/workspace`. Default id lists are frozen in some
runners (`git_commit`, `guardrail_audit`, `task_auto_check`) and derived from
`evals.json` in others (`skill_doctor`, `task_fix`). `stage_named_agents` is
copied in the wiki layer-2 runner and in `task_auto_check` even though
`vendor.stage_skill_tree` already copies agent files. `tests/lib/worker_auth.py`
is a Claude-only wrapper around `vendor.worker_env` / `vendor.preflight_auth`.
Operator policy lives in `tests/CLAUDE.md` under `### Parallel workers` and in
the shorter `### Parallel workers` block in `tests/AGENTS.md`; both still list
the Pattern A runners as sequential.

Live siblings consume this helper rather than inventing a second pool:

- [git_commit parallel evals](tests_git-commit-parallel-evals.md)
- [git_review parallel evals](tests_git-review-parallel-evals.md)
- [task hub parallel evals](tests_task-hub-parallel-evals.md)
- [task_create parallel evals](tests_task-create-parallel-evals.md)
- [task_fix parallel evals](tests_task-fix-parallel-evals.md)
- [task_auto_check parallel evals](tests_task-auto-check-parallel-evals.md)
- [agent_spinner parallel evals](tests_agent-spinner-parallel-evals.md)
- [guardrail_audit parallel evals](tests_guardrail-audit-parallel-evals.md)
- [skill_doctor parallel evals](tests_skill-doctor-parallel-evals.md)
- [wiki layer-2 runner dedup](tests_wiki-layer2-runner-dedup.md)
- [language_humanizer shared pool](tests_language-humanizer-shared-pool.md)
- [git checkout and refresh runners](tests_git-eval-runner-parity.md)

Host-instruction isolation for the language_humanizer worker and judge stays
with [the isolation task](tests_language-humanizer-worker-isolation.md). Cache
key narrowing stays with [the granularity task](tests_eval-cache-key-granularity.md).
Trigger-eval `--workers` already follows `DEFAULT_PARALLEL_WORKERS` in
[the Cursor vendor task](tests_trigger-evals-cursor-vendor.md).

## Approach

Add `tests/lib/eval_runner.py` (name may match the module that lands) beside
`vendor.py`. It exposes:

- A `--workers` argparse helper whose default is `vendor.DEFAULT_PARALLEL_WORKERS`.
- A job runner that takes callables, runs them in a `ThreadPoolExecutor` when
  workers is greater than 1, and preserves completion order in the printed
  summary.
- A per-job environment builder that sets `TMPDIR` (and `TEMP` / `TMP` when a
  worker honors those) to a fresh directory unique to that job, then removes it
  after the job returns.
- Optional before/after hooks for a host-checkout escape guard, serialized so
  two finishing jobs cannot mis-attribute `git status` noise.
- Helpers every copy currently inlines: load eval ids from `evals.json` in file
  order, resolve `workspace/` to `tests/<skill>/workspace`, write
  `response.txt` / `stderr.txt` / `timing.json` with both `worker_rc` and
  `claude_rc`, skip/record through `eval_cache`.

Keep `vendor.stage_skill_tree(..., agent_files=)` as the only agent-staging
path; delete the need for a third `stage_named_agents`. Leave
`worker_auth.py` as the thin Claude wrapper it is, or fold its tests onto
`test_vendor.py` if nothing imports it.

Rewrite `### Parallel workers` in `tests/CLAUDE.md` and the matching block in
`tests/AGENTS.md` in place: isolated-sandbox evals default to 4 concurrent jobs;
`--workers 1` serializes; a harness keeps a sequential subset only when jobs
share a resource the helper cannot isolate (today: the `task_auto_check`
repair-class nested loops). Raise the same rule in `tests/README.md` under
`## Vendor switch` so the three operator docs agree. Rewrite the comment above
`DEFAULT_PARALLEL_WORKERS` in `tests/lib/vendor.py` to match.

Prove the helper with `tests/lib/test_eval_runner.py` in the style of
`tests/lib/test_vendor.py`: default workers is 4, two concurrent dummy jobs get
distinct `TMPDIR` values and cannot see each other's files, `--workers 1` runs
serially, and a hook pair around two overlapping jobs still attributes a
deliberate host-tree touch to one job.

**Out of scope:**

- Switching any existing `evals/run.py` onto the helper; each sibling named in
  Context owns that conversion.
- Authoring or live-running harnesses for an unshipped editorial plugin skill.
- Changing what any eval asserts.

## Acceptance

- `tests/lib/eval_runner.py` exists and `python3 tests/lib/test_eval_runner.py`
  passes, covering default workers 4, per-job `TMPDIR` isolation, serial
  `--workers 1`, and serialized host-status hooks.
- `vendor.DEFAULT_PARALLEL_WORKERS` remains 4, and the comment above it states
  the isolated-sandbox default rather than listing Pattern A runners as
  sequential.
- `tests/CLAUDE.md` and `tests/AGENTS.md` state that same default in lockstep
  under `### Parallel workers`, and the Pattern-A-stay-sequential list is gone
  rather than left beside the new rule. `tests/README.md` `## Vendor switch`
  agrees.
- Grepping `tests/` for a second `stage_named_agents` definition is a follow-up
  the wiki and `task_auto_check` siblings close; this task's helper does not
  add a third copy.
