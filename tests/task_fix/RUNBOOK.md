# RUNBOOK: tests/task_fix

## Full suite

```bash
python3 tests/task_fix/evals/run.py
```

Runs every id in `evals/evals.json` on a pinned sonnet worker, one at a time,
and prints a per-eval PASS/FAIL plus a tally. Exit code is 0 only when every
worker completed cleanly *and* its deterministic grade passed.

## One eval

```bash
python3 tests/task_fix/evals/run.py regroup_live_skip_archived
```

## Re-running past the verdict cache

A verdict is cached under `evals/.eval_cache/` keyed on the `task_fix` skill,
the base `task` skill, the `auto_*_task` agents, this harness directory, the
model, and the prompt. Edit the react protocol or any of those artefacts and
the cache invalidates on its own. To force a fresh run anyway:

```bash
python3 tests/task_fix/evals/run.py --force
```

```bash
python3 tests/task_fix/evals/run.py --no-cache
```

## Reading a failure

Each run writes `workspace/run-<ts>-<pid>/<id>/`:

- `response.txt`: the run's report. This is the graded surface for every
  disposition-line check; read it when a `the report carries …` check fails.
- `grading.txt`: every PASS/FAIL line plus the agent-attest notes.
- `sandbox/proj/tasks/`: the tree as the run left it.
- `stderr.txt`, `timing.json`: worker diagnostics.

A `worker did not complete` line means the grade cannot be trusted: the worker
timed out or crashed, and grade.sh saw partial state.

## Reading the two failure shapes that matter

A **regroup that dropped a link instead of gathering** shows up as a cleared
warn with `the gathered account sits in ## Context only` failing, because the
account is still narrated twice with one link. A **kept finding graded as
resolved** shows up as `both links to the reference page still stand` failing:
the run took the count as the measure, which is the reading the protocol reword
supersedes.

## Staging a sandbox by hand

```bash
bash tests/task_fix/evals/stage.sh kept_each_site_earns_link /tmp/tf-sandbox
```

Then drive the skill yourself with `/tmp/tf-sandbox/proj` as the working
directory, and grade it:

```bash
RESPONSE_FILE=/tmp/tf-sandbox/response.txt bash tests/task_fix/evals/grade.sh kept_each_site_earns_link /tmp/tf-sandbox/proj
```

Without `RESPONSE_FILE` the grader falls back to the runner's conventional
path, and the report checks fail loudly rather than passing vacuously.
