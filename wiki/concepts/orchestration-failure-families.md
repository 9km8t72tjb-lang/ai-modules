---
title: Orchestration failure families
created: 2026-10-04
updated: 2026-10-04
type: concept
tags: [skill, agent, experiment, verification-gap]
sources: [raw/notes/agent-spinner-run-evidence-2026-09.md, raw/notes/agent-delegation-host-observations-2026-09.md]
confidence: medium
---

# Orchestration failure families

## Definition

In an orchestrated run, one agent, the orchestrator, hands parts of a job to helper agents and combines what they return. An orchestration failure family groups the failures and missed events of such runs that share one root cause. This page holds the run evidence behind the recipes proposed for agent_spinner, where a recipe is the procedure for one class of job. It records the families with their counts, the base rates, and a register of the observed cases. It also lists the families seen in each recipe's grounding cases, which are the cases a recipe rests on. Last, it maps each run-protocol step and check to the families it answers. Every case appears under a neutral label built from its run class and job class ([run evidence](../raw/notes/agent-spinner-run-evidence-2026-09.md)).

The research asked two questions. The first was what lets ultracode-style scripted orchestration on Claude Code catch defects. The second was what agent_spinner must add so that hosts without Claude Code's Workflow tool get comparable fan-out, cross-checks, aggregation, and adversarial verification. Fan-out means dispatching many helpers at once. The sixteen working sessions studied ran from 5 to 26 September 2026, and the analysis closed with a merged proposal on 27 September 2026.

The analysts' own tallies cap this page at medium confidence, because the research checker has not verified them. The analyst also made the classification behind one base rate, the one on who caught the scripted runs' failures. The evidence critic reproduced that classification on the 93 failures that base rate covers. Every figure also rests on one research archive, which the two raw notes this page cites anonymize.

The sample limits how far any figure generalizes. The research selected its cases rather than sampling them, and they come from one owner's repositories over three weeks. Host and run class also coincide. Every scripted case ran on Claude Code and every unscripted case on Cursor, so no comparison here separates a host effect from an orchestration effect.

## Current state of knowledge

A census read every completed Workflow run in the study window, and each case got a digest built from its transcripts. Analysts wrote a ledger for each case, recording its failures, missed events, successes, harness facts, and user interventions. A checker re-read the evidence behind each of the 152 failure entries. It confirmed 59, narrowed the wording of 91, refuted 1, and left 1 unchecked. The ledgers also hold 99 missed events. The figures below use the checker-corrected wording and leave the refuted entry out. An adherence ledger rated, for each case, whether the run followed each block of agent_spinner's doctrine, the rules its SKILL.md body states. Four refute-by-default critics, which treat a claim as wrong until evidence clears it, raised 61 findings against the first merged proposal. Its second version resolves them.

### Run classes and case register

The cases fall into four run classes. In a scripted run, a script for Claude Code's Workflow tool held the run's structure in code: its fan-out, the schemas helper returns had to match, the joins that combined results, and its pass or fail gates. Scripted runs ran on Claude Code with ultracode switched on. In a doctrine-attached run, agent_spinner's SKILL.md body was attached to an unscripted run as prose instructions. A governed run ran inside task_auto_check's readiness loop, where agent_spinner adds nothing by design. In a native prose run, the host's agent improvised with no orchestration skill loaded. The last three classes all ran on Cursor. The nine scripted sessions held 15 completed Workflow runs, which dispatched 967 helpers in about 402 workflow minutes.

Each row below is one case. Each token total is given on the basis the evidence states, and the base rates below explain those bases. The last column lists the families the case contributed entries to, with the case's entry count in parentheses.

