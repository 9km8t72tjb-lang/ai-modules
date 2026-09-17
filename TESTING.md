# Testing

The verification methodology for this repository. It covers the regression
harnesses under `tests/` and the repo-wide linters, and it says what counts as
evidence that a shipped component works.

## Test Design Principles

- **Assert the behaviour, not its wording.** A check names the property that
  must hold and passes on every phrasing and placement that satisfies it.
  Prose is the most variable surface an agent produces, so a grader that pins
  one sentence fails correct work and reads as a regression.
- **Prefer a filesystem fact over a claim.** Grade what a run left behind, such
  as a file's bytes, a roster line, or a written brief, before grading what the
  run said about itself. Reach for a response check only where no artifact
  carries the property.
- **Read prose with wraps collapsed and negations dropped.** A hard wrap
  falling mid-phrase hides text that is present, and a run that names a move in
  order to say it did not take that move must not score as having taken it.
- **State the fail branch.** A check proves the failure case fails, not only
  that the hoped-for direction passes. A fixture that cannot fail measures
  nothing.
- **Stage a sandbox per scenario.** Every harness operates on a fresh temporary
  tree, never on the working checkout. A harness that runs a component against
  a real filesystem carries an explicit escape guard, such as a canary tree
  outside the sandbox and a `git status` of the host checkout, so an escape
  fails the scenario that caused it rather than passing unnoticed.

## Test Organization

One subdirectory per skill under test, at `tests/<skill_name>/`. The layout,
the two patterns in use, and the per-harness inventory live in
[tests/README.md](tests/README.md); the operator guidance for running them
lives in [tests/CLAUDE.md](tests/CLAUDE.md). Keep both current when a harness
is added or changed.

The authored harness is committed. Everything a run regenerates stays local
through `tests/.gitignore`, and the Makefile's `EXCLUDE` prunes the same
subtrees so lint scope matches git scope. The two lists change together.

## Stack and Runner

Make plus POSIX shell plus Markdown, with `jq`, `git`, and Python 3 as standing
dependencies, matching the charter's toolchain invariant. Bundled-script tests
are plain shell. Behavioural evals spawn a `claude -p` worker per scenario,
pinned to one cheap, stable model so results do not drift with the host
session; only the grading level runs on the inherited model.

## Coverage Expectations

A change to a shipped component lands with the tight scenarios that prove its
own new behaviour, plus the existing suite re-run to confirm no regression.
Unbounded harness growth beyond the change, such as backfilling coverage of
pre-existing untested behaviour or restructuring a harness, belongs in its own
session. The boundary is scope, not timing.

Where a task's acceptance names an eval, that eval is part of the change rather
than something to defer.

## Running Tests

```bash
make lint                                   # markdown, JSON, shell, repo-wide
bash tests/<skill>/run_all.sh               # that skill's deterministic surface
bash tests/<skill>/script_tests/run.sh      # the same, where no run_all.sh exists
python3 tests/<skill>/evals/run.py          # behavioural evals, spawns workers
python3 tests/<skill>/evals/run.py <id>     # one eval
python3 tests/<skill>/evals/run.py --force  # ignore the recorded verdicts
```

Trigger evals answer a different question, whether a skill's `description:`
loads it on a realistic message, and run through
`python3 tests/trigger_evals/run.py --eval-set <set> --skill <name> --baseline <prior-run>`.

## Re-run Economy

Running a check produces evidence about the state of what it inspects, so it
runs once per that state. Three runs are always sound: the first run in a
session, a run after the inspected state changed, and a standing gate at its
standing moment, such as `make lint` before a commit.

Beyond those, **re-running a check whose inputs did not change is waste, not
rigour.** It returns what the recorded run already returned, and on a sampling
surface it also resamples noise. Spend a run on what is genuinely unknown.

Judge "changed" by whether the change can reach the behaviour under test, not
by whether some byte moved in a watched directory. A recorded verdict stays
evidence when the edit since it was recorded cannot affect that scenario: a
clause added to one section of a skill does not invalidate an eval exercising a
different section, and an edit to one harness's grader does not invalidate
another harness. When the reach is genuinely unclear, re-run; when it is
clearly out of reach, keep the recorded verdict and say which run it came from.

The behavioural runners implement this: `tests/lib/eval_cache.py` records each
graded verdict under a content key and replays it instead of re-spawning a
worker. A cache hit means byte-identical inputs to a run already graded, so it
can never serve a stale pass. Re-grading a captured run against an updated
grader costs nothing and is the right move when the grader changed and the
behaviour did not.

Two things this rule never excuses: skipping a standing gate at its moment, and
skipping a check whose inputs did change. Name the relied-on run whenever a
run is skipped.

An acceptance criterion that mandates a re-run buying no new information is a
defect in the criterion. Rewrite it to name the evidence that would actually
inform the decision, and record why.

## Test Integrity

Code rises to the tests, never the reverse. A failing check is not weakened,
skipped, or removed to get a suite green: fix the component or the fixture
first, and change the check only when the behaviour it pinned is genuinely
superseded.

One distinction matters here, because both look like editing a test. Broadening
a check that pinned one phrasing of a property the component still satisfies is
a grader fix, and it is correct: the check was asserting surface form rather
than substance. Weakening a check so a component that no longer holds the
property passes is the failure this rule forbids. Say which of the two a change
is, and name the evidence, whenever an existing check is edited.
