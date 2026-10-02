---
description: "Isolate the language_humanizer eval worker and judge from the host's settings, deployed style and CLAUDE.md files through a shared tests/lib helper, then re-measure."
scope: tests
created: 2026-10-02T12:56:51
updated: 2026-10-02T16:31:00
status: ready
reported-by: Andreas Hoffmann
---

# Isolate the language_humanizer eval workers from the host via a shared tests/lib helper, then re-measure

## Goal

The `language_humanizer` behavioural harness measures the skill alone. Its worker and its judge run free of the host machine's user-level settings, its deployed output style, and every CLAUDE.md file outside the sandbox. The isolation lives in a shared helper under `tests/lib/`, the way the nested-worker auth wiring does, so that other runners can adopt it without re-deriving it. A fresh five-pass measurement of the three scenarios under isolation is recorded beside the earlier runs, which ran unisolated.

## Context

- **What the runner does today.** `run_pass` in `tests/language_humanizer/evals/run.py` stages each pass's sandbox at `pass_dir / "sandbox"` under the harness's `workspace/`, which sits inside the repository, and starts the worker from there with `claude -p --permission-mode bypassPermissions` plus `--model`. The worker prompt tells it to read the skill file at the `skill_path` that `evals/stage.sh` prints, which is inside the repository. `judge` in `evals/judge.py` starts its own `claude -p` call without a working directory of its own, so it runs wherever the runner was started. Neither call narrows the setting sources.
- **What reaches such a worker.** Probes of Claude Code build 2.1.226 on 2026-10-02 showed the following, recorded under `### Configuration roots` and `### Standing instruction files` on `wiki/entities/anthropic-claude-code.md` and under `### A worker inherits the host's instructions unless it is isolated` on `wiki/concepts/verification-surfaces.md`:
  - A default `claude -p` worker loads the user-level settings, including a deployed output style, and the user-level CLAUDE.md.
  - The CLAUDE.md search runs past the repository root and loads `CLAUDE.md` and `.claude/CLAUDE.md` from ancestor directories. A worker inside this repository therefore reads the repository's CLAUDE.md files and, through the home directory, the user-level one, even under `--setting-sources project,local`.
  - A worker in a sandbox outside the home directory and outside any repository, started with `--setting-sources project,local`, reads none of them.

  Those files and the deployed style carry writing rules of their own, so every recorded humanizer measurement so far ran under them, in the worker's rewrite and in the judge's verdict alike. That is a confound for a skill whose subject is prose.
- **Existing shared wiring.** `tests/lib/worker_auth.py` holds the nested-worker environment that every runner imports through `worker_env()`, documented in the `### Worker auth` section of `tests/CLAUDE.md`; it is the shared-wiring model for the isolation helper. The helper's standalone unit tests follow the pattern of `tests/lib/test_worker_io.py`.
- **The skill under test.** `evals/stage.sh` points `skill_path` at `plugins/ai_editorial/skills/language_humanizer/SKILL.md`. That file ships on the `init-ai-editorial-plugin` branch and is absent from `main`, so every Acceptance item that starts a worker, and the Approach skill-copy that feeds those items, runs on a checkout that carries it.
- **The other harness on this pattern.** [styles_natural-language-connected-prose.md](styles_natural-language-connected-prose.md) builds a new harness on the same isolation and reuses the helper this task adds, so the helper serves both: an isolated sandbox root, the worker arguments, and the create-root refusal that helper defines.

## Approach

1. **Add `tests/lib/worker_isolation.py`** beside `worker_auth.py`, as the single source of the isolation the runners import:
   - A function that creates a fresh sandbox root with `tempfile.mkdtemp()` under the system temporary directory, using a prefix the caller names, and raises an error for any root that resolves under the home directory or inside any git repository.
   - A function that returns the worker arguments `["--setting-sources", "project,local"]`, for every `claude -p` call a runner makes, judge calls included.
   - A module docstring that states what the isolation keeps out and points at the two wiki pages named in Context.
2. **Add `tests/lib/test_worker_isolation.py`**, a standalone script in the style of `test_worker_io.py`, covering the create-root refusal's refused cases and a fresh temporary root, accepted.
3. **Run each pass outside the repository.** In `run_pass`, stage the sandbox under an isolated root from the helper, copy the skill file under test into that sandbox, and point the worker prompt at the copy, so that the worker reads nothing inside the repository. Start the worker with cwd at the staged `sandbox_proj` (the `proj/` directory under that isolated root), carrying the helper's arguments; grade against that same project directory there; then copy the finished sandbox to `pass_dir / "sandbox"`, so that the `workspace/` layout the runbook describes and `regrade.py` keep working. Remove the temporary root afterwards.
4. **Isolate the judge.** In `judge`, start the `claude -p` call from an isolated root of its own with the helper's arguments, and remove that temporary root after the call.
5. **Document the isolation.** Add a `### Worker isolation` section to `tests/CLAUDE.md` beside `### Worker auth`, naming the helper and what it keeps out, and rewrite the passages of the harness `README.md` and `RUNBOOK.md` that describe where a pass runs, so that they say the live sandbox sits under the system temporary directory and is copied into `workspace/` afterwards.
6. **Re-measure.** On a checkout that carries the skill file, run the three scenarios under isolation over the harness's five-pass denominator, keeping the harness's measurement contract for a scenario that misses the bar. Write `results/isolation-comparison.md`, giving for each scenario and assertion the isolated rate beside the rate of the latest non-regrade `results/run-*` that reports that scenario, naming that baseline run's identifier and denominator.

**Out of scope:**

- Moving the other behavioural runners onto the helper, since this task changes the `language_humanizer` runner and judge only.
- Changing the skill, its fixtures or its grader rubrics.
- Deciding what becomes of the earlier, unisolated results, which the comparison hands to the user.

## Acceptance

- `python3 tests/lib/test_worker_isolation.py` passes, with the two refused roots and the accepted temporary root covered, and the helper's module docstring names what the isolation keeps out and the two wiki pages behind it.
- `run.py` and `judge.py` both import the helper, every `claude -p` command they build carries `--setting-sources project,local`, and neither starts a worker or a judge call from a directory the create-root refusal rejects.
- A one-pass plumbing run, `python3 tests/language_humanizer/evals/run.py write_path --passes 1`, leaves `git status` exactly as it was before the run, leaves no directory with any isolation prefix `run.py` or `judge.py` passes to the helper under the system temporary directory, and leaves a copied `pass_dir/sandbox` from which `regrade.py` re-grades the pass.
- The worker prompt points at a copy of the skill file inside the sandbox rather than at the path inside the repository.
- `tests/CLAUDE.md` carries the `### Worker isolation` section, and the harness `README.md` and `RUNBOOK.md` describe the isolated staging, with no passage left saying that a pass runs inside `workspace/`.
- `results/` holds the isolated five-pass run of all three scenarios, and `results/isolation-comparison.md` sets each scenario's per-assertion rates beside those of the latest non-regrade `results/run-*` that reports that scenario, naming that baseline run's identifier and denominator. Where a rate moved, the comparison names the assertions that moved and leaves the disposition of the earlier results to the user.
