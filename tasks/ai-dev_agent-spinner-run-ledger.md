---
description: Bundle scripts/run_ledger.py in agent_spinner, a stdlib ledger that keeps a run's accounts and launches nothing, with its script tests, static-check and grader fixes, lint prune, and doc updates.
scope: plugins/ai_dev/skills/agent_spinner
created: 2026-10-03T15:54:08
updated: 2026-10-03T15:54:08
status: open
reported-by: Andreas Hoffmann
---

# Bundle the run ledger in agent_spinner

## Goal

An orchestrator running agent_spinner keeps a run's accounts on disk through one bundled program, `scripts/run_ledger.py`, instead of holding them in its own context. The ledger refuses to close a run while any unit, returned record, fork, or landed write is unaccounted for. Each omission that used to fail silently therefore becomes a non-zero exit. The ledger records the spawns the orchestrator makes and launches nothing itself.

The program ships proven by its own script tests. The skill's static contract, one eval grader, the repository's lint scope, the harness docs, and the wiki concept page all describe a skill that now bundles one program.

## Context

The owner approved bundling the ledger on 2026-10-03. That decision reverses two items of [the archived agent_spinner task](archive/ai-dev_agent-spinner-skill.md) for this one script: the Goal sentence "Ship it prose-only", and the Out of scope item "A bundled runtime script, workflow runner, or scheduler, which the standing repo rules keep out of the toolchain". The workflow-runner and scheduler exclusions stay in force inside agent_spinner. The archived task stays unedited as the decision record. Its stated reason no longer holds, because the standing repo rules and `CHARTER.md` now accept Python 3 as a standing dependency and place a skill's helper script inside the skill under `scripts/`.

The owner approved three further rules the same day, and this task implements them in code:

- The run directory is `.agent_spinner/` in the working root, hidden from git by its own `.gitignore` holding `*`. A gate-scope check runs through planted known positives, an auto-fix gate is refused while run state exists, the directory is queried only through the ledger, and this repository's Makefile `EXCLUDE` gains a prune for it.
- Read snapshots are file copies under the run directory. The run writes no ref, tree, commit, or object into the user's repository.
- Each repaired item gets one re-check at no lower depth than its first check, with no second repair round. `dispatch` enforces the counting half of that rule.

The case for a mechanism comes from observed orchestration runs. Scripted runs that encoded six properties avoided the failures that prose-only runs had: width equal to an enumerated list, returns checked before they count, joins by identity, counts computed from records, a verdict that waits for every checker, and a review of every landed write against a recorded baseline. Scripted runs that left one property out failed the same way. Three failures hit both kinds of run, and each gets a refusal with its own script test: schema-valid hollow returns, joins by index or by a shared label, and integrator writes nobody reviewed. The directory sits in the working root because helpers can write there under the host's write scope, it survives reboots and temp cleaning, and searches outside the workspace can be silently re-scoped. Ignore-honouring search tools skip a directory whose own `.gitignore` holds `*`, which is why queries go through the ledger. Gates that list files themselves still see it, which is why the gate-scope check exists.

Current state, verified on 2026-10-03:

- `plugins/ai_dev/skills/agent_spinner/` holds `SKILL.md` at version 1.0.1 and `references/`, and no `scripts/`.
- `bash tests/agent_spinner/script_tests/run.sh` reports 119 passed and 1 failed. The failing check, labelled "frontmatter version: 1.0.0", pins `^version: 1\.0\.0$`. The check labelled "the skill bundles no runtime scripts" asserts that `scripts/` is absent. The greps behind "no per-harness frontmatter keys or tool identifiers", "no harness agent directory paths", "no sandbox mode values", "every target product name cites harness_portability", and "no instruction to write a global rules or agent-config file" recurse through the whole skill directory case-insensitively, so they will scan the ledger too.
- In `tests/agent_spinner/evals/grade.sh`, `PHASE_PLAN='phase|pass 1|phases:'` passes on any mention of a phase. The inline_floor and phase_plan_announcement evals both expect a plan of two to four named phases, which `<phase_plan>` in `SKILL.md` requires today.
- The Makefile builds `MD_FILES`, `JSON_FILES`, and `SH_FILES` with `find .` under `EXCLUDE`, which prunes no `.agent_spinner`, and `fix-md` runs `markdownlint --fix` over `MD_FILES`. The comment above `EXCLUDE` says its prunes mirror `tests/.gitignore`, and the standing repo rules change the two lists together so lint scope matches git scope. `lint-sh` already enforces the bash 3.2 construct floor over every shell file in scope.
- `WORKER_PROMPT` in `tests/agent_spinner/evals/run.py` asks the worker to keep `announcement.txt`, `roster.tsv`, `briefs/<label>.txt`, and `report.md` under `.agent_spinner/`. The ledger keeps those paths, so the runner's prompt and state paths stay unchanged.
- [tests_agent-spinner-runner-modes](tests_agent-spinner-runner-modes.md) edits the same agent_spinner row in `tests/CLAUDE.md` and the same agent_spinner bullet in `tests/README.md`. This task rewrites the clause calling the skill prose-only, and that task rewrites the clause about denying the spawn tool.

## Approach

Write `plugins/ai_dev/skills/agent_spinner/scripts/run_ledger.py` as one file that imports only the standard library and needs Python 3.9 or newer. Every verb works on `.agent_spinner/` under its current directory, which is the working root. The program holds no per-harness fact: anything specific to a host, such as a host log path or a wave cap, arrives as a value from the caller. It writes only under the run directory. The files are the contract, so an orchestrator on a host that cannot run python3 can keep the same files by hand.

### Run directory

```text
.agent_spinner/            the current run; its own .gitignore holds "*"
  run.json                 run id, probed rung and capabilities, phases, bound, wave size,
                           block hashes, baseline commit
  request.txt              the request, verbatim
  intent.md                frozen intent; its hash is stamped into every brief
  preamble.md              invariant preamble; facts.tsv holds settled facts with tier and source
  access/<phase>.md        access block per phase; kinds/<kind>.md holds kind notes
  items/<label>.md         item briefs
  roster.tsv               one line per helper row
  exclusions.tsv           excluded item and reason
  briefs/<label>.txt       rendered briefs, the fixed probe brief included
  returns/<label>.start    start marker a file-writing helper creates first
  returns/<label>.md       helper return
  ledger.jsonl             findings, forks, flags, incidents, own-authority calls,
                           narrowings, gates, checks
  baseline/                HEAD, status and stash-list records, hashes, copies of files
                           modified at start
  snapshots/               file copies for reading passes, base-commit copies included
  diffs/ gates/ outbound/  per-file diffs, gate logs, outbound drafts
  controls/                the known positives init plants for the gate-scope check
  STOP                     while present, nothing new is dispatched
  announcement.txt         the opening announcement
  report.md                the closing report
  history/<run-id>/        closed runs
```

A closed run stays readable at these flat paths until the next `init` moves it under `history/<run-id>/`, so the eval harness still finds a closed run's roster, briefs, and report.

### The frozen verb set

