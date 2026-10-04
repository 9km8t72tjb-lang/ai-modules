---
ingested: 2026-10-04
sha256: 2f33d47bb28253b483f9fd2f9fe86ed34352311c79fbb86e30e25b5ecc7dbd15
---

# Orchestration run evidence for agent_spinner, September 2026

This note anonymizes a private research archive kept on the author's workstation, outside the repository. The archive holds per-case transcript digests, checked ledgers, and a merged proposal dated 2026-09-27. Its case identifiers name sessions and projects, so this note cites each case by a neutral label built from its run class and job class. Figures use the checker-corrected wording, and refuted entries are left out. The relevant content is excerpted below as the authoritative copy, and no path to the archive is given.

## Scope

The research asked what lets ultracode-style scripted orchestration on Claude Code catch defects. It then asked what agent_spinner must add to bring comparable fan-out, cross-checks, aggregation, and adversarial verification to hosts without Claude Code's Workflow tool.

It covers 16 working sessions from one owner's repositories, dated 2026-09-05 to 2026-09-26. Nine sessions ran on Claude Code with ultracode switched on, and their orchestrators wrote Workflow tool scripts. Those sessions held 15 completed Workflow runs, which dispatched 967 helpers in about 402 workflow minutes, with a harness token figure of about 85.4M. The transcripts record ultracode turning on and off, and some unscripted tails ran after it was switched off. Seven sessions ran on Cursor and orchestrated in prose.

## Method

1. A census read every completed Claude Code Workflow run in the window from local session records. It tallied script patterns, widths, helper states, tokens, and minutes.
2. Each case received a digest built from its local session transcripts. Scripted cases added their workflow scripts and result files.
3. Analysts wrote per-case ledgers of failures, missed events, successes, harness facts, recipe candidates, mechanics, and user interventions. Each failure carries a severity, a root cause, and a caught-by line.
4. A checker re-read the evidence behind each entry and marked it confirmed, narrowed with corrected wording, refuted, or unchecked. Of 152 failure entries, it confirmed 59, narrowed 91, refuted 1, and left 1 unchecked. The ledgers also hold 99 missed events.
5. An adherence ledger rated each agent_spinner doctrine block per case as followed, partial, ignored, or not applicable.
6. Four analyses grouped the entries by family, mechanics, gaps, and lessons. Three drafts proposed recipes, a skill body, and a mechanism, and one proposal merged them. Four refute-by-default critics raised 61 findings against its first version, and the second version resolves them.

## Caveats on the sample

The sample is small and was selected rather than sampled. It comes from one owner's repositories over three weeks.

Host and run class coincide. Every scripted case ran on Claude Code, and every prose case ran on Cursor. A comparison therefore cannot separate a host effect from an orchestration effect. The job mix also differs between the classes.

No scripted session loaded agent_spinner. Seven of the nine predate its release, and the other two ran under the Workflow tool's own doctrine with no load recorded. Their failures show which rules the doctrine lacks. Only the two doctrine-attached sessions test the doctrine itself.

Several figures are the analysts' own tallies, which the checker has not verified. The caught-by classification is also the analyst's, and the evidence critic reproduced it on the 93 scripted-run failures.

Severities are the checker-corrected ratings of failures. Missed events carry no rating.

Token figures come on different bases. The Workflow harness figure sums each helper's final request context size, so it measures context. Transcript sums come on two bases. Fresh tokens count input, cache creation, and output, and cache-inclusive context tokens add cache reads. A share compares only within one basis.

The mechanisms the scripted runs used occurred together, and no run varied one alone. The evidence therefore ranks none of them.

## Run classes

| Class | Host | What held the run's structure | Cases |
| --- | --- | --- | --- |
| Scripted | Claude Code | A Workflow tool script held fan-out, return schemas, joins, and gates in code. | 9 |
| Doctrine-attached | Cursor | agent_spinner's SKILL.md body was attached to the session, and the orchestrator had it in context as prose instructions. | 2 |
| Governed | Cursor | task_auto_check's readiness loop owned the run, and agent_spinner's invocation boundary lets it add nothing there by design. | 3 |
| Native prose | Cursor | The host's agent improvised the orchestration with no orchestration skill loaded. | 2 |

## Case register

The last column lists the failure families each case contributed to, with its entry count in parentheses. It comes from the member lists of the family analysis, and the families appear under "Failure families" below.

