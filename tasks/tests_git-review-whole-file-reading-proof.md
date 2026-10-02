---
description: Restage the git_review deep_file_defect fixture as a whole-file diff with an unannounced tail defect, so eval 18 passes only for a run that reads the entire changed file.
scope: tests/git_review
created: 2026-10-02T10:23:20
updated: 2026-10-02T10:23:20
status: open
reported-by: Andreas Hoffmann
---

# Make the git_review long-file eval prove a whole-file read

## Goal

Eval 18 in the `git_review` harness passes only for a run that reads the whole changed file, which is what the parent task's long-file acceptance item claims it proves. The fixture's diff spans a file several thousand lines long, the only defect sits in the last hunk, and nothing in the file announces it. The run then takes the large-diff branch of the skill's `<scale_the_reading>` rule, "read the whole file, sample nothing, and trust no comment or docstring", and a run that samples the diff misses the defect.

## Context

The fixture `tests/git_review/evals/fixtures/deep_file_defect/setup.sh` writes the same helper block on the base and the branch through `plant_long_file` in `tests/git_review/evals/fixtures/_common.sh`, then appends a `summarize()` function whose body carries `# Defect: an empty list divides by zero here rather than returning 0.`. The resulting diff is about ten lines, so finding the defect proves the diff was read, not the file, and the comment names the defect outright. The `18)` case in `tests/git_review/evals/grade.sh` checks for `summarize` and a zero or empty mention.

`tests/git_review/RUNBOOK.md` already notes under its timeouts heading that this fixture is long by design and that the runner's default per-eval timeout is 600 seconds.

## Approach

Rewrite the branch side of the fixture so every helper changes, for example by renaming each `helper_N` or changing each body's arithmetic. The diff then spans the whole file, and the skill's large-diff branch applies. Keep the base file several thousand lines long. Put the only defect in the final hunk, for example a `summarize()` that divides by `len(values)` without an empty-input guard, and give it no comment or docstring that names the defect. Keep every other changed helper correct, so the defect is the one finding a whole read surfaces.

Size the file so a fresh run finishes well inside the default timeout. When a run comes close, lower the helper count while keeping the file several thousand lines long. Record the measured duration in the RUNBOOK timeout note, rewriting that note in place, and rewrite the eval 18 entry and the `deep_file_defect` fixture row in `tests/git_review/evals/README.md` to describe the whole-file diff.

## Acceptance

- In a staged `deep_file_defect` sandbox, the three-dot diff stat for `src/helpers.py` shows several thousand changed lines, and the defect sits in the last hunk.
- A case-insensitive search of the staged branch's `src/helpers.py` for `defect`, `bug`, and `divides by zero` returns no match.
- Eval 18 passes on a fresh run, and that run's `timing.json` duration stays under the runner's default timeout.
- The RUNBOOK timeout note states the measured duration for the rewritten fixture in place of the prior 4800-line description.
