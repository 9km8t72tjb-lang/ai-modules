---
description: Settle wiki log entries at commit and fold open follow-ups, log no clean lint run while audits keep theirs, keep session detail out of the wiki, and reach wikis via wiki_fix.
scope: plugins/knowledge_management
created: 2026-08-20T17:09:44
updated: 2026-09-25T23:42:48
status: checked
reported-by: Andreas Hoffmann
---

# Record net changes in the wiki log, and keep session detail out of the wiki

## Goal

Every wiki this skill family scaffolds or maintains holds durable content and net changes. Three rules carry that, and each reaches existing wikis through `wiki_fix`.

- **An entry settles at commit.** A `log.md` entry that the last commit already contains is settled, and append-only protects it. An entry the working tree adds is still open. A later edit that corrects or refines the same work folds into the open entry instead of adding one of its own. Work that no commit ships, such as a block deleted and then restored, leaves no entry. In a wiki outside version control, an entry settles when the session that wrote it ends.
- **A lint run is logged only when it changes files.** A clean lint run writes no entry. An audit run stays the one zero-change exception, because its entry carries the baseline the next audit scopes from.
- **Session detail stays out of the wiki.** Pages, raw sidecars and log entries record what the wiki holds and what changed in it. The session that produced a change stays out. That covers who asked for what, drafts that were replaced, and corrections made before the work was committed. A clarification given in the same session lands in the text it clarifies. Knowledge a session produced is content. A position that changed between dated sources stays on record, as the update policy already requires.

An owner then sees one entry for a change that was corrected before its commit, and that entry describes what the commit ships. A clean lint pass leaves `log.md` unchanged. No page or sidecar retells the conversation that wrote it.

## Context

The log rules live in these canonical surfaces under `plugins/knowledge_management`. At implementation time, `rg -in 'process record|append the outcome|lint and audit|append-only' plugins/knowledge_management` lists every current site.

- The `skills/wiki/references/template_log.md` preamble opens `Chronological record of wiki changes. Append-only.` Its `Entries:` group says an operation that creates or updates wiki files `appends one entry` and that `Lint and audit runs are the exception.` Its `Repair:` group says `never reword, reorder, or delete what a past entry records`, with a carve-out for repairing a structural or lint break an entry introduced. Its `Body:` group lists only changed files and says nothing about session detail.
- The `## Conventions` bullet in `skills/wiki/references/template_schema.md` led by `Append every operation that creates or updates wiki files` excepts `lint and audit runs` as process records.
- `skills/wiki/SKILL.md` states the absolute form in the `<architecture>` diagram annotation `append-only in substance, rotated yearly`, in the paragraph led by `**The log is append-only in substance.**`, and in `<appending_to_log>`. That block opens with `**An entry records a change.**` and keeps `Lint and audit runs are the one exception`. The `<log_only_what_changed>` pitfall repeats the exception. `<inline_iteration_loop>` says `Append the outcome to` the log. The `<update_navigation>` line naming the `ingest | Source Title` heading and the `<query>` step led by `log entry when the query changed files` each append one entry per operation.
- The `## Iteration loop` section of `skills/wiki/references/lint_checks.md` also says `Append the outcome to` the log.
- In `agents/auto_shaper_wiki.md`, `<append_audit_log_entry>` writes a zero-change `audit` entry whose `Audit baseline:` line the next audit reads to scope its page walk. That makes the audit exception load-bearing. No later run reads a clean lint entry.

Nothing addresses session detail. `<capture_raw_source>` asks the sidecar of a local source to `note its locality in prose`. That note stays, because it describes the source and leaves the session out.