| Label | Class | Job | Scale | Families (entries) |
| --- | --- | --- | --- | --- |
| scripted-fidelity-review | Scripted | Derived wiki pages checked against the source captures they cite, with fixes for what the sources settle. | Completed launches ran 302 helpers (185, 81, and 36). An earlier launch started 65, and an aborted relaunch killed 12 more. | 1, 6, 7, 10, 11, 13, 15, 17, 18, 22 (16) |
| scripted-prose-sweep-a | Scripted | One style rule, dash removal plus jargon, applied in place across about 160 markdown files while keeping meaning and length. | 272 helpers and 12.06M fresh tokens. | 2, 6, 7, 10, 11, 12, 13, 17, 18, 19 (17) |
| scripted-prose-sweep-b | Scripted | One wording rule applied in place across about 80 files of a document tree that has a build step. | 170 helpers and 9.04M tokens. | 1, 2, 5, 7, 10, 11, 12, 16, 18, 20, 21 (16) |
| scripted-artifact-repair | Scripted | Drift repair across a task backlog, with repairs, new filings, and a granularity review. | 4 runs, 152 helpers, 102.5 minutes, and 17.13M tokens, plus 11 one-off helpers. | 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 18, 23 (24) |
| scripted-check-only-audit | Scripted | Check-only audit of 30 instruction files against authoring rubrics, with one verifier per finding. | 19 helpers, 3.1 minutes, and 1.5M tokens. | 4, 7, 10, 11, 15, 16, 18, 19, 20 (13) |
| scripted-design-panel | Scripted | Challenge to a built but uncommitted design through blind designers, judges, and refuters. | 10 helpers, 24.4 minutes, and 1.38M tokens. | 1, 2, 4, 6, 10, 11, 19, 22 (15) |
| scripted-research-synthesis-a | Scripted | Research across a corpus, merged into one task specification. | 16 helpers, 27.3 minutes, and 2.68M tokens. | 1, 2, 4, 5, 6, 7, 11, 13, 15, 19 (15) |
| scripted-research-synthesis-b | Scripted | Feasibility study and design over a large corpus. | 33 helpers and 4.81M tokens. | 1, 2, 3, 4, 5, 6, 11, 20, 21 (18) |
| scripted-disputed-claim | Scripted | Settle a figure that two passages disagree on, then edit. | 5 helpers, 7.0 minutes, and about 455,000 tokens. | 2, 3, 4, 5, 7, 12, 15, 19, 22 (10) |
| doctrine-fidelity-review | Doctrine-attached | The same job as scripted-fidelity-review, from a near-identical prompt. | 1 family agent, about 5 minutes. | 1, 2, 5, 8, 9, 11, 15, 18, 19, 21, 23 (13) |
| doctrine-multi-file-task | Doctrine-attached | One task implemented across many files, a mechanical rename plus semantic rewrites per surface. | 1 background checker in a session of about 9 minutes. | 1, 4, 6, 9, 12, 13, 14, 15, 23 (14) |
| governed-readiness-loop-a | Governed | Readiness loop on one task file. | 16 helpers, 26 minutes. | 1, 2, 4, 5, 9, 10, 16 (12) |
| governed-readiness-loop-b | Governed | Readiness loop on one task file. | 25 helpers, 46 minutes, 5 gate draws. | 2, 4, 6, 10, 16, 20, 22 (11) |
| governed-readiness-loop-c | Governed | Readiness loop on one task file. | 17 helpers, 24 minutes. | 1, 4, 10, 15, 16, 19, 21, 23 (10) |
| native-prose-sweep | Native prose | Meaning-preserving rewrite of contrastive negation across a markdown knowledge base, in three whole-tree passes. | 11 foreground writers, 70 minutes. | 1, 2, 5, 6, 9, 12, 13, 14, 18, 23 (16) |
| native-pointer-reconcile | Native prose | Knowledge-base pages reconciled against the code repositories they point at. | 3 background helpers over about 50 pages. | 1, 2, 5, 9, 11, 18 (12) |

## Five comparable pairs

Each pair did one job under different run classes. Each run states its helpers, its verification, and what landed. It closes with what surfaced afterwards, including what the user had to fix.

### Pair 1: raw-source fidelity review from near-identical prompts

**scripted-fidelity-review.** Launch 1 started 65 helpers, and 12 were killed when the user paused it for cost after about 48 minutes. An aborted relaunch killed 12 more. The completed main launch ran 185 helpers, 39 of them cache replays. A per-page review then ran 81 helpers and a second round 36. Those three launches used 23.3M, 10.5M, and 2.6M harness tokens, and launch 1's total is unrecorded. The plan held 43 units plus 4 gap units.

Before writing, two refute-by-default lenses refuted 0 of 148 findings, and each rated 59 of its 154 verification events partly true. Both lenses confirmed one wrong detail. After writing, a read-only review of each page raised 258 issues on 27 pages, 13 of them high. A bounded second round repaired 18 pages, and all 18 re-checks passed at a lowered effort the report left unnamed. The run landed 37 captures, 29 pages, the index, and the log in two commits, and 817 non-high findings stayed unverified. The user widened the run to auto-fix and accepted the offered per-page review, which found the integrator's damage.

**doctrine-fidelity-review.** One family agent ran for about 5 minutes. The requested paired check ran as the producer's own string-presence script. The orchestrator re-derived by grep, missed one restore, and read only the diff stat. Six files landed, five pages and the log, and all six restores were faithful. The user fixed nothing in session. Even so, 72 of 76 pages were never read in full, and the audit baseline plus one checked stamp now certify reads that never happened.

### Pair 2: meaning-preserving prose sweep

**scripted-prose-sweep-a.** 272 helpers covered about 160 files: 175 writers, 12 of them killed and rerun, plus 97 checkers, on 12.06M fresh tokens. Per-file checkers failed 4 of 97, all false zero counts. The orchestrator added a second dash gate, lint with baseline attribution, and requirement-word deltas. The run changed about 100 files and caught and fixed one lint regression. During the run, one writer ran a whole-tree stash in the shared tree. It reset dozens of files that belonged to other writers and restored most of them, and the stash stayed in the repository. The user stopped the run for budget with most files modified and none verified, then authorised the resume. Three edited files bypassed review after the resume.

**scripted-prose-sweep-b.** 170 helpers ran, about 80 writers and about 80 checkers, on 9.04M tokens. The checkers ran in a search role that disclaims review, under a schema that let a pass go uncited. They returned nearly all bare passes and one recall-confirmed flag. A lint diff against a pristine baseline, where 97 blocking findings predated the sweep, and a baseline build carried the safety claims. The run edited most of the tree. Residual targets remained in at least 8 files, with inconsistencies across sibling files. In the inline follow-ups the user acted as checker for own-authority calls, 17 interventions in all.