| Label | Class | Job | Scale | Families (entry count) |
| --- | --- | --- | --- | --- |
| scripted-fidelity-review | Scripted | Check derived wiki pages against the source captures they cite, and fix what the sources settle. | 302 helpers in three completed launches of 185, 81, and 36 helpers, with harness token figures of 23.3M, 10.5M, and 2.6M. An earlier launch started 65 helpers before the user paused it after about 48 minutes, and an aborted relaunch killed 12 more. | 1, 6, 7, 10, 11, 13, 15, 17, 18, 22 (16) |
| scripted-prose-sweep-a | Scripted | Apply one style rule, covering dash removal and jargon, in place across about 160 markdown files while keeping meaning and length. | 272 helpers on 12.06M fresh tokens. | 2, 6, 7, 10, 11, 12, 13, 17, 18, 19 (17) |
| scripted-prose-sweep-b | Scripted | Apply one wording rule in place across about 80 files of a document tree that has a build step. | 170 helpers on 9.04M tokens. | 1, 2, 5, 7, 10, 11, 12, 16, 18, 20, 21 (16) |
| scripted-artifact-repair | Scripted | Repair drift across a task backlog, with repairs, new filings, and a review of task granularity. | 4 runs with 152 helpers in 102.5 minutes on 17.13M tokens, plus 11 one-off helpers. | 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 18, 23 (24) |
| scripted-check-only-audit | Scripted | Audit 30 instruction files against authoring rubrics without editing them, with one verifier per finding. | 19 helpers in 3.1 minutes on 1.5M tokens. | 4, 7, 10, 11, 15, 16, 18, 19, 20 (13) |
| scripted-design-panel | Scripted | Challenge a design that was built but not yet committed, through blind designers, judges, and refuters. | 10 helpers in 24.4 minutes on 1.38M tokens. | 1, 2, 4, 6, 10, 11, 19, 22 (15) |
| scripted-research-synthesis-a | Scripted | Research across a corpus, and merge the results into one task specification. | 16 helpers in 27.3 minutes on 2.68M tokens. | 1, 2, 4, 5, 6, 7, 11, 13, 15, 19 (15) |
| scripted-research-synthesis-b | Scripted | Study feasibility and draft a design over a large corpus. | 33 helpers on 4.81M tokens. | 1, 2, 3, 4, 5, 6, 11, 20, 21 (18) |
| scripted-disputed-claim | Scripted | Settle a figure that two passages disagree on, then edit. | 5 helpers in 7.0 minutes on about 455,000 tokens. | 2, 3, 4, 5, 7, 12, 15, 19, 22 (10) |
| doctrine-fidelity-review | Doctrine-attached | Do the same job as scripted-fidelity-review, from a near-identical prompt. | 1 agent of the owning skill family, for about 5 minutes. | 1, 2, 5, 8, 9, 11, 15, 18, 19, 21, 23 (13) |
| doctrine-multi-file-task | Doctrine-attached | Implement one task across many files: a mechanical rename plus semantic rewrites on each surface. | 1 background checker in a session of about 9 minutes. | 1, 4, 6, 9, 12, 13, 14, 15, 23 (14) |
| governed-readiness-loop-a | Governed | Run the readiness loop on one task file. | 16 helpers in 26 minutes. | 1, 2, 4, 5, 9, 10, 16 (12) |
| governed-readiness-loop-b | Governed | Run the readiness loop on one task file. | 25 helpers in 46 minutes, over 5 runs of the gate. | 2, 4, 6, 10, 16, 20, 22 (11) |
| governed-readiness-loop-c | Governed | Run the readiness loop on one task file. | 17 helpers in 24 minutes. | 1, 4, 10, 15, 16, 19, 21, 23 (10) |
| native-prose-sweep | Native prose | Rewrite contrastive negation across a markdown knowledge base while keeping meaning, in three passes over the whole tree. | 11 foreground writers in 70 minutes. | 1, 2, 5, 6, 9, 12, 13, 14, 18, 23 (16) |
| native-pointer-reconcile | Native prose | Reconcile knowledge-base pages against the code repositories they point at. | 3 background helpers over about 50 pages. | 1, 2, 5, 9, 11, 18 (12) |

### Failure families

The 23 families cover 150 of the 151 unrefuted failures and 82 of the 99 missed events. The one failure outside them is a misread of a work item's lifecycle, which lies outside orchestration. The 17 missed events outside them are observations, harness facts, notes about the case reports, one success counterexample, and duplicates of failures already counted. The table ranks the families by weighing severity, frequency, persistent damage, and how often the user had to act as checker.

Each row counts one family's entries. The Scripted column counts entries from the nine Claude Code sessions, and the Unscripted column counts entries from the seven Cursor sessions. Both columns count failures and missed events together. The High, Medium, and Low columns rate failures only, by severity, and the Missed events column counts the missed events. The Caught by column says who caught each entry. There, "user" counts catches by the user, in the session or in a repair session the user started later. "Later" counts catches by later rounds, audits, and sessions. The label "in-run" counts catches during the run by the orchestrator, a helper, or the host. "Never" counts entries that no pass or person caught as such. Most of those surfaced only in the retrospective. Later audits and user repair sessions surfaced the consequences of the five never-caught entries in family 9.

