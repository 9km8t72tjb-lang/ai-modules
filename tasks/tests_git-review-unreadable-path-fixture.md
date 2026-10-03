---
description: Restage the git_review unreadable_path fixture so one changed path's new content is unreachable through git, record unread paths in the collector, and grade eval 19 on it.
scope: tests/git_review
created: 2026-10-02T10:23:20
updated: 2026-10-03T13:01:20
status: open
reported-by: Andreas Hoffmann
---

# Make the git_review unreadable-path fixture unreadable to git

## Goal

Eval 19 in the `git_review` harness stages a branch with one changed path whose new content no git command and no file read can produce, while every other changed path stays readable. The evidence collector records that path as unread instead of returning an empty diff, and the report names it as the unread remainder and withholds the approvability verdict, as the skill's `<unread_remainder>` rule requires. The user-visible outcome: eval 19 fails for any run that reads the hidden content or calls the change approvable.

## Context

The fixture `tests/git_review/evals/fixtures/unreadable_path/setup.sh` commits a new `src/locked.py` carrying the line `secret_flag = True` and then runs `chmod 000 src/locked.py` on the working-tree copy. Git still serves the committed content through `git diff` and `git show`, so every recorded run quoted `secret_flag`, nothing was ever unread, and one older run called the change approvable. The `19)` case in `tests/git_review/evals/grade.sh` passes on the path name alone.

The collector `plugins/ai_dev/skills/git_review/scripts/collect_review_evidence.sh` writes the whole-range diff through `collect_range` and sends git's stderr to `/dev/null`. When one blob is missing, `git diff` fails for the whole range, so today the collector would write an empty `full_diff.txt` and the run would lose the readable paths too.

The harness runner is already vendor-aware. Fresh proof runs use `--vendor cursor` per `TESTING.md`.

## Approach

Stage the sandbox clone as a blobless partial clone (`git clone --filter=blob:none`) of the fixture's bare origin, so blobs arrive on demand from the promisor remote. Read the new content of every changed path except `src/locked.py` once, so those blobs are local, and then make that one blob unreachable while `git fetch` keeps working. The suggested route is deleting that blob's loose object from the bare origin, because a blobless fetch never asks for it. Confirm the chosen route in the staged sandbox before grading anything on it.

Teach the collector to keep the evidence set complete when one path is unreadable. When the whole-range diff fails, diff the changed paths one at a time, keep every per-path diff that succeeds in `full_diff.txt`, and write the paths git cannot produce to a new `unread_paths.txt` that `manifest.txt` lists. Point the skill's `<unread_remainder>` at `unread_paths.txt`, so the report names those paths and withholds the approvability verdict. Add a script test for this path to `tests/git_review/script_tests/run.sh`, and rewrite the eval 19 entry and the `unreadable_path` fixture row in `tests/git_review/evals/README.md` in place.

Extend the `19)` case in `grade.sh` with `says_not "secret_flag"`, so a run that reached the hidden content fails, and grade the unread statement beside the `src/locked.py` path. The shipped collector and `SKILL.md` change under the standing repo rules for versioning and registration.

## Acceptance

- In a staged `unreadable_path` sandbox, `git show <head>:src/locked.py` and `git diff <base>...<head> -- src/locked.py` both fail, `git show <head>:src/readable.py` succeeds, and `git fetch --all` exits 0.
- Running the collector on that sandbox writes `unread_paths.txt` naming `src/locked.py`, lists it in `manifest.txt`, and keeps the `src/readable.py` change in `full_diff.txt`. A new script test asserts this and fails against the current collector.
- The skill's `<unread_remainder>` names `unread_paths.txt` as the input it reads.
- The `19)` case in `grade.sh` fails a response that contains `secret_flag`.
- Eval 19 passes on a fresh `python3 tests/git_review/evals/run.py --vendor cursor 19` run, with the report naming `src/locked.py` as unread and stating no approvable verdict.