**native-prose-sweep.** Eleven foreground writers held 1 to 73 files each and made three whole-tree passes in 70 minutes. No checker ran. Some helpers compared edits against the pre-session commit, but only for links, key numbers, pattern counts, and diff stats. No helper verified another helper's work. A presence count with no before value closed the plan item "verify no meaning loss". The run changed 73 files, and contrast markers fell from 534 occurrences to 4. The user ran two repair sessions the same day, on 13 pages and then on 18 pages plus the schema, the log, and a raw file. One inverted claim was still live five days later, and one deleted design point was still missing when the research closed.

### Pair 3: codebase-pointer reconcile

**scripted-fidelity-review, merge side.** 43 finder units were keyed by lineage. Returns were schema records with verbatim quotes and coverage fields. Two lenses checked them, and code computed survival and counted the unverified remainder.

**native-pointer-reconcile.** Three background helpers split about 50 inventoried pages by repository cluster. Between finder and writer, the orchestrator read selectively and re-derived about seven claims. It applied nine findings on a helper's word and ran no diff review or lint after writing. Twenty files landed in one commit, and the spot-checked edits were correct. The user needed three rounds, and two forks were re-asked for evidence. Six of 20 decision items never reached the user, and about 45 of about 64 fix findings got one collective, uncounted deferral. Some of those defects still stand. The report said every inventoried page was compared.

### Pair 4: readiness and repair loops over task files

**scripted-artifact-repair.** Four runs used 152 helpers (39, 49, 10, and 54) in 102.5 minutes on 17.13M tokens, and an unscripted tail added 11 one-off helpers. Per-repair checkers read the writer's report verbatim plus the diff, against a checklist of 6 to 9 lines. 25 of 31 first-pass writes came back with issues, 113 in all, and one remediation round followed. Critics aimed at the scout found 3 of its 4 "current" items drifted. Everything landed in one about-40-file commit.

The user demoted five ready stamps by hand and forced the revert of a rewrite of a completed item. The next morning the user reversed the granularity review and folded 9 items into 3. No remediation was re-checked, and the second run's three filings never had a paired check. In the tail, two helpers' completed reports queued behind a blocking wait on a proxy predicate and were never delivered.

**governed-readiness-loop-a.** Sixteen helpers ran for 26 minutes. The verifier judged proposals before they were applied, reading paraphrases and the orchestrator's preferences. Only the next gate read the applied file. The task under review gained a ready stamp. Five committed rule clusters were deleted with no decision routed to the user, and one unapproved wording change landed. Nothing was fixed in session, and the deletions landed in a commit.

**governed-readiness-loop-b.** Twenty-five helpers ran for 46 minutes over 5 gate draws. Hand-offs were retyped, and ready came on the fifth draw, at the cap. The task gained 94 lines and lost 35. The later implementation found four protocol defects and one Acceptance item it could not stage, and the user authorised rewriting the Acceptance.

**governed-readiness-loop-c.** Seventeen helpers ran for 24 minutes. Verifiers saw 9 to 19 percent of the reviewer text plus the orchestrator's preferences. One gate finding was relabelled mechanical and fixed outside the verifier's path. The task gained 10 lines and lost 7, and the change stayed uncommitted. An introduced banned ordinal pointer waited for the next gate.

### Pair 5: multi-file task implementation

**doctrine-multi-file-task.** One background checker ran, read-only by prompt only. It requested the fast model, and the record shows the default model. The session took about 9 minutes and the checker about 4. The producer wrote an 11-item checklist that tested old strings absent and never tested the new form present. The checker received no Acceptance and no baseline reference. The verdict went out before the checker returned, and the orchestrator stashed the whole change while the checker read.

The run applied a slug script over about 120 files and a semantic rewrite by generic name swaps, and the final commit touched about 180 files including later fixes. Three audits in another harness plus a backlog repair then found 17 stale source hashes and seven surfaces missing a required flag. They also found four archived quotations rewritten under a contract that left them ambiguous, and one move that lost its history at 46 percent similarity. The repository lint never ran, and its four errors predated the run.

**Scripted comparators: scripted-prose-sweep-b and the first run of scripted-artifact-repair.** These used about 80 writers plus about 80 checkers, and 12 writers with verifiers (39 helpers). Per-file checkers diffed against a stated baseline. The verifier checklist asked for unrequested changes and for missing requested ones. Nine of 12 repairs were flagged, the linter ran last, and the return waited for every verdict.

### Scripted cases without a pair

These five cases ground the recipes for design panels, research synthesis, check-only audits, and disputed claims.

| Label | Helpers | What its checks caught | What surfaced afterwards |
| --- | --- | --- | --- |
| scripted-check-only-audit | 19: 11 reviewers and 8 verifiers. | 8 findings raised, 7 confirmed, 1 refuted, and 2 downgraded. | The user reversed the direction of one recommendation and chose a live fix. Six empty reviews were reported as nine clean families, and a class confirmed in one family survived in families reported clean. |
| scripted-design-panel | 10: 4 designers, 3 judges, and 3 refuters. The designers were blind by prompt only, and two of them saw traces of the shipped design. | Four defects that had passed 4 new and 54 existing test scenarios. Two of the four were specified by the ready task or inherent to it. The refuters caught a false precedent leading two of the three ballots. | The user picked an option whose main objection the menu had dropped, and an 8-file revert and re-scope followed. |
| scripted-research-synthesis-a | 16. | The critic found that the drafts' universal inline floor contradicted a shipped readiness loop's stop rule, which 3 drafters and 4 judges had missed. | A positional join built the task on the lowest-scoring draft, and a placeholder reached eight briefs. The merged task was committed before a gate found 10 issues, then 2 more. |
| scripted-disputed-claim | 5. | One checker returned an alternative reading in a free-text field that carried no verdict value. The merge dropped it and relayed another checker's point from the same field. | Three hypothesis-seeded checkers were reported as independent, and a placeholder-sourced figure entered the document. The user caught date-only changes, and two reverts followed. |
| scripted-research-synthesis-b | 33. | One verifier flagged the documentation-derived facts on its own initiative. | Absence claims reached 23 design helpers as verified facts, and a live probe later overturned two blockers. The user caught about twelve defects in two days of inline follow-ups. |