| # | Family | Scripted | Unscripted | High | Medium | Low | Missed events | Caught by | Doctrine |
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

The table holds 232 entries, 144 from scripted runs and 88 from unscripted runs. Its failures split into 17 high, 65 medium, and 68 low. Summed across families, the user caught 43 entries, later passes caught 22, and the run itself caught 30. The other 137 were never caught. The Doctrine column says how agent_spinner's rules relate to each family, with one of six values:

- **absent:** No rule exists for the family.
- **not-reached:** The rule exists, and the run never loaded it.
- **not-followed:** The rule was in the run's context, and the run ignored it.
- **needs-mechanism:** The rule cannot hold by instruction alone and needs a mechanism to carry it.
- **rule-causes:** An existing rule produces the failure, so the fix edits that rule.
- **mixed:** The family shows a combination of these.

No scripted session loaded agent_spinner. Seven of the nine ran before its release. The other two ran under the Workflow tool's own doctrine, and no load of agent_spinner was recorded. So the scripted sessions' failures show which rules the doctrine lacks. Among the unscripted runs, the three governed runs, governed-readiness-loop-a, governed-readiness-loop-b, and governed-readiness-loop-c, ran under task_auto_check's loop, where agent_spinner adds nothing by design. The two native prose runs, native-prose-sweep and native-pointer-reconcile, never loaded it. The two doctrine-attached runs, doctrine-fidelity-review and doctrine-multi-file-task, had its body attached and still broke its rules.

The adherence verdicts show which rules the two attached sessions broke. In both, the verdicts mark these rules as ignored or partly followed: width, checking, run state, the phase plan's bounds, and confirmation provenance. Width is how many helpers a run uses, and confirmation provenance records whether a confirmation came from recall or was surfaced independently. In doctrine-fidelity-review, the verdicts also mark delegation depth, which limits how deep helpers may delegate, and the skill's references as ignored. The multi-file run, doctrine-multi-file-task, followed delegation depth and has no verdict on the references. Those rules were in the runs' context, so the verdicts show that prose alone did not carry the doctrine. An unscripted tail is the work a session did after its scripted run ended. In those tails, the same Claude model reproduced the failure classes of the unscripted runs, once no script held the structure.

The doctrine text itself causes some failures, and the rule-causes value marks them. The settled-facts clause of prompt assembly, the doctrine's rules for building helper prompts, reproduces family 3. The checking block hands the checker the producer's report verbatim. That works against blind derivation, where a checker derives a claim without seeing the producer's answer, in families 4 and 22. The routing clause handed a run that explicitly asked for agent_spinner to the single agent of the skill family that owns the job, and that feeds family 9. Family 21 is a failure to follow rules already in context. The attached body stated every rule the run skipped, so mandatory reference loading alone would leave the defect in place.

### Base rates

Each row gives one measured rate, the cases behind it, and the caveat that limits it. A value marked (derived) was worked out from other entries rather than stated directly.