| Verb | What it does |
| --- | --- |
| `init` | Creates the run directory and its `.gitignore`, then opens a run over the enumerated list the caller names. Loads each unit as a row with a stable slug, records exclusions with reasons, records the baseline, and records which targets carry a stamp or marker together with the owning family's gate. Plants one known-positive file per file type the named gates read, each holding one lint defect and one counted marker, runs each gate at the baseline, and records whether that gate reported its planted file. Prints the counts the announcement needs. Refuses a blank, duplicate, or case-colliding slug, a gate the caller marks as auto-fixing, and a new run while one is open, naming `attach` in that refusal. |
| `init --probe` | Creates the run directory and renders the fixed probe brief once per spawn route the caller names: the cheapest route and each registered role the host lists. Opens no run, so the later `init` opens it. Accepting a probe row records each capability as established, assumed absent, or unverified. The read-only lever counts as enforced only when the probe's write attempt inside the run directory left no file. Model and depth count as observed only where the host exposes the helper's settings to the run. |
| `attach` | Re-reads `run.json`, checks HEAD and the tree guard against the baseline, prints the status and the pending returns, and records the re-entry time. A completion notice, a user message, and a fresh session all re-enter through it. |
| `brief` | Renders one brief from the run's fixed blocks in a fixed order and appends a closing block: the role's return template, the return channel, the END line, the no-delegation clause, the capabilities stated as facts, the bound, and the brief token as the last line. A writer's closing block adds the start-marker instruction and the rule that its final message is only its END line. Relays upstream material by path, or pasted under a stated cap with the trimmed ids listed, and refuses a relay whose upstream row is unaccepted. Records the version of every input the brief names, relayed returns included, and the row's obligations, such as the paths its `examined` list must cover. Refuses shared blocks that differ within a phase and a brief that both forbids and permits one path or command, and warns on steering words in a checker brief. One provisional flag takes a withheld text on standard input and records only its hash in the blind row's input versions. |
| `dispatch` | Marks a row dispatched with its UTC time and spawn route. `--helper-id` records the host's id for the spawn where the host gives one, and `--model M --effort E` records the requested values. Refuses while `STOP` exists, while W written rows are unchecked, and while a user gate is open for a writer. Refuses a third attempt, a second repair of the same path, and a second re-check of the same repaired item. |
| `accept` | Validates a return file against the return contract, imports its records with stable ids, and records the source as `file`. `--stdin <label>` takes the verbatim final message, or a host log file the caller pipes instead, stores it at `returns/<label>.md`, and records the source as `relayed` or `log`. Checks each receipt line against the input version the row recorded, never against the live file, and checks a withheld text's later version against the blind row's hash. Tags each confirmation recall-confirmed when the checker's brief relayed that record, and independently surfaced otherwise. `--observed-model M --observed-effort E` records what the host exposed to the run, or `unobserved`. `--wait` polls the return files for at most 90 seconds per call until every row of the wave is terminal or past its bound, and marks a row past its bound unreturned. `--classify` records the orchestrator's call on a free-text return. |
| `rows` | `--phase P --from-records PATTERN`, `--from-repair-list`, or `--from-gaps LABEL` creates one row per source record, derives each slug from the record id, refuses a duplicate, and records the source phase. |
| `dispose` | Records final dispositions singly or by id pattern: applied (tagged re-derived or taken on a helper's word), refuted with its span, surfaced with a packet id, or deferred with a durable pointer. Also records narrowings with the checks they drop, attributions, and user gates. |
| `diff` | Measures the net change against the baseline and HEAD, attributes each change to a writer row, the orchestrator, or an outside source, and writes each per-file diff under `diffs/`. `--add-checks` adds a check row for every changed path, whoever wrote it. Flags date-only changes, mostly-deleted files, and append-only violations, maps hunks to approved-edit ids, and runs the tree guard. `--count` runs counters with built-in known positives. |
| `gate` | `gate NAME -- ARGV` runs a command without a shell and records its exit status, its output, and its executable's resolved path. `--expect exit0` records a silent pass as silent, `nonempty` fails on empty output, and `count` needs a counter whose positive control passed. For a gate that reported its planted file, drops findings under the run directory and says so on the gate line, and names a gate the filter cannot handle as a narrowing. `--on-baseline` records the baseline run, and later runs report the difference. An executable that does not resolve makes the gate unavailable, recorded as a narrowing. |
| `snapshot` | Copies the files a reading row needs, from the baseline or the working tree, into `snapshots/`. `--base` copies the base commit's files through `git show`, so nothing enters the repository. |
| `status` | Prints the live tally, each open row with its bound deadline, each open gate, the repair list, and a resume listing by brief hash. |
| `show` | `show <label>` prints one row's records in full. |
| `search` | Runs a pattern search over the run directory in Python, with its own positive control. |
| `stop` | Creates `STOP`. |
| `close` | Renders the tally block and checks that `report.md` carries it byte for byte, with confirmations split into recall-confirmed and independently surfaced. Prints advisory claim lines, flags "independent" on a row tagged recall-confirmed, and flags every checker whose recorded depth sits below its producer's. Exits 3 and lists the open items while any close condition fails. `--stopped` lists modified, untouched, and unknown paths. When it closes the run, it removes the snapshot copies and keeps their hashes on the roster. |

Each verb answers `--help` with its row's meaning, so the command reference can be written from the program. One working root holds one open run.

### Roster, return contract, and close conditions

`roster.tsv` holds one line per helper row with these columns in this order: label (the stable `role:item` label the return echoes), phase, role, item (the unit's stable slug), path, kind, state, attempts, brief hash, input versions, helper id, spawn route, model_req, effort_req, model_obs, effort_obs, dispatched at, start-marker time, returned at, source, and stamp owner. State takes pending, dispatched, violation, accepted, inability, failed, unreturned, unknown, or dropped. Input versions hold the baseline copy for a writer's target, the snapshot for a reader, each relayed return, and for a blind pass the hash of each withheld text. Spawn route names a registered role or a generic spawn, with the lever and depth as the probe found them. Times are UTC, and the start-marker and return times come from the filesystem. A checker's producer is the row whose return its brief relayed.

A return may open with prose for people, holds exactly one fenced JSON block, and ends with the line `END <label>`. The block echoes the label first and repeats the brief token:

```json
{"label": "check:docs-setup", "brief": "3f9a1c07", "status": "done", "verdict": "fail",
 "examined": [{"path": "docs/setup.md", "how": "full", "receipt": "Run `tool.sh setup --jobs 4`."}],
 "checklist": [{"n": 1, "verdict": "fail", "span": "docs/setup.md#Install"}],
 "findings": [{"claim": "The page documents a flag the command lacks.", "severity": "major",
   "quote": "--jobs 4", "anchor": "docs/setup.md#Install"}],
 "forks": [], "beyond_brief": [], "incidents": [], "own_authority": [],
 "alternatives": [], "brief_corrections": [], "dropped_suspicions": [], "notes": ""}
```

`status` is `done` or `inability`, and `verdict` and each checklist `verdict` take `pass` or `fail`. Each `examined` entry claims a reading of `full`, `searched`, or `unreachable` with one verbatim receipt line. A finding carries a claim, a severity from the ladder the run records at `init`, a quote, and an anchor. A fork carries its issue in one sentence, the verbatim passage with its anchor, two to four options each with a cost, and the helper's preferred end state verbatim. The other lists hold objects with a `text` field, plus an `anchor` where an entry points into the tree, and `alternatives` may be explicitly empty. Extra keys pass through with the return.

A helper whose brief grants file writes writes `returns/<label>.md` as its last act, and its final message is only `END <label>`. A helper whose read-only lever removes file writes, or whose brief forbids them, ends with the return block and its END line as its final message and never writes its return through a shell. The orchestrator pipes that message verbatim into `accept --stdin <label>`, or pipes a host log file that holds it. A file-writing helper's first act creates `returns/<label>.start`. Two rows ran at once when their marker-to-return intervals overlap, and a read-only wave leaves its concurrency unobserved.

`accept` rejects a return, from a file and from standard input alike, when the END line is missing, the block count is not exactly one, the echoed label disagrees with the file name or the `--stdin` label, the token disagrees with the roster, a required key is missing, a value falls outside its allowed set, a value is a placeholder, a receipt line is missing from the input version its row recorded, a passing checklist line cites no span, or a list falls short of the obligations recorded for its row. A placeholder is an empty or whitespace-only required text, an ellipsis, a lone angle-bracketed slot such as `<path>`, or a to-do marker such as TODO or TBD. The first rejection sets the row to violation and prints the errors for one re-ask, and the second sets it to failed. An inability status completes the row with no retry. A free-text return waits for `--classify`, because recognizing host boilerplate is a per-harness judgement. A return far smaller than its siblings raises a warning, and joins read identifiers only and stop when one is missing.

`close` exits 0 only when all of these hold:

1. Every row is terminal: accepted, inability, failed, unreturned, or dropped by a named narrowing, rows that `rows` created at runtime included.
2. Every record has a disposition.
3. Every changed path, drafts under `outbound/` included, has an accepted check from another row, a covering gate, or an unverified disposition.
4. Every change is attributed.
5. The tree guard is clean, or each change it found has a disposition.
6. Every fork is surfaced or listed as the orchestrator's own decision, and every gate is answered.
7. `report.md` carries the current tally block.
8. Every accepted, inability, or failed row records its source as `file`, `relayed`, or `log`.
9. Every checker sits at or above its producer's recorded depth, or carries a flag.

### Portability and failure

- **Git reads only.** Every git call passes `--no-optional-locks`, because a plain `git status` refreshes and writes the index. Status reads pass `--porcelain -z --untracked-files=all`, and diff reads pass `--no-ext-diff --no-textconv --no-color`. No call writes a ref, the index, a tree, a commit, an object, or the working tree, and `stash list` is the only form of `stash` the ledger runs.
- **Paths and text.** Every path is normalized to its realpath relative to the repository root before any join. Slugs are case-folded, text is read as UTF-8 with replacement, and a NUL byte marks a binary file. The walk follows no symlink inside the tree and skips submodules. Where the target is not a repository, a hashed walk stands in, recorded as a narrowing.
- **Fail closed and measure.** A missing sentinel, an unreadable block, and a counter whose positive control failed each refuse with a non-zero exit and a message naming what to fix. An internal error exits non-zero naming the failed step, so the orchestrator can record it and continue by hand. The measured diff decides which files changed, whatever a writer reported.
- **Concurrency and time.** An advisory lock with atomic replace guards the ledger's own files. Timestamps are UTC, bounds count from the dispatch time, and concurrency comes from filesystem times, never from a helper's claim.
- **Interpreter and invocation.** The ledger checks its interpreter at start and exits with an actionable error below 3.9. It uses no syntax newer than 3.9, so that check runs first. It is one file, run as `python3 -B` on its absolute path with no wrapper, and `-B` writes no bytecode.
- **Text the static greps scan.** Code, comments, and strings pass every grep `run.sh` runs over the skill directory. No identifier may end in `task(` or `bash(` in any case, and no name may carry a product token, such as a database cursor named `cursor`. The code avoids the `$VAR$` placeholder shape, which `make deploy` can replace in deployed copies.

### Tests, grader, lint scope, and docs

- **Static contract.** In `tests/agent_spinner/script_tests/run.sh`, replace the check "the skill bundles no runtime scripts" with checks that `scripts/` holds exactly `run_ledger.py`, that it imports only standard-library modules, that it answers `--help` under the oldest python3 on the machine, and that its source holds no state-changing git subcommand. A comment beside them names the change superseded behaviour under the owner's decision to bundle the ledger. Replace the version pin with a semver-shape check, and name it a grader fix in a comment: the pin asserted one value of a property every commit-time bump changes, the reason `tests/lib/plugin_version.sh` gives against literal pins. Rewrite the header comment that says the skill ships no bundled scripts.
- **Ledger tests.** Add `tests/agent_spinner/script_tests/ledger_run.sh`, written to the bash 3.2 floor `lint-sh` enforces, staging each scenario under `script_tests/scratch/`. It finds every python3 the machine offers, on `PATH` and the operating system's own, runs each scenario under the oldest and the newest, and prints both versions. When only one exists, it runs once and says so. `run_all.sh` drives it beside `run.sh` with an aggregated exit code, the way `tests/task/run_all.sh` drives its two runners.
- **Grader.** In `grade.sh`, replace `PHASE_PLAN` in the inline_floor and phase_plan_announcement arms with an assertion that the announcement states two to four named phases, written to TESTING.md's test design principles. A comment names it a grader fix, because the pattern asserted surface form rather than the property both evals state.
- **Lint scope.** Add `-name .agent_spinner -prune -o` to `EXCLUDE`. Rewrite the comment above it so it says this prune mirrors the run directory's own `.gitignore`. That file sets the git side wherever a run sits, so lint scope still matches git scope and `tests/.gitignore` stays unchanged.
- **Harness docs.** Rewrite in place each agent_spinner line that `grep -rniE 'prose-only|no bundled scripts|bundles no (runtime )?scripts|ships no bundled' tests/agent_spinner tests/README.md tests/CLAUDE.md` finds, so it names the bundled ledger and its tests, and leave other skills' lines as they are. Update the layout tree in `tests/agent_spinner/README.md` and the static-contract section of `tests/agent_spinner/RUNBOOK.md`, which says `run_all.sh` drives one entrypoint. `tests/AGENTS.md` keeps no inventory row of its own, so it needs no change.
- **Wiki.** Through the wiki skill family, update `wiki/concepts/agent-delegated-automation.md` where its section headed "The general rule lives in a skill, the instances keep their own runs" lists what ships with the skill, and where its "Derived from" list names the skill and its `references/`. Both name the run ledger: a standard-library program that keeps a run's accounts and launches nothing.

**Out of scope:**

- The command reference in `references/run-protocol.md`, the `SKILL.md` blocks that cite the ledger, and the ledger-increment evals, which [ai-dev_agent-spinner-ledger-doctrine](ai-dev_agent-spinner-ledger-doctrine.md) owns.
- The `<role>` sentence naming `scripts/` and the concept page's one-way routing paragraph, which [ai-dev_agent-spinner-routing](ai-dev_agent-spinner-routing.md) owns.
- The markers check over the ledger's own rows, the checklist-to-acceptance lint, decision packets rendered from the ledger, and the helper-log audit, which [ai-dev_agent-spinner-ledger-phase-2](ai-dev_agent-spinner-ledger-phase-2.md) owns.
- Launching any helper or headless worker, which a separate skill owns through [ai-dev_headless-launcher-skill](ai-dev_headless-launcher-skill.md).
- A `--run-dir` option, since one working root holds one open run and `init` names `attach` instead.

## Acceptance

- `python3 -B` on the ledger's absolute path with `--help` lists exactly the verbs of the frozen set, each with its own `--help`, and an unknown verb exits non-zero.
- `bash tests/agent_spinner/run_all.sh` exits 0 under the stock bash 3.2, running the static contract and `ledger_run.sh`, which prints the oldest and newest python3 versions it used and passes every scenario below under both.
- Slugs: `init` refuses a blank, a duplicate, and a case-colliding slug, and a label two units share, and while a run is open it refuses with a message naming `attach`.
- Rejection: each rejection rule has a scenario that `accept` rejects, the first rejection leaves the row in violation and the second in failed, an inability return completes its row with no retry, and a schema-valid plan holding one placeholder task against five target paths is rejected.
- Joins: two returns arriving in reverse order are joined only by echoed label and brief token.
- `diff`: a return claiming no change for a file that differs from the baseline still gets a check row, an orchestrator write is attributed to the orchestrator, a helper write outside its brief's target paths gets a check row that keeps `close` refusing while it is open, and an untracked file, a date-only change, a stash change, a HEAD move, and new ignored residue are each caught.
- Approved edits: a regeneration carrying one extra hunk is reported with the hunk that maps to no approved-edit id.
- Counters: a counter whose pattern misses its own known positive, such as an alternation that a zsh quoting slip turned literal, fails closed instead of reporting zero.
- `gate --expect`: `exit0` records a silent pass as silent, `nonempty` fails on empty output, `count` refuses a counter whose positive control failed, the baseline difference is reported, each command's resolved executable path is recorded, and an unresolved executable records the gate as unavailable and names the narrowing.
- `close`: each close condition refuses on its own staged gap with exit 3 and the open item named, including condition 1 over rows `rows` created at runtime and a row with no recorded source. The tally byte check fails on an altered report, a checker recorded below its producer's depth is flagged, and `close --stopped` lists modified, untouched, and unknown paths.
- Repository safety: every verb leaves the tree hash outside `.agent_spinner/`, the index file's bytes, and the output of `git for-each-ref` and `git count-objects -v` unchanged, and writes no bytecode.
- `accept --stdin`: label echo, brief token, sentinel, a source of `relayed`, or `log` when a host log file is piped, and the same rejections as a file return.
- `attach` reports the open run and its pending returns, and it reports a HEAD that moved since the baseline.
- `rows` from records, from the repair list, and from gaps makes one row per source record with its slug from the record id, refuses a duplicate, and records the source phase.
- `show` prints one row's records in full, and `search` finds a marker planted in the run directory that an ignore-honouring search misses, with its positive control passing.
- Gate scope: `init` plants one known positive per file type, shown with a markdown gate and a shell gate, the path filter drops run-directory findings for a gate that reported its plant and says so, and an auto-fix gate is refused while run state exists.
- Hostile git settings: under `-c status.showUntrackedFiles=no`, an external diff driver, a textconv driver, and forced color, with hidden untracked files and from a symlinked root, status and diff reads stay correct and every path is normalized relative to the repository root.
- Recorded versions: a receipt matching the row's recorded snapshot is accepted after the live file changed, and a withheld text handed to `brief` leaves only its hash on the blind row, which `accept` later checks against that text's recorded version.
- Recall tags: a confirmation is tagged recall-confirmed when the checker's brief relayed the record and independently surfaced otherwise, the tally block splits the two, and `close` flags "independent" on a recall-confirmed row.
- Start markers: overlapping and serial intervals are read correctly from the filesystem times of `returns/<label>.start` and the return file.
- Version floor: with the version it reads stubbed below 3.9, the ledger exits non-zero with an error naming the floor and the running version.
- `run.sh` holds no check asserting that `scripts/` is absent. Each replacement check passes on the tree and fails on a scratch copy holding one violation: an extra file in `scripts/`, a third-party import, syntax the oldest python3 rejects, or a state-changing git call.
- `run.sh`'s version check is a semver-shape check that passes at the current version and fails on a scratch copy whose version reads `1.0`, and `run.sh` reports no failure.
- Every existing grep in `run.sh` passes with `scripts/run_ledger.py` in the tree.
- A comment beside each edited check names its class under TESTING.md's Test Integrity rule with its evidence: the scripts check as superseded behaviour, and the version check and the phase-count assertion as grader fixes.
- The phase-count assertion passes on staged announcements naming two and four phases and fails on ones naming a single phase and five phases. inline_floor and phase_plan_announcement pass under TESTING.md's vendor rule, where re-grading a captured run counts under TESTING.md's re-run economy.
- `EXCLUDE` carries the `.agent_spinner` prune and the comment above it names the pairing. A markdown file with a lint defect, staged under a repository-root `.agent_spinner/` whose `.gitignore` holds `*`, appears neither in `make lint-md`'s file list nor in `git status`. `tests/.gitignore` is unchanged.
- The harness-docs grep finds no agent_spinner line calling the skill prose-only or scriptless, other skills' lines are unchanged, and the README layout tree and the RUNBOOK name `ledger_run.sh`.
- The concept page's skill section and its "Derived from" entry name `scripts/run_ledger.py`, written through the wiki skill family.
- Before commit, a manual read of every changed shipped file and of this task's own diff finds no session, company, or project name, and no denylist is committed.