## Base rates

| Metric | Value | Caveat |
| --- | --- | --- |
| First drafts of spec-like writes failing a strict check | 6 of 12 and 12 of 16 task repairs carried a should-fix finding or worse. 3 of 3 new filings failed, and 27 of 27 single-pass page rewrites were flagged. | Two scripted cases only. Counting any issue, 25 of 31 first-pass task writes came back flagged. The research plans one repair round for half to all first drafts. |
| Checker results against actual misses in mechanical sweeps | Checkers failed 4 of 97 files and 1 of about 80. Retrospective reads found target misses in at least 8 of about 80 files, about 9 percent. | Two sweeps. The 8 of about 80 is a floor from retrospective reads, with no full re-check behind it. |
| Refutation rates by target and stance | Three refute-by-default runs refuted 0 of 148 finder findings, 1 of 8 audit findings, and 16 of 24 change proposals. Three seeded checkers refuted 0 of 3 on a hypothesis whose refutation condition covered one sub-claim. Six orchestrator-authored framing claims came back 6 of 6 refuted, each steered by its brief. Repairers rejected 0 of 258 review issues, then 3 of 46 in a second round, one of them a checker false positive. | The first three runs share one stance, so stance cannot explain their spread. They also differ in target, prompt, checklist, and verdict options, and no run varied one of these alone. The repairer contrast is uncontrolled. No ledger shows the first-round repairers lacked a confirm-first instruction, and they read sources with a median of 25 tool calls. |
| Checking share of token figures | One sweep's checkers took 37.5 percent of the harness token figure. On summed transcript usage they took about 20 percent of cache-inclusive context tokens and about 37 percent of output tokens. Another sweep's verifiers took 33.0 percent of fresh tokens. | The harness figure sums each helper's final request context size, so it measures context. The ledgers give no share on one basis for the other runs. |
| Widths | Median 36 helpers per run, range 5 to 260. 14 of 15 runs used ten or more. Observed concurrency was 12. | Scripted runs on one host. The 12 is the ceiling seen in two sessions on 2026-09-05, one of them checker-verified, consistent with first-in-first-out queuing. |
| Helper errors | 1 of 967 helpers ended in a terminal error. 2 of 967 were schema-valid hollow returns, both load-bearing and both counted as successes. | A hollow return counts only where a later read caught it, so 2 is a floor. |
| Self-reports against measurement | Measurement contradicted 4 of 97 writers' dash counts (4.1 percent), 3 of 11 reviewers' read claims (27 percent), and 26 of 78 writers' fix counts (33 percent). | Three different measures from three runs. The rates do not compare with each other. |
| Who caught the scripted runs' failures | Of 93 unrefuted scripted-run failures, 39 percent went uncaught in session. The user caught 28 percent, the orchestrator 13 percent, a helper or the host 12 percent, and a later round 9 percent. The user caught 6 of 9 highs. In 8 of 9 sessions a correct in-run flag never reached the user. | The analyst's classification, which the evidence critic reproduced on the 93. Scripted runs only. |
| Failure mix | Among the 93 scripted-run failures, the largest class was report misstatement, with 18. Orchestration-script bugs and lenient verification followed with 14 each, then context loss with 11. Wrong counts reached the user in at least 6 of 9 sessions. | The class is each entry's own label, separate from the 23 families. All 14 script bugs come from scripted cases, so scripts bring defects of their own. The session figure is a floor. |
| Cost stops | The user stopped 2 of 9 scripted sessions for cost. | Nine sessions. One stop followed an unestimated widening, and the other followed a launch that sent every finding to verification past a size guideline it never named. |
| Adherence with the body attached | 1 of 21 doctrine verdicts was followed in the fidelity review (8 ignored, 9 partial, 3 not applicable). 2 of 21 were followed in the multi-file implementation (3 ignored, 14 partial, 2 not applicable). | Two sessions on one host. The checker confirmed 36 of the 42 verdicts and narrowed 6. |

The samples are small, were selected rather than sampled, and come from one owner's repositories. Several figures are the analysts' own tallies, which the checker has not verified.

## Failure families

150 of the 151 unrefuted failures and 82 of the 99 missed events fall into 23 families. The unassigned failure is a work-item lifecycle misread outside orchestration. The 17 unassigned missed events are observations, harness facts, notes about the case reports, one success counterexample, and duplicates of counted failures. The ranking weighs severity, frequency, persistent damage, and how often the user had to act as checker.

The scripted column covers the nine Claude Code sessions, and the prose column covers the seven Cursor sessions of the other three classes. Both count failures and missed events together. The high, medium, and low columns rate failures only. In the caught column, "user" counts catches by the user, in session or in a later user-started repair session. "Later" counts later rounds, audits, and sessions. "In-run" counts the orchestrator, a helper, or the host during the run. "Never" counts entries that no pass or person caught as such. Most surfaced only in the retrospective, and family 9's five had consequences that later audits and user repair sessions surfaced.