| Metric | Value | Cases | Caveat |
| --- | --- | --- | --- |
| First drafts of spec-like writes that fail a strict check | 6 of 12 task repairs carried a should-fix finding or worse, and so did 12 of 16 in a second set. 3 of 3 new filings failed, and 27 of 27 single-pass page rewrites were flagged. | scripted-artifact-repair and scripted-fidelity-review | Two scripted cases only. When any issue counts, 25 of 31 first-pass task writes came back flagged. The research plans one repair round for half to all first drafts. |
| Checker results compared with actual misses in mechanical sweeps | Checkers failed 4 of 97 files and 1 of about 80. Retrospective reads found target misses in at least 8 of about 80 files, about 9 percent. | scripted-prose-sweep-a and scripted-prose-sweep-b | Two sweeps only. The 8 of about 80 is a lower bound from retrospective reads, and no full re-check stands behind it. |
| Refutation rates by target and checker stance | Three refute-by-default runs refuted 0 of 148 finder findings, 1 of 8 audit findings, and 16 of 24 change proposals. Three seeded checkers refuted 0 of 3 on a hypothesis whose refutation condition covered one sub-claim. Six framing claims that the orchestrator wrote came back refuted, 6 of 6, each steered by its brief. Repairers rejected 0 of 258 review issues in a first round and 3 of 46 in a second round, and one of those 3 was a checker false positive. | scripted-fidelity-review for the finder findings and the review issues, scripted-check-only-audit for the audit findings, and scripted-disputed-claim for the seeded checkers. The evidence names no case for the change proposals or the framing claims. | The first three runs share one stance, so stance cannot explain why their rates differ. They also differ in target, prompt, checklist, and verdict options, and no run varied one of these alone. The repairer contrast is uncontrolled. No ledger shows that the first-round repairers lacked a confirm-first instruction, and they read sources with a median of 25 tool calls. |
| Checking's share of the token figures | In one sweep, the checkers took 37.5 percent of the harness token figure. Measured on summed transcript usage, they took about 20 percent of cache-inclusive context tokens and about 37 percent of output tokens. In another sweep, the verifiers took 33.0 percent of fresh tokens. | Two scripted sweeps that the evidence leaves unnamed | The harness figure measures context rather than spend ([Claude Code delegation surfaces](claude-delegation-surfaces.md)). Fresh tokens count input, cache creation, and output, and cache-inclusive context tokens add cache reads. A share therefore compares only with shares on the same basis. For the other runs, the ledgers give no share on a single basis. |
| Widths, the number of helpers per run | The median run used 36 helpers, the range was 5 to 260, and 14 of 15 runs used ten or more. | All nine scripted cases | Scripted runs on one host. The pool's observed limit on helpers running at once is a host fact, recorded on [Claude Code delegation surfaces](claude-delegation-surfaces.md). |
| Helper errors | 1 of 967 helpers ended in a terminal error. 2 of 967 returned hollow results that still passed the schema, and both were load-bearing and counted as successes. | All nine scripted cases | A hollow return counts only where a later read caught it, so 2 is a lower bound. |
| Self-reports against measurement | Measurement contradicted the dash counts of 4 of 97 writers (4.1 percent), the read claims of 3 of 11 reviewers (27 percent), and the fix counts of 26 of 78 writers (33 percent). | scripted-prose-sweep-a, scripted-check-only-audit, and scripted-prose-sweep-b, matched to the values by their counts (derived) | Three different measures from three runs, so the rates do not compare with each other. |
| Who caught the scripted runs' failures | Of 93 unrefuted failures in scripted runs, 39 percent went uncaught in the session. The user caught 28 percent, the orchestrator 13 percent, a helper or the host 12 percent, and a later round 9 percent. The user caught 6 of the 9 high-severity failures. In 8 of 9 sessions, a correct flag raised during the run never reached the user. | All nine scripted cases | This is the analyst's classification, which the evidence critic reproduced on the 93. Scripted runs only. |
| Failure mix | Among the 93 scripted-run failures, the largest class was misstatement in reports, with 18. Bugs in orchestration scripts and lenient verification followed with 14 each, then lost context with 11. Wrong counts reached the user in at least 6 of 9 sessions. | All nine scripted cases | The class is each entry's own label, separate from the 23 families. All 14 script bugs come from scripted cases, so scripts bring defects of their own. The session figure is a lower bound. |
| Cost stops | The user stopped 2 of 9 scripted sessions because of cost. | scripted-fidelity-review and scripted-prose-sweep-a | Nine sessions. One stop followed a widening made with no estimate. The other followed a launch that sent every finding to verification beyond a size guideline it never named. |
| Adherence with the body attached | In the fidelity review, 1 of 21 doctrine verdicts was followed, with 8 ignored, 9 partial, and 3 not applicable. In the multi-file implementation, 2 of 21 were followed, with 3 ignored, 14 partial, and 2 not applicable. | doctrine-fidelity-review and doctrine-multi-file-task | Two sessions on one host. The checker confirmed 36 of the 42 verdicts and narrowed 6. |

### Mechanisms observed together

Scripts made six properties cheap to build into a run. The number of helpers equals the length of an enumerated list. Returns are checked before they count. Joins match results by identity. Counts are computed from records. The verdict waits for every checker. Every landed write, a change already applied to a file, gets a review against a recorded baseline. Runs that built these in avoided the unscripted runs' failures, and scripted runs that left one out failed in families 1, 7, and 18. Three failures occurred even under scripts. Helpers returned hollow results that still passed the schema, joins matched results by index or by a shared label, and an integrator's writes went unreviewed. The first two appear only in scripted runs, because family 7 has no unscripted entry. The third appears in both kinds of run, as the members of family 1 show.

