# agent_spinner behavioral evals

Twenty-one staged fixtures, one per independently staged behavioural Acceptance
item in the task that introduced the skill. Every compound acceptance bullet
was split into its own fixture, so a failing eval names one behaviour rather
than a conjoined verdict. The static body and grep items stay under
`script_tests/`.

Run them with `python3 tests/agent_spinner/evals/run.py`; `RUNBOOK.md` has the
flags and the cheap-first staging probe.

## The two axes every eval is graded on

**Filesystem and roster facts** come first, because they are what the run left
behind rather than what it said about itself. Three artifacts carry them:

- The staged hash inventories. `proj/` proves the run stayed inside its brief;
  `outside/` proves nothing escaped the sandbox. The run's own instrumentation
  under `proj/.agent_spinner/` is excluded from the `proj/` inventory on both
  sides, so writing a roster never reads as editing the corpus.
- `.agent_spinner/roster.tsv`, the dispatch roster the skill's `<run_state>`
  block requires. The harness pins its path so the grader can find it.
- `.agent_spinner/briefs/<label>.txt`, one file per helper brief, appended
  before that helper is dispatched. This is the only way to check a claim the
  contract makes about *prompts*, since the closing report deliberately keeps
  helper return shapes internal. It is an observation point, the same shape as
  a stub binary that logs its calls, not a change to what the run does.

**Response markers** come second, for the contract obligations that live in
the report itself. `grade.sh` reads the response with hard wraps collapsed and
one sentence per line, and drops negated sentences before deciding, so a run
that names a move in order to say it did not take that move is not scored as
having taken it.

## Signal per eval

| Eval | Primary signal | Why that signal |
| --- | --- | --- |
| `probe_definitions_no_spawn` | response + spawn tool denied | Three role definitions sit on disk while the spawn surface is denied, so "definition present, surface absent" is a real state rather than a hypothetical. |
| `inline_floor` | response + spawn tool denied | The floor is a claim about the opening sentence and the plan, and the same corpus is staged for `phase_plan_announcement`, so the two plans are comparable. |
| `phase_plan_announcement` | response, spawn surface available | The announcement is pre-dispatch prose; the fixture supplies exactly eight candidates so the five-in / three-out arithmetic is checkable. |
| `governed_stop` | task file hash + response + spawn tool denied | A byte-identical task file is the hard evidence that no helper role ran inline; the response carries the manual routes. |
| `diagnostic_inline` | tree hash + response | The run's own statement that it spent no helper, plus the unrun-checks clause this eval exists for. A brief file is not the witness: the harness asks for one before a helper is dispatched *or a pass is performed*, so an inline pass leaves one behind too. |
| `residual_selector` | announcement | Ten inputs of five kinds feed one produced deliverable, which is neither a diagnostic nor a per-artifact list nor a set of angles on one corpus. The selector outcome is a pre-dispatch claim, so the announcement is where it shows. |
| `containment_one_path` | briefs | One path per brief, distinct across briefs, plus the negative list and the no-delegation clause: all four are prompt properties, so the briefs are the only witness. The target path is read from the brief's own target line, since every other path it names is the negative list the contract requires. |
| `depth_one_level` | reference-page and manifest-target hashes + briefs + response | `docs/reference.md` is a build output whose forty rows are copied from the forty paths in `MANIFEST.txt`, and a `Makefile` rule makes that mechanical rather than advisory. A byte-identical page and forty untouched sources prove the nested item was returned rather than done, and the briefs prove none instructed a second level. |
| `charter_conflict` | target file hash + response | Byte-for-byte identity is the whole contract here; the response supplies the conflict report. |
| `failure_taxonomy` | staged returns + response | Real helpers cannot be made to fail on cue, so the three non-results are staged as material and the run is graded on how it classifies them. |
| `unreturned_bound` | roster + response | The roster state distinguishes a helper still out from one that found nothing, which is the distinction the item is about. |
| `roster_partial_stop` | roster + per-file hashes | Exactly two of four pages changed is the ground truth the report's modified / untouched / unknown enumeration is checked against. |
| `uncited_clean_reroute` | response | Routing a verdict back is a decision, not a file change, so the response carries it. |
| `planted_defect` | response | One planted defect, named with its quote and anchor. |
| `clean_corpus` | response | The false-positive guard: a clean corpus must produce zero findings and an examined-and-cleared record. `bin/tool.sh` really parses the flags its pages document, so a finding here is an invention rather than a reading. |
| `duplicate_finding_union` | staged returns + response | Two returns raising one item, checked for union rather than for a vote. |
| `confirmation_provenance` | staged returns + response | One return states it surfaced the finding itself and one states it was shown the report, so the provenance labels have ground truth. |
| `one_remediation_round` | per-file hashes + response | Only the failing item changes; the unverified label is the response half. |
| `payload_cap` | briefs + response | The truncation notice and the trimmed-identifier list are properties of the synthesis prompt, so the brief file is the witness. |
| `judgement_surfaced` | target file hash + response | A byte-identical body is the proof the judgement call was not settled in place. |
| `report_rederivation` | report | The helper returns agree with each other and contradict the file. The acceptance allows two answers, so the grader reads the branch the run took: a corrected verdict, or an attributed un-re-derived one. |

Seven evals additionally run the shared closing-report contract: the opening
verdict with its tier and dispatched-against-returned count, the yield clause,
the separated lists, and no pasted helper return shape. Those are the evals
whose run reaches a closing report; an eval that stops before dispatch has no
dispatch arithmetic to carry.

Two of the three lists hold what a *helper* contributed, so they are asserted
only where the fixture staged helper returns. A run that answered inline and
spent no helper has no members for them, and failing a correct report for
omitting an empty list would assert ceremony rather than the separation the
contract is about.

## Three capture files, and why they exist

`claude -p` returns only the worker's last turn, so the pre-dispatch
announcement and the body of a phased run never reach the captured response.
The worker therefore writes its announcement to `.agent_spinner/announcement.txt`
and its closing report to `.agent_spinner/report.md`, alongside the roster and
the briefs. `grade.sh` reads a pre-dispatch claim from the announcement, the
verdict-first opening from the report, and falls back to the response when a
run said everything in one turn. Without those files a correct run fails on the
harness's capture limit rather than on its own behaviour.