| # | Family | Scripted | Prose | High | Medium | Low | Missed | Caught in session | Doctrine |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | Writes no independent pass reads after they land | 12 | 10 | 1 | 8 | 7 | 6 | user 7, later 4, in-run 2, never 9 | mixed |
| 2 | Findings, flags, forks and objections dropped between stages | 11 | 10 | 1 | 6 | 5 | 9 | user 3, later 1, never 17 | mixed |
| 3 | Unverified premises promoted to settled facts | 8 | 0 | 4 | 1 | 1 | 2 | user 4 (all highs), later 1, in-run 1, never 2 | rule-causes |
| 4 | Checks pre-decided by their framing or verdict space | 6 | 8 | 1 | 6 | 4 | 3 | user 3, later 3, never 8 | rule-causes |
| 5 | User-owned decisions settled inside the run | 8 | 5 | 0 | 3 | 6 | 4 | user 5, never 8 | mixed |
| 6 | One shared tree with prose-only containment | 7 | 4 | 1 | 3 | 4 | 3 | in-run 3, later 3, never 5 | needs-mechanism |
| 7 | Results counted and joined before identity and substance are checked | 11 | 0 | 2 | 2 | 5 | 2 | in-run 7, never 4 | mixed |
| 8 | Trusted markers that outrun their evidence | 3 | 2 | 2 | 2 | 0 | 1 | user 3, never 2 | mixed |
| 9 | Width and shape set by convenience batches and routing | 0 | 6 | 2 | 3 | 0 | 1 | in-run 1, never 5 | mixed |
| 10 | Checker judges a retyped or partial rendering of its inputs | 5 | 6 | 0 | 3 | 6 | 2 | in-run 1, never 10 | mixed |
| 11 | Report claims more verification, independence or completion than ran | 16 | 3 | 0 | 3 | 4 | 12 | later 1, never 18 | mixed |
| 12 | Run state read from self-reports, with no recorded baseline | 6 | 2 | 0 | 4 | 3 | 1 | user 4, later 1, never 3 | absent |
| 13 | Completion, stop and resume inferred from proxies | 8 | 2 | 1 | 3 | 2 | 4 | user 4, in-run 1, later 1, never 4 | mixed |
| 14 | Mechanical scripted edits applied to semantic prose | 0 | 7 | 1 | 3 | 1 | 2 | user 2, later 3, in-run 1, never 1 | absent |
| 15 | Planned or mandated checks dropped silently | 5 | 3 | 1 | 1 | 1 | 5 | later 1, never 7 | mixed |
| 16 | All-clears accepted on the verdict word alone | 3 | 4 | 0 | 4 | 2 | 1 | in-run 2, later 2, never 3 | mixed |
| 17 | Fan-out cost and widening decided before any estimate or pause point | 4 | 0 | 0 | 2 | 0 | 2 | user 3, never 1 | absent |
| 18 | Counts and coverage written by hand | 9 | 4 | 0 | 1 | 7 | 5 | never 13 | needs-mechanism |
| 19 | Deterministic probes whose result is fixed by their construction | 9 | 2 | 0 | 0 | 4 | 7 | in-run 4, never 7 | absent |
| 20 | Checking and repair stop at the raised instance | 4 | 2 | 0 | 3 | 0 | 3 | in-run 2, user 1, never 3 | absent |
| 21 | Acting before reading the governing rules and requirement sources | 4 | 2 | 0 | 1 | 3 | 2 | user 4, never 2 | mixed |
| 22 | Shown claims confirmed or applied by recall | 4 | 1 | 0 | 2 | 3 | 0 | in-run 4, never 1 | rule-causes |
| 23 | Presence, count, header or sample checks standing in for content claims | 1 | 5 | 0 | 1 | 0 | 5 | in-run 1, later 1, never 4 | absent |

The table holds 232 entries, 144 from scripted runs and 88 from prose runs. Its failures split into 17 high, 65 medium, and 68 low. Summed across families, the user caught 43 entries, later passes 22, and the run itself 30, while 137 were never caught.

The doctrine column uses six values:

- **absent:** no rule exists.
- **not-reached:** the rule exists, and the run never loaded it.
- **not-followed:** the rule was in context, and the run ignored it.
- **needs-mechanism:** the rule cannot hold by instruction alone.
- **rule-causes:** an existing rule produces the failure, so the fix edits that rule.
- **mixed:** a combination of these.

### Why the doctrine missed these

No scripted session loaded agent_spinner, so the scripted members show which rules the doctrine lacks. Of the seven prose sessions, three ran under task_auto_check's readiness loop, where agent_spinner adds nothing by design. Two never loaded it. Two had its body attached and still broke its rules.

In both attached sessions, the adherence verdicts mark width, checking, run state, the phase-plan bounds, and confirmation provenance as ignored or partial. The fidelity review also ignored delegation depth and the references. The multi-file session followed delegation depth, and its verdicts include no references row. Those rules were in context, so these verdicts are the evidence that prose alone did not carry the doctrine.

The same Claude model reproduced the prose-run failure classes once no Workflow script held the structure. That happened in the unscripted tails that followed scripted runs.

Some failures come from the doctrine text itself, which the rule-causes value marks. The settled-facts clause of prompt assembly reproduces family 3. The checking block hands the checker the producer's report verbatim, which works against blind derivation in families 4 and 22. The routing clause handed an explicit agent_spinner run to the owning family's single agent, which feeds family 9.