In the pairs of runs the research selected, the catches came from narrowing, cited clears, and a checker role able to review, working together with three mechanisms. Narrowing means a checker cuts an overstated finding down to what holds, and a cited clear is a pass that cites the evidence that settled it.

- **Coverage by construction, plus one read-only review of every written file.** In scripted-fidelity-review, one reviewer per page diff raised 258 page issues. In scripted-artifact-repair, one refute-by-default checker per repair, working from a closed checklist, raised 113 repair issues. No unscripted run had an independent pass read an applied diff for meaning against its baseline.
- **Deterministic commands against a recorded baseline.** Commands with fixed, repeatable results carried the sweeps' safety claims. They showed 97 blocking findings that predated scripted-prose-sweep-b and measured the change in requirement words over 100 files. A baseline build settled a suspected regression, and a linter caught a problem in a file no reviewer saw. A gate, an automated check that passes or fails, carries such a claim only where its executable resolved and its expected result held. Commands run on 27 September 2026 show why ([host observations](../raw/notes/agent-delegation-host-observations-2026-09.md)). On a clean file, markdownlint, `jq empty`, and shellcheck each exit 0 with no output, so a rule that fails on empty output would record every clean pass as a failed probe. A ripgrep search found nothing inside a directory whose own `.gitignore` holds `*`, until the search named the file's explicit path. One host's shell grep behaves the same way ([Claude Code delegation surfaces](claude-delegation-surfaces.md)). The planned ledger therefore plants a known positive, an item a working gate reports, in its run directory at `init`, when it opens the run. It then records which gates report it. A plain `git status` writes the index unless it runs with `--no-optional-locks`. Running it with `-c status.showUntrackedFiles=no` hides untracked files until `--untracked-files=all` lists them again. The hardened git reads of P1, the step that opens the run, account for both.
- **Checker stance, with narrowing and cited clears.** The fidelity lenses, checkers that each worked from one angle, refuted none of the 148 findings they verified. Yet each rated 59 of its 154 verification events partly true, and the planner prompt said such a correction overrides the finding. In scripted-prose-sweep-b, nearly all per-file checkers returned bare passes with no citation. Their role's contract disclaims review, and their schema let a pass go uncited. In scripted-prose-sweep-a, per-file adversarial checkers caught all 4 writers that falsely reported zero, with no false positives.

These mechanisms occurred together, and no run varied one alone, so the evidence ranks none of them. Refutation counts alone say little. The paired sweeps were also narrower asks than the negation rewrite in native-prose-sweep that they are compared with.

The proposal of 27 September 2026 answers the families with three layers, which ship in this order. First comes a run ledger, a Python script bundled with the skill that uses only the standard library. It dispatches nothing, and it refuses to close a run while any unit of work, record, fork, or landed write is unaccounted for. A fork is an open decision that belongs to the user. Second, body blocks in agent_spinner's SKILL.md put each broken rule at the point of decision and cite the ledger. Third, one recipe per job class gives each kind of run its procedure. The body rewrite and the recipes are untested hypotheses. Their evals measure adherence to a rule, and none measures the act of reading. The ledger carries the refusals that can be enforced, and they bind only when the orchestrator calls it. A report on a run that the ledger did not close cleanly therefore says so in its opening sentence.

Three of those refusals answer failures the scripted runs had too, and each has a planned script test. The verbs below are the ledger's commands, and their names were provisional when the proposal closed. First, `accept` rejects a placeholder value and a list that falls short of its row's obligations, and `brief` refuses to relay a return that was never accepted. Second, `init` and `rows` refuse duplicate slugs, the short item identifiers, and slugs that differ only in letter case, and every join reads identifiers only. Third, `diff --add-checks` builds check rows from the measured diff, whoever wrote it, and `close` refuses a changed path with no accepted check from another row.

### Recipes and step map

The proposal assigns families to its run-protocol steps, its checks, and its ledger verbs. A recipe combines those entries for one job class. The recipe table therefore lists the families seen in each recipe's grounding cases, which the research derived from the case register. Its Shape column names how the recipe arranges its helpers.