Propagation rides the agent's scaffold-drift path. The linter's `boilerplate` check compares the `log.md` preamble with `template_log.md`, and `<fix_log_preamble_drift>` writes the current text for a replaced canonical unit. Every new preamble line must sit above the first `## [` heading, or this path cannot carry it. Under `<hunk_classification>`, a bullet that `template_schema.md` has and a wiki's `SCHEMA.md` lacks is drift the remediate phase adds, and a wiki bullet that contradicts the canonical one is surfaced for the owner. The rules in `SKILL.md` and the agent reach every wiki once the skill is deployed.

The failure was observed in a downstream wiki. One session ingested an operator note and then corrected the capture twice. Before any commit, the log held four entries for that one piece of work: the ingest, a refinement of the same capture, and two clean lint runs. The raw sidecar and a page also retold the conversation. The owner's correction was that only changes that change something belong in the wiki, and nothing transient. The same owner had asked earlier that the log record what a commit ships and leave out transitions no commit reflects. That wiki now carries all three rules in its own schema and log preamble.

## Approach

1. **Rewrite the canonical preamble.** In `template_log.md`, rewrite the opening `Append-only.` so it applies to settled entries. Rewrite `Entries:` in place to carry the first two rules from `## Goal`. One open entry covers one work unit, meaning one subject or change set, so unrelated work in the same uncommitted span keeps separate entries. A lint run that changes files records a `lint` entry listing them. Name the failure in one clause: an entry per edit or per clean check turns the log into a record of transitions instead of a record of what shipped. Rewrite `Repair:` so settlement and the repair carve-out read as one qualification. A settled entry keeps its substance, an open entry takes folds, and any entry may be repaired for a break it introduced. Extend `Body:` with the log half of the session-detail rule. Add no group beside `Entries:`.
2. **Carry the rules in the base skill.** In `SKILL.md`, rewrite `<appending_to_log>` so it records net changes, scopes append-only to settled entries, and names folding as the second path beside a new entry. Say how to tell an open entry from a settled one: in a git-backed wiki, `git diff HEAD -- log.md` shows the open entry lines. Narrow the exception to audit runs, and point at the preamble instead of restating it. Keep newest-at-bottom, `**Anchor on the previous entry's last body line**`, cluster ordering and the post-edit `grep -n '^## \['` check as the mechanics of a new entry. Rewrite the `<architecture>` annotation and the `**The log is append-only in substance.**` paragraph to the settled-entry scope. Make the `<update_navigation>` ingest line and the `<query>` log step record into the open entry for their work unit, appending only when none is open. Condition the `<inline_iteration_loop>` outcome entry on changed files, and narrow `<log_only_what_changed>` to the audit exception.
3. **State the session-detail rule once.** Add it to `SKILL.md` as its own block inside `<operational_discipline>`, carrying the third rule from `## Goal`. Point at that block from `<write_or_update_pages>`, from the `note its locality in prose` clause of `<capture_raw_source>`, and from `<appending_to_log>`, without restating it.
4. **Mirror the rules in the schema template.** In the `template_schema.md` `## Conventions` section, rewrite the log bullet to the settled-entry and lint-run rules, pointing at the preamble. Add one bullet for the session-detail rule beside it. These are the texts `<hunk_classification>` compares an existing wiki's `SCHEMA.md` against.
5. **Align the lint reference.** In the `lint_checks.md` `## Iteration loop` section, log the outcome only when the run changed files.
6. **Reconcile the agent.** In `auto_shaper_wiki.md`, keep `<append_audit_log_entry>` and its baseline as the audit exception. Reword the `The log is append-only in substance` sentence that cites `<configurable_zones>` so it protects settled entries. Point the agent's page and log writes at the new `SKILL.md` block. The agent needs no fold move, because an audit writes one entry per run.

**Out of scope:**

