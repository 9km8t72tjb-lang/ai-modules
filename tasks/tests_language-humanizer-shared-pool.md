---
description: Point language_humanizer's already-parallel pool at the shared eval-runner helper after isolation lands, without changing the five-pass measurement.
scope: tests/language_humanizer/evals
created: 2026-10-04T22:11:10
updated: 2026-10-04T22:11:10
status: open
reported-by: Andreas Hoffmann
---

# Deduplicate the language_humanizer pool onto the shared eval runner

## Goal

`tests/language_humanizer/evals/run.py` keeps its fixed-denominator concurrent
passes at default 4 workers and drives them through the shared helper instead
of a private `ThreadPoolExecutor`. Isolation, vendor, and judge behavior stay
as the isolation task left them. The user-visible outcome: this harness remains
the Pattern A parallel reference without a second copy of the pool.

## Context

This runner already parallelizes (`vendor.DEFAULT_PARALLEL_WORKERS`) and
deliberately skips the verdict cache because repeated draws are the
measurement. [The isolation task](tests_language-humanizer-worker-isolation.md)
rewrites where each pass and the judge run. [The shared Pattern A eval
runner](tests_shared-pattern-a-eval-runner.md) is the pool this task switches
onto after those land.

The `ai_editorial` plugin and this skill are not yet the shipped-plugin
testing scope; refine the runner generally here. A full five-pass live
re-measure waits on that isolation checkout when the skill is present.

## Approach

After the isolation rewrite, replace the local executor with the shared pool
helper. Keep `--passes`, `--workers` default 4, per-pass sandbox ownership, and
the judge call. Do not add `eval_cache`. Rewrite the module docstring so the
pool is the shared helper rather than a private executor.

**Out of scope:** Changing grader rubrics, the five-pass contract, or plugin
shipping. A five-pass live cursor re-measure, which the isolation task owns.

## Acceptance

- `evals/run.py` imports the shared helper and contains no
  `ThreadPoolExecutor` construction of its own.
- `run.py --help` still defaults `--workers` to 4 and `--passes` to 5.
- `python3 tests/lib/test_eval_runner.py` still passes after this import.
- A `--passes 1 --workers 1 --vendor cursor` plumbing run of one scenario
  still writes `verdict.json` under the run dir when the skill file is on the
  checkout; when the skill is absent, the RUNBOOK records that the plumbing
  step waits on the isolation checkout requirement rather than failing this
  task's code change.