Family 21 is non-adherence to rules already in context. The attached body stated every rule the run skipped, so mandatory reference loading alone would leave the defect in place.

## Mechanisms observed together

Scripts made six properties cheap to encode:

- width equal to an enumerated list;
- returns checked before they count;
- joins by identity;
- counts computed from records;
- a verdict that waits for every checker;
- a review of every landed write against a recorded baseline.

Runs that encoded them avoided the prose runs' failures. Scripted runs that left one out failed in families 1, 7, and 18. Three failures occurred even under scripts: schema-valid hollow returns, joins by index or shared label, and integrator writes nobody reviewed. The first two appear only in scripted runs, since family 7 has no prose entry. The third appears in both kinds of run, as family 1's members show.

In the selected pairs, the catches came from narrowing, cited clears, and a review-capable checker role. These worked together with coverage by construction, a per-file review after each write, and baseline-differential gates.

- **Coverage by construction, plus one read-only review of every written file.** One reviewer per page diff raised the 258 page issues. One refute-by-default checker per repair, with a closed checklist, raised the 113 repair issues. No prose run had an independent pass read an applied diff for meaning against its baseline.
- **Deterministic commands against a recorded baseline.** These carried the sweeps' safety claims: 97 blocking findings that predated one sweep, requirement-word deltas over 100 files, a baseline build that settled a suspected regression, and a linter catch in a file no reviewer saw. A gate carries such a claim only where its executable resolved and its expectation held.
- **Checker stance, with narrowing and cited clears.** The fidelity lenses refuted none of the 148 findings they verified. Each lens still rated 59 of 154 events partly true, and the planner prompt said such a correction overrides the finding. In one sweep, nearly all per-file checkers returned bare passes, from a role whose contract disclaims review, under a schema that let a pass go uncited. In another sweep, per-file adversarial checkers caught all 4 false-zero writers with no false positives.

These mechanisms occurred together, and no run varied one alone, so the evidence ranks none of them. Refutation counts alone say little. The paired sweeps were also narrower asks than the negation rewrite they are compared with.

## What the program proposes to ship

The proposal of 2026-09-27 answers the families with three layers. A body rewrite puts each broken rule at the point of decision. One recipe per job class gives each kind of run its procedure. A bundled standard-library Python run ledger dispatches nothing and refuses to close a run while any unit, record, fork, or landed write is unaccounted for. The layers ship in order: the ledger, then the body blocks that cite it, then the recipes.

The body rewrite and the recipes are untested hypotheses. Their evals measure adherence to a rule, and none measures the act of reading. The ledger carries the enforceable refusals, and they bind only when the orchestrator calls it. A report on a run with no clean close therefore says so in its opening sentence.

Routing runs in a fixed order. The selector matches orchestration weight first. A read-only diagnostic or a single judgement question is answered inline and takes no recipe. An ask that matches no shape takes the smallest covering shape and no recipe. An ask that matches a shape then matches the recipe table, and a matched recipe is the procedure the run follows. An ask that matches a shape but no recipe runs that shape from the body and says so.

The proposal assigns families to the run protocol, the checks, and the ledger verbs. A job recipe composes those entries, so the job recipe table lists the families seen in each recipe's grounding cases, derived from the case register.

### Job recipes

Each job recipe ships as one reference file with fixed fields: trigger, ledger steps, two to four helper phases, width, roles and returns, adversarial checks, orchestrator gates, failure handling, stop-and-ask points, report, cost profile, tier notes, and post-run checks. Every cost profile keeps three things whatever else is cut: coverage by construction, a review of every landed write, and baseline-differential gates. Each cut is offered only as a narrowing the user chooses, with the checks it drops.

| Recipe | Ask and artifact signals | Shape it runs under | Grounding cases | Families seen in grounding cases (derived) |
| --- | --- | --- | --- | --- |
| J1 Source-fidelity review and fix | Derived pages checked against the sources they cite, with fixes for what the sources settle. | Per-artifact fan-out | scripted-fidelity-review, doctrine-fidelity-review, native-pointer-reconcile | 1, 2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 18, 19, 21, 22, 23 |
| J2 Meaning-preserving prose sweep | One style or wording rule applied in place across a tree, keeping meaning and length. | Per-artifact fan-out | scripted-prose-sweep-a, scripted-prose-sweep-b, native-prose-sweep | 1, 2, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23 |
| J3 Multi-file task implementation | One task whose change spans many files, with a written acceptance list. | Per-artifact fan-out | doctrine-multi-file-task, with two scripted comparators | 1, 4, 6, 9, 12, 13, 14, 15, 23, from doctrine-multi-file-task alone |
| J4 Drift repair across many artifacts | Many specifications checked against the repository and repaired, where other gates own their stamps. | Per-artifact fan-out | scripted-artifact-repair and the three governed readiness loops | Every family except 14 and 17 |
| J5 Design option panel | A request for options, or a built design under challenge. | Lens panel, or the paired refute-by-default check for a challenged build | scripted-design-panel, with parts of both research syntheses | 1, 2, 4, 6, 10, 11, 19, 22, from scripted-design-panel alone |
| J6 Understand-then-synthesize research | Research, assessment, or mining across a large corpus into one deliverable. | Lens panel | scripted-research-synthesis-a, scripted-research-synthesis-b | 1, 2, 3, 4, 5, 6, 7, 11, 13, 15, 19, 20, 21 |
| J7 Check-only audit sweep | Sweep everything with an audit and report what to fix, read-only. | Per-artifact fan-out | scripted-check-only-audit | 4, 7, 10, 11, 15, 16, 18, 19, 20 |
| J8 Disputed-claim settlement | Two passages disagree on a figure or claim, and the ask wants it settled by an edit. | Paired refute-by-default check | scripted-disputed-claim | 2, 3, 4, 5, 7, 12, 15, 19, 22 |