| Recipe | Shape | Grounding cases | Families seen in grounding cases (derived) |
| --- | --- | --- | --- |
| J1 Source-fidelity review and fix | Per-artifact fan-out | scripted-fidelity-review, doctrine-fidelity-review, and native-pointer-reconcile | 1, 2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 18, 19, 21, 22, 23 |
| J2 Meaning-preserving prose sweep | Per-artifact fan-out | scripted-prose-sweep-a, scripted-prose-sweep-b, and native-prose-sweep | 1, 2, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23 |
| J3 Multi-file task implementation | Per-artifact fan-out | doctrine-multi-file-task, with scripted-prose-sweep-b and the first run of scripted-artifact-repair as scripted runs to compare against | 1, 4, 6, 9, 12, 13, 14, 15, 23, from doctrine-multi-file-task alone |
| J4 Drift repair across many artifacts | Per-artifact fan-out | scripted-artifact-repair, governed-readiness-loop-a, governed-readiness-loop-b, and governed-readiness-loop-c | Every family except 14 and 17 |
| J5 Design option panel | Lens panel, or the paired refute-by-default check for a challenged build | scripted-design-panel, with parts of scripted-research-synthesis-a and scripted-research-synthesis-b | 1, 2, 4, 6, 10, 11, 19, 22, from scripted-design-panel alone |
| J6 Understand-then-synthesize research | Lens panel | scripted-research-synthesis-a and scripted-research-synthesis-b | 1, 2, 3, 4, 5, 6, 7, 11, 13, 15, 19, 20, 21 |
| J7 Check-only audit sweep | Per-artifact fan-out | scripted-check-only-audit | 4, 7, 10, 11, 15, 16, 18, 19, 20 |
| J8 Disputed-claim settlement | Paired refute-by-default check | scripted-disputed-claim | 2, 3, 4, 5, 7, 12, 15, 19, 22 |

The step table has one row for each run-protocol step, P1 to P6, and for each check, C1 to C10. Families answered gives the families the proposal assigns to the row, and Basis lists every case that carries one of those families. The Proposal column names any part of the step that goes beyond the evidence or waits on an owner decision, and reads None where no part does.

| Step | Families answered | Basis | Proposal |
| --- | --- | --- | --- |
| P1 Open the run | 9 | doctrine-fidelity-review, doctrine-multi-file-task, governed-readiness-loop-a, native-prose-sweep, and native-pointer-reconcile | None |
| P2 Render every brief from files | None named; C2's blind pass and C3's verbatim hand-off depend on it | Through C2 and C3, every case but doctrine-fidelity-review, native-prose-sweep, and native-pointer-reconcile (derived) | None |
| P3 Return files and the acceptance gate | 2, 7 | Every case but doctrine-multi-file-task and governed-readiness-loop-c | None |
| P4 Completion, waves, stop and resume | 13 | scripted-fidelity-review, scripted-prose-sweep-a, scripted-artifact-repair, scripted-research-synthesis-a, doctrine-multi-file-task, and native-prose-sweep | None |
| P5 Keep shared state still | 6 | scripted-fidelity-review, scripted-prose-sweep-a, scripted-artifact-repair, scripted-design-panel, scripted-research-synthesis-a, scripted-research-synthesis-b, doctrine-multi-file-task, governed-readiness-loop-b, and native-prose-sweep | None |
| P6 The findings ledger, decision packets and the report | 2, 11 | Every case but doctrine-multi-file-task and governed-readiness-loop-c | None |
| C1 Check every landed write | 1 | Every case but scripted-prose-sweep-a, scripted-check-only-audit, scripted-disputed-claim, and governed-readiness-loop-b | None |
| C2 Build a clean checker | 4 | scripted-artifact-repair, scripted-check-only-audit, scripted-design-panel, scripted-research-synthesis-a, scripted-research-synthesis-b, scripted-disputed-claim, doctrine-multi-file-task, governed-readiness-loop-a, governed-readiness-loop-b, and governed-readiness-loop-c | None |
| C3 Hand off verbatim and unsteered | 10 | scripted-fidelity-review, scripted-prose-sweep-a, scripted-prose-sweep-b, scripted-check-only-audit, scripted-design-panel, governed-readiness-loop-a, governed-readiness-loop-b, and governed-readiness-loop-c | None |
| C4 Run deterministic gates against the baseline, with positive controls | 12, 19 | scripted-prose-sweep-a, scripted-prose-sweep-b, scripted-artifact-repair, scripted-check-only-audit, scripted-design-panel, scripted-research-synthesis-a, scripted-disputed-claim, doctrine-fidelity-review, doctrine-multi-file-task, governed-readiness-loop-c, and native-prose-sweep | None |
| C5 One repair round with one re-check | 20 | scripted-prose-sweep-b, scripted-check-only-audit, scripted-research-synthesis-b, and governed-readiness-loop-b | The re-check rests on an owner decision |
| C6 Aim critics at the run's own conclusions | 20 | scripted-prose-sweep-b, scripted-check-only-audit, scripted-research-synthesis-b, and governed-readiness-loop-b | The surplus read paired with every completeness critic |
| C7 Set verification scope, depth and calibration | None named; its depth flag and recall label serve families 15 and 22 (derived) | scripted-fidelity-review, scripted-check-only-audit, scripted-design-panel, scripted-research-synthesis-a, scripted-disputed-claim, doctrine-fidelity-review, doctrine-multi-file-task, governed-readiness-loop-b, and governed-readiness-loop-c (derived) | None |
| C8 Sweep residuals and classes, and check receipts | 16, 20 | scripted-prose-sweep-b, scripted-check-only-audit, scripted-research-synthesis-b, governed-readiness-loop-a, governed-readiness-loop-b, and governed-readiness-loop-c | None |
| C9 Hand stamps, completed artifacts and markers to their owners | 8 | scripted-artifact-repair and doctrine-fidelity-review | None |
| C10 Tier the evidence and keep weak claims conditional | 3 | scripted-artifact-repair, scripted-research-synthesis-b, and scripted-disputed-claim | None |

