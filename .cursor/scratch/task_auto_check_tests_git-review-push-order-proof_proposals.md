# Union of auto_reviewer_task proposals (round 1)

Frozen title: Grade the git_review push-warning order from logs
Frozen goal: Eval 41 in the `git_review` harness proves the order the parent task's push-approval acceptance item names: the warning about the at-risk approval exists before the push runs, and the checks and the merge state are read after it. The grader reads both facts from artifacts the run leaves behind, a push line in `gh_calls.log` and the report draft's modification time, so neither one stays an `agent-attest` line.

## Gate issues
1. Same-second mtime vs integer epoch
2. Post-push contract contradicts itself
3. Unpaired: merge-state after push
4. Unpaired: evals.json rewrite
5. Unpaired: README eval 41 rewrite
6. Unpaired: fixture-row rewrite
7. “Both new checks” vs three checks

## Proposal 1 — Self-sufficiency / issue 1
proposal_kind: edit
Rewrite Approach hook stamp to python3 time.time() subsecond epoch; rewrite warning-order compare as st_mtime strictly less than push epoch; rewrite Acceptance fail clause to fail when st_mtime >= push epoch, pass even when both share the same integer second.

## Proposal 2 — Decide-or-label / issue 1
proposal_kind: edit
Same Python-float path. Do not adopt integer-second truncation or a same-second tie rule. Evidence: Goal requires draft before push and skill-following eval 41 to pass; integer truncation cannot keep both a same-second pass and a same-second inverted fail. CHARTER/TESTING/harness_portability prefer Python 3 for portable filesystem work.

## Proposal 3 — Acceptance-contract / issue 1
proposal_kind: edit
Python float-epoch on push line; mtime < push_epoch; also add that the first Acceptance item's line carries a Python float-epoch timestamp.

## Proposal 4 — Rewrite-in-place / issue 1
proposal_kind: edit
Subsecond Unix timestamp from same family as os.path.getmtime; getmtime strictly less than push stamp.

## Proposal 5 — Minimum-change / issue 1
proposal_kind: edit
Integer Unix epoch plus fail-on-equal truncation of st_mtime. Conflicts with proposals 1–4.

## Proposal 6 — Decide-or-label / issue 2
proposal_kind: edit
Approach: "Both a checks read and a merge-state read follow the push line in the log."
Acceptance third bullet: fail if log lacks a checks read after the push line, or lacks a merge-state read after the push line.

## Proposal 7 — State-once / issue 2
proposal_kind: edit
Approach: "After that line, the log proves the Goal's post-push re-reads."
Acceptance: fail if log is missing either of the Goal's post-push re-reads.

## Proposal 8 — Rewrite-in-place / issue 2
proposal_kind: edit
Approach: "At least one checks read and at least one merge-state read follow the push line in the log."
Acceptance: fail on no checks read after push, or no merge-state read after push.

## Proposal 9 — Acceptance-contract / issue 2
proposal_kind: edit
Acceptance-only: fail on no checks OR no merge-state after push. Leaves Approach OR standing.

## Proposal 10 — Acceptance-contract / issue 3
proposal_kind: edit
Third bullet: fail no-checks, fail no-merge-state, fail newer report.md (three clauses).

## Proposal 11 — State-once / issue 3
proposal_kind: edit
Same Acceptance OR fail as proposal 8; Approach "A checks read and a merge-state read each follow the push line in the log."

## Proposal 12 — Acceptance-contract / issue 4
proposal_kind: edit
Add Acceptance item: eval 41 expectations in tests/git_review/evals/evals.json name push-line, post-push re-read, and report.md mtime proofs; no warning-order agent-attest; prior attest expectation gone.

## Proposal 13 — Rewrite-in-place / issue 4
proposal_kind: edit
Rewrite last Acceptance bullet to also inspect evals.json expectations in place of prior warning-order expectation AND keep the live run pass. Overlaps issue 7 last bullet.

## Proposal 14 — Acceptance-contract / issue 5
proposal_kind: edit
Add bullet: ### 41: `push_approval` entry in tests/git_review/evals/README.md states grading reads the push from gh_calls.log and warning order from report.md mtime.

## Proposal 15 — Rewrite-in-place / issue 5
proposal_kind: edit
Add bullet with supersede: transcript-level order description that stands there today is gone.

## Proposal 16 — Acceptance-contract / issue 6
proposal_kind: edit
Add bullet: push_approval fixture row names origin post-receive log line and eval-target TMPDIR; no longer states only prior approval-plus-ruleset description.

## Proposal 17 — Rewrite-in-place / issue 6
proposal_kind: edit
Similar plus exactly one push_approval row remains.

## Proposal 18 — Decide-or-label / issue 7
proposal_kind: edit
Last bullet names three checks, still using Approach's current OR wording for post-push read.

## Proposal 19 — State-once / issue 7
proposal_kind: edit
Last bullet: "with the three grade.sh checks named in Approach in place of the attest line."

## Proposal 20 — Acceptance-contract / issue 7
proposal_kind: edit
Same as 18: enumerate three checks on last bullet.

## Proposal 21 — Minimum-change / issue 7
proposal_kind: edit
Replace "both new checks" with "the three new checks" only.