### Run protocol

The run protocol ships as one reference. Three blocks precede its six steps.

- **Capability ladder.** One rung covers the inline floor, where no delegation surface exists. The other covers spawned roles, under batch delivery or notice delivery as the probe records. Headless workers are not available in this version.
- **Run directory.** The run directory, `.agent_spinner/`, sits in the working root, and its own `.gitignore` holds `*`. At init the ledger plants a known positive there and records which gates report it, which serves family 19.
- **Ledger floor.** The ledger needs Python 3.9 or newer. When the ledger itself errors, the orchestrator records the error, continues by hand, and names each check left unenforced.

| Step | What it does | Families it answers |
| --- | --- | --- |
| P1 Open the run | Probe four capabilities by observation: a delegation surface, a host-enforced read-only lever, a depth or effort control, and concurrency. Read the governing documents and requirement sources in full, validate the inventory, and record a baseline with hardened git reads. Take gate answers from the request, pilot two or three items to price the run, and announce a plan of two to four helper phases with a model and an effort per role. | 9 |
| P2 Render every brief from files | Keep the request, intent, preamble, access rules, shared rules file, and per-item notes as files, and render each brief from fixed blocks. Relay upstream material by path, lint every brief, and keep text a blind pass must not see out of the workspace until it returns. | None named. C2's blind pass and C3's verbatim hand-off depend on it (derived). |
| P3 Return files and the acceptance gate | A helper that may write files writes its return file. A read-only helper ends with its return block, which the orchestrator relays verbatim to the ledger. The gate rejects missing sentinels, placeholders, uncited passes, and short lists, allows one retry, joins by identifier only, and tags each confirmation recall-confirmed or independently surfaced. | 2, 7 |
| P4 Completion, waves, stop and resume | Completion is an accepted return, and a notice is only a hint to check status. Poll inside the turn with bounded waits, work in waves, size later phases from accepted records, and let the verdict wait for every checker. A stop file blocks dispatch, and every turn ends with a closing or interim report. | 13 |
| P5 Keep shared state still | No pass runs a whole-tree version-control state command during the run. Every reading pass reads a file-copy snapshot, and the run writes no ref or object into the user's repository. Write grants name paths, and a guard records HEAD, the stash list, and the status around every pass. | 6 |
| P6 The findings ledger, decision packets and the report | The ledger imports every return in full, and each record gets one disposition. Each fork becomes a decision packet with options, costs, and objections. The report is built from the ledger's tally, and a run without a clean close says so in its opening sentence. | 2, 11 |

### Checks

| Check | What it does | Families it answers |
| --- | --- | --- |
| C1 Check every landed write | Measure every path's net change against the baseline and give each changed path a check row. A read-only checker reads each claim-changing diff against two standing checklist lines, and the orchestrator never certifies its own inline work. | 1 |
| C2 Build a clean checker | Build the checklist from the acceptance contract, testing the required form present and the old form absent, with a closed verdict set and no steering. Derive the orchestrator's own claims blind first, and run one challenger per side of a trade-off. | 4 |
| C3 Hand off verbatim and unsteered | Checkers read producer returns in full by path, briefs hold no paraphrase, and the writer applies only bytes the checker saw. | 10 |
| C4 Run deterministic gates against the baseline, with positive controls | Run every named gate on the baseline and on the final tree, and report the deltas. Give each gate an expectation, record its resolved executable, and fire every self-written count on a known positive first. | 12, 19 |
| C5 One repair round with one re-check | The repair list holds every item that failed verification, plus each confirmed class-sweep instance. Each repaired item is re-checked once at no lower depth, and a second round runs only on the user's word. The re-check depends on an owner decision. | 20 |
| C6 Aim critics at the run's own conclusions | A completeness critic proposes capped gap units, paired with a surplus read. Scout critics refute the items called current, and a repository-grounded critic charges a design with named mechanisms and limits. | 20 |
| C7 Set verification scope, depth and calibration | State the verification scope and estimate before dispatch, and keep checker depth at least the producer's. Choose a checker role whose contract is review, and reserve "independent" for passes that shared neither the claim nor its framing. | None named. Its depth flag and recall label serve families 15 and 22 (derived). |
| C8 Sweep residuals and classes, and check receipts | Sweep the target class across every in-scope item after a diff-scoped check, and enumerate every instance of a confirmed class. Check read receipts against recorded input versions, and count a path as read only on tool evidence of a full read. | 16, 20 |
| C9 Hand stamps, completed artifacts and markers to their owners | Route every write to a stamped target to its owning gate or the user before dispatch, whatever the write changes. A marker advances only over what the run examined. | 8 |
| C10 Tier the evidence and keep weak claims conditional | Tag each fact as measured, read, documented, placeholder, or inferred. Only measured and read facts settle, and every weaker claim stays conditional with the probe that would settle it. | 3 |

### Families without a protocol or check entry

Eight families take their answer from body blocks and ledger verbs alone.