Eight families have no run-protocol or check entry. Body blocks and ledger verbs alone answer them.

- The judgement block answers family 5 with decision packets, and it counts an answer that the request states as the user's. The ledger refuses to close while a fork is open.
- Prompt assembly answers family 14 by keeping pointers apart from claims, and an edit-mechanics reference adds a wrap-seam gate.
- Ledger rows for planned and mandated steps answer family 15. A path counts as read only on tool evidence of a full read, and at close the ledger flags every checker shallower than its producer.
- The phase plan answers family 17. It requires an estimate, treats widening as a fork, writes in waves, and uses a stop file that gives a real pause.
- The ledger answers family 18 by printing every number and checking the tally at close.
- Orient rows and the recipe read stay in the body rewrite as hypotheses for family 21. The guarantee for that family rests on the ledger's refusals.
- The checking block answers family 22 with a blind derivation of the claim a verdict rests on. The ledger tags each confirmation as recall-confirmed or independently surfaced.
- A claim-type rule in the checking block answers family 23. It bars a count or presence check from clearing a claim about content.

## Open questions

- The sample is small and selected, and it comes from one owner's repositories. Several figures are analyst tallies that no checker verified, so every rate here is provisional.
- The effect of each proposed recipe and step stays unmeasured until their evals and later runs measure it. Those evals measure adherence to a rule rather than the act of reading.
- Which mechanism carries the catches stays open, because the mechanisms occurred together and no run varied one alone.
- Whether the ledger binds in practice is open. Its refusals bind only when the orchestrator calls `init` and `close`, and the evidence shows orchestrators skipping mandated tool runs without saying so.
- How much of the gap between scripted and unscripted runs comes from the host is open, because run class and host coincide in this sample.
- What drives the spread in refutation rates is open, because target, prompt, checklist, and verdict options all varied together.
- How many hollow returns and false self-reports went uncaught is open, because the measured rates are lower bounds.
- What a checker on a different model adds is unmeasured, because no run gave the producer and the checker different models.
- Whether a planned session boundary at half the host's context window helps wide runs is open. The evidence shows the context pressure, and the threshold itself goes beyond the evidence.

## Related concepts

- [Agent-delegated automation](agent-delegated-automation.md), for the delegation pattern that agent_spinner ships in a general, harness-independent form and that the proposed recipes would extend.
- [Instruction-defect classes](instruction-defect-classes.md), for why a rule in context can still misfire at runtime and why a property that must hold needs a mechanism. The not-followed and needs-mechanism values echo both points.
- [Verification surfaces for a shipped skill](verification-surfaces.md), for the behavioural evals that would measure adherence to the proposed recipes, and for what such a result can show.

## Derived from

- A private research archive drawn from observed orchestration sessions. It holds per-case transcript digests, checked case ledgers, and a research write-up with its merged proposal. Its owner keeps it outside this public repository, and the raw notes this page cites anonymize it.