- A lint check for clean lint entries or unfolded entries. Every existing wiki holds settled clean-lint entries that append-only keeps, so the check would fire on history nobody may rewrite, and folding is an authoring judgement the committed file does not record.
- Rewriting settled entries in any existing wiki, which stays the owner's editorial call.
- A behavioural eval proving an agent folds entries and skips clean lint runs, owned by [tests_wiki-front-end-behavior-evals.md](tests_wiki-front-end-behavior-evals.md).
- The post-approval append steps in `wiki_import` and `wiki_wrapup`. Each writes one entry per approved work unit, which the fold rule keeps as a new entry.
- Page-convention and lint-sanction prose in page bodies, owned by [wiki_meta-prose-in-page-bodies.md](wiki_meta-prose-in-page-bodies.md). Both tasks add a page-body rule to `SKILL.md`, to the schema template's `## Conventions` and to the agent's `<remediate>`, so the task that lands second composes its rule beside the first.

## Acceptance

- `rg -in "reword, reorder, or delete what a past entry records" plugins/knowledge_management` returns no match. The preamble's `Repair:` group, the `<architecture>` paragraph and `<appending_to_log>` each scope append-only to settled entries and keep the repair carve-out in the same qualification.
- `rg -in "lint and audit" plugins/knowledge_management` returns no match, and every remaining `process record` match names the audit run.
- The preamble's `Entries:` group states settlement at commit, one open entry per work unit, folding, no entry for work no commit ships, no entry for an operation that changes no file, a `lint` entry only for a run that changed files, the audit exception with its baseline reason, the named failure, and the session boundary for a wiki outside version control. No other group restates it, and every preamble line sits above the first `## [` heading.
- The preamble's `Body:` group tells an entry to leave out the session that produced it.
- `<appending_to_log>` names `git diff HEAD -- log.md` as the open-entry test and keeps the new-entry mechanics that **Carry the rules in the base skill.** names beside the fold path.
- The `<update_navigation>` ingest line and the `<query>` log step record into the open work-unit entry and still write nothing when nothing changed.
- `rg -in "append the outcome to" plugins/knowledge_management/skills/wiki` returns no unconditional form, and both `<inline_iteration_loop>` and the `lint_checks.md` `## Iteration loop` section condition the entry on changed files.
- `<log_only_what_changed>` names the audit run as the only zero-change exception.
- The session-detail rule appears once in `SKILL.md`, as its own block in `<operational_discipline>`. `<write_or_update_pages>`, `<capture_raw_source>` and `<appending_to_log>` each point at it, and a grep for the block's lead sentence finds that one statement plus its mirror in `template_schema.md`.
- The `template_schema.md` `## Conventions` section carries the rewritten log bullet, pointing at the preamble, and the session-detail bullet. No bullet there excepts lint runs.
- `auto_shaper_wiki.md` keeps the zero-change entry of `<append_audit_log_entry>`, points its writes at the session-detail block, and asserts immutability only for settled entries.
- Layer 1: a scaffold scenario in the `tests/wiki/` script harness proves a freshly scaffolded wiki carries the new preamble and both new schema bullets verbatim. The default `tests/wiki/run_all.sh` run exercises it and passes.
- Layer 2: a scenario is registered in `tests/wiki/layer2/evals.json` and staged by `tests/wiki/layer2/setup_scenarios.sh` on the sibling `AS-*` pattern, with `skill_name: wiki_fix`, out-of-band grading and a top-level `passes` denominator. Its fixture wiki predates the rules. It carries the old preamble, a `SCHEMA.md` log bullet that excepts lint runs, no session-detail bullet, and no `Declared boilerplate:` bullet for the preamble. After `wiki_fix`, assertions prove the preamble carries the rewritten groups and `SCHEMA.md` carries the session-detail bullet. They also prove the lint exception was either rewritten or named in the run's report as a contradiction for the owner. The scenario runs against the rewritten agent as the harness resolves it, since the runner loads the deployed agent copy. It reaches the all-passes result across its `passes` denominator, and the graded run is recorded under `tests/wiki/layer2/workspace/`. When it misses that bar, the report records the measured rate and the diverging assertions and hands the disposition to the user. `tests/wiki/run_all.sh --layer2` is the runner.