- **Family 5, user-owned decisions.** The judgement block names the fork classes and requires decision packets. An answer the request states is the user's answer. On a host with no later turn, an unanswered gate ends the run with its packet. The ledger keeps fork rows, and close refuses an open fork or a write after an open gate. The rest belongs to a change in task_auto_check's own family.
- **Family 14, scripted edits on prose.** Prompt assembly separates pointers from claims, and an edit-mechanics reference adds a wrap-seam gate.
- **Family 15, dropped mandated checks.** Planned and mandated steps become ledger rows, and a path counts as read only on tool evidence of a full read. Close flags every checker shallower than its producer. A sweep samples its checkers only for glyph-for-glyph hunks, and only on the user's word.
- **Family 17, cost before any estimate.** The phase plan requires an estimate, treats widening as a fork, and runs writes in waves. A stop file gives a real pause, and the estimate counts the orchestrator's own context load.
- **Family 18, hand counts.** The ledger prints every number, and close checks the tally. Without python3, the orchestrator keeps the same files by hand and reports each check as unenforced.
- **Family 21, acting before reading.** Orient rows and reading the recipe stay in the rewrite as hypotheses. The guarantee rests on the ledger's refusals, which bind once the body calls init and reaches a clean close.
- **Family 22, recall confirmations.** The checking block requires a blind derivation of the claim a verdict rests on, and remediators give dispositions. The ledger tags each confirmation recall-confirmed or independently surfaced, and the report lint flags "independent" on a recall-confirmed row.
- **Family 23, proxy checks for content claims.** A claim-type rule in the checking block bars a count or presence check from clearing a content claim.

### The run ledger

The ledger's verbs and flags were provisional when the proposal closed. The proposal maps each verb to the families it serves.

| Verb | What it does | Families | Status |
| --- | --- | --- | --- |
| `init` | Writes the run directory, loads the enumerated list as rows, and records exclusions, the baseline, and stamped targets. It plants a known positive and runs each named gate at the baseline. | 7, 8, 9, 12, 19 | core |
| `init --probe` | Renders the fixed probe brief for each spawn route and records each capability as established, assumed absent, or unverified. | 6, 11 | core |
| `attach` | Re-enters an open run after a notice, a user message, or a new session, checking HEAD and the tree guard. | 2, 13 | core |
| `brief` | Renders each brief from fixed blocks, relays by path, records input versions, and lints steering words. | 3, 4, 10 | core |
| `dispatch` | Records a spawn the orchestrator makes, with the requested model and effort. It refuses while a stop, an unchecked wave, or an open gate stands. | 5, 11, 13, 17 | core |
| `accept` | Validates a return, imports its records, takes relayed final messages, and checks receipts against recorded input versions. | 2, 7, 13, 16, 22 | core |
| `rows` | Creates one row per accepted finding, repair, or gap record, so a later phase keeps its width equal to its records. | 2, 7, 20 | core |
| `dispose` | Records one final disposition per record, with narrowings, attributions, and user gates. | 2, 5, 9, 11 | core |
| `diff` | Measures the net change against the baseline with attribution and adds a check row for every changed path. | 1, 6, 12, 19 | core |
| `gate` | Runs a command without a shell, with an expectation, its resolved executable, and a baseline run. | 12, 15, 19 | small add-on |
| `snapshot` | Copies the files a reading row needs into the run directory, from the baseline or from the base commit for a blind pass. | 6 | small add-on |
| `status` | Prints the live tally, the open rows with their deadlines, the open gates, and the repair list. | 11, 13 | core |
| `show` | Prints one row's records in full for the orchestrator's judgement reads. | 2 | core |
| `search` | Searches the run directory in Python with its own positive control. | 19 | small add-on |
| `stop` | Creates the stop file that blocks further dispatch. | 13, 17 | small add-on |
| `close` | Renders the tally block and flags recall-confirmed rows called independent and checkers shallower than their producers. It refuses while anything is unaccounted for. | 1, 2, 5, 11, 12, 13, 22 | core |

Three refusals answer failures the scripted runs had too, and each has a planned script test. First, `accept` rejects a placeholder value and a list short of its row's obligations, and `brief` refuses to relay an unaccepted return. Second, `init` and `rows` refuse duplicate and case-colliding slugs, and every join reads identifiers only. Third, `diff --add-checks` builds check rows from the measured diff, whoever wrote, and `close` refuses a changed path with no accepted check from another row.

## Eval run on Cursor, 2026-10-03

On 2026-10-03 the agent_spinner behavioral evals ran on the Cursor vendor with the `auto` worker model. 19 of 21 evals passed every assertion. `containment_one_path` failed two assertions, which expected three helper briefs, each declaring exactly one distinct target path. `planted_defect` failed one assertion, which expected a record of what the run examined and cleared.

The runner's source states that the Cursor CLI has no disallowed-tools flag, so on that vendor the runner declares a withheld tool in a prompt note. The inline-floor eval therefore rested on a declared absence of the spawn tool there. These facts were read from the run's local grading output and from the runner's source on 2026-10-04.

## Open questions

- Which mechanism carries the catches. The mechanisms occurred together, and no run varied one alone.
- Whether the body rewrite and the recipes raise adherence. Both are untested, and their evals measure adherence to a rule rather than the act of reading.
- Whether the ledger binds in practice. Its refusals bind only when the orchestrator calls init and close, and the evidence shows orchestrators skipping mandated tool runs without saying so.
- How much of the difference between script and prose belongs to the host. Run class and host coincide in this sample.
- What drives the spread in refutation rates. Target, prompt, checklist, and verdict options all varied together.
- How many hollow returns and false self-reports went uncaught. The measured rates are floors.
- What a checker on a different model adds. No run measured model diversity between producer and checker.
- Whether a planned session boundary at half the host's context window helps wide runs. The evidence shows the context pressure, and the threshold itself goes beyond it.
