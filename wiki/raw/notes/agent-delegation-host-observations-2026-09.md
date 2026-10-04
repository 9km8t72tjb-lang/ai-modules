---
ingested: 2026-10-04
sha256: dd76948ab0deeb16b0fdecfb133de62ab295bb8eaa886ca2b8d09d70c5d22478
---

# Agent delegation host observations, September 2026

This note anonymizes the host observations of a private research archive kept on the author's workstation, outside the repository. The research studied how orchestration runs delegate work to helper agents on Claude Code and on Cursor, to plan agent_spinner's support for hosts without Claude Code's Workflow tool. Each observation carries its date and the kind of source behind it. The relevant content is excerpted below as the authoritative copy, and no path to the archive is given.

## Source kinds and terms

Each observation rests on one of these source kinds:

- observed in local agent transcripts;
- observed in local workflow records, meaning workflow scripts, journals, and result files;
- read from the installed CLI's help text;
- read from an installed build, its app bundle, its local state store, or a directory listing;
- measured by a command run on the workstation.

The research uses three terms for how delegated work runs and comes back. Under batch delivery, several spawns sent together return together inside the turn. Under notice delivery, a spawn returns at once, and its completion arrives later as a notice, with or without its result. At the inline floor no delegation surface exists, so each pass runs in the orchestrator's own context.

## Cursor

These rows come from the Cursor IDE unless a row names another source.

| Observation | Observed | Source kind |
| --- | --- | --- |
| Manually attaching a skill inlines only its SKILL.md body into the user turn, with no frontmatter and no references. A note says the files need reading only if needed. | 2026-09-16, 2026-09-23 | local agent transcripts |
| A subagent's first turn holds only its prompt, and the parent's attached skills never reach it. | 2026-09-16 | local agent transcripts |
| The Task call accepts description, subagent_type, prompt, model, run_in_background, resume, and readonly. Custom agents are callable by name. | 2026-09-16, 2026-09-22 | local agent transcripts |
| A requested model of `fast` was recorded as `default`, so its effect is unverified. | 2026-09-16 | local agent transcripts |
| Effort keys in agent definitions had no observable effect, and helpers ran on `default` with max mode off. Per-definition model pins took effect in July transcripts. | 2026-09-16 | local agent transcripts |
| `readonly: true` maps a helper to chat mode and leaves the shell callable. | 2026-09-17, 2026-09-26 | local agent transcripts |
| The frontmatter tools allowlist is not enforced. | 2026-09-26 | local agent transcripts |
| Several foreground Task calls in one message run concurrently and act as a barrier. | 2026-09-17 | local agent transcripts |
| A background completion re-invokes the parent only after the parent's turn ends. It carries no result and can arrive in bursts. | 2026-09-16, 2026-09-22 | local agent transcripts |
| Helper transcripts are live JSONL files at `agent-transcripts/<parent>/subagents/<id>.jsonl`. They end in a `turn_ended` record and hold no tool results. | 2026-09-22, 2026-09-23 | local agent transcripts |
| Helpers can read their siblings' transcripts, and nothing isolates them. | 2026-09-16, 2026-09-22 | local agent transcripts |
| The parent and a background helper share one working tree and one index. | 2026-09-16 | local agent transcripts |
| Grep and Glob silently re-scope out-of-workspace paths to the workspace. | 2026-09-26 | local agent transcripts |
| A dynamic-tool search returns a false negative for delegation. | 2026-09-26 | local agent transcripts |
| Helper progress updates never reach the parent. | 2026-09-22 | local agent transcripts |
| The editor's state store keeps the tool results and termination reasons that the transcripts omit. Its per-session change tally matched the working-tree diff of the target. | 2026-09-26 | the editor's local state store |
| Each helper starts with a fixed load of about 24,000 to 25,000 tokens. One parent context holding five rounds of returns reached 141,765 of 256,000 tokens, 55 percent. About 24,000 of that was fixed host overhead. The other 117,761 was conversation: the inlined skill, five full reads of the task file, the orchestrator's own prompts, and 25 returns. | 2026-09-17, 2026-09-26 | local agent transcripts |
| Nested spawning worked on 2026-07-02, with a subagent dispatching background reviewers and polling their transcripts. No subagent has issued a Task call since August, while main sessions kept making them. Whether a subagent can still spawn is unverified. | as stated | local agent transcripts |
| The build defines subagentStart and subagentStop hook events. The stop event carries status, duration, summary, modified files, tool-call count, error message, and loop count. The 2026-09-22 session under study did not use them. | 2026-09-27 | the installed build |
| Transcripts record no token counts. | 2026-09-16 to 2026-09-26 | local agent transcripts |
| The host shows both delivery properties. Several foreground Task calls in one message return together inside the turn, which is batch delivery. A background call returns at once, and its completion arrives after the turn ends as a notice with no result, which is notice delivery. | 2026-09-16, 2026-09-17 | local agent transcripts |
| The largest batches observed were seven background Task calls in one message and five foreground calls in one response. | 2026-09-16, 2026-09-17 | local agent transcripts |
| A cross-turn continuation primitive exists. A built-in goal skill calls a CreateGoal tool whose goal persists across turns with no turn budget, and a built-in loop skill reruns a prompt on an interval. One orchestrator looked the tool up and left it unused, so no run has exercised either. Both skill files sit in Cursor's built-in skills folder in the user's home directory. | 2026-09-22; files listed 2026-09-27 | local agent transcripts; a directory listing |
| The agent's shell tool spawns non-login `zsh -i` shells. A tool that only the login profile puts on PATH does not resolve there. | 2026-09-18 | a process listing on the workstation |
| The IDE build read 3.22.7, installed 2026-09-24, after most of the observations above. The installed agent CLI read 2026.01.23, about eight months older. Attachment and spawn behaviour were observed in the IDE, so a runner on the CLI may measure a different host until a probe compares the two. | 2026-09-27 | the app bundle's version and the CLI's version output |
| The IDE build read 3.23.12, and the agent CLI read 2026.10.01. The eight-month gap recorded on 2026-09-27 no longer holds in build dates. | 2026-10-04 | the app bundle's version and the CLI's version output |

## Claude Code

These rows come from Claude Code desktop sessions and their Workflow tool, on the dates each row gives. One session recorded build 2.1.260. Build 2.1.226 is the standalone CLI whose help text the headless CLI flags section records. The research checker left most source entries behind these rows unchecked. Several rows rest on analyst observations alone, among them depth 2 through the Agent tool, the 55,000-token start and the verbatim request, the quiet-file interval, the skill-listing lag, and the shell's sleep blocking.

| Observation | Observed | Source kind |
| --- | --- | --- |
| Workflow helpers run at spawn depth 1 and inherit the main-loop model and effort. | 2026-09-05, 2026-09-06 | local workflow records |
| The Workflow pool ran at most 12 helpers at once, consistent with first-in-first-out queuing. At about width 160, no verifier started until every writer had been dequeued, and at the user's stop most writers and no checker had started. At about width 80, the first checker started while writers still ran, so the stages overlapped at the tail. | 2026-09-05 | local workflow records |
| A schema-bound helper retries inside its own turn, and its first schema-valid call ends it, even when that call is a probe. After five failures the slot resolves falsy and the run completes. | 2026-09-15 | local workflow records |
| A "done" state plus null filtering counts a schema-valid placeholder as a success. One output of 142,872 characters was accepted. | 2026-09-15, 2026-09-23 | local workflow records |
| Journal result entries carry no label and arrive in completion order, and labels need not be unique. | 2026-09-15 | local workflow records |
| Resume replays the longest unchanged prefix of agent calls, so a byte-identical call placed after a changed one runs fresh. The claim that the cache is keyed on content was refuted. | 2026-09-24 | local workflow records |
| A resume reruns killed helpers against the current disk state. | 2026-09-05 | local workflow records |
| A stop kills helpers in flight without results, and their edits persist. Freed slots kept starting queued helpers after a pause request. Whether the tool offers a pause is unverified. | 2026-09-05, 2026-09-23 | local workflow records and session transcripts |
| General-purpose helpers keep every tool. The Explore type keeps Bash and describes itself as a search role that does not review. | 2026-09-05 | local session transcripts |
| A custom agent spawned through the Agent tool reached depth 2. | 2026-09-05 | local session transcripts |
| Helpers start with about 55,000 tokens of context and receive the triggering request verbatim. | 2026-09-15, 2026-09-23 | local session transcripts |
| The workflow output file holds progress entries with truncated previews, and a plain read of it truncates. | 2026-09-05 | local workflow records |
| A quiet-file interval is not a completion signal. | 2026-09-15 | local session transcripts |
| The skill listing that helpers receive comes from the deployed copies, which can lag the working tree. | 2026-09-05 | local session transcripts |
| A background Workflow run returns a task id at once, and the main loop keeps running tools meanwhile. The completion notice carries the result inline, truncated in some sessions, and the full result sits in a task output file. This is notice delivery with the result, recorded for the Workflow tool only. How a background spawn outside the Workflow tool delivers is unrecorded. | 2026-09-05 to 2026-09-23 | local session transcripts and workflow records |
| A notice that completes during a blocking poll waits until the poll returns, which added 1.5 to 4.2 minutes of latency in one session. A user message sent during an unbounded foreground wait never reached the model. | 2026-09-15 | local session transcripts |
| The shell tool blocks foreground and chained sleeps and points to a monitor or a background run instead. It moves any command running past 600 seconds into the background. | 2026-09-15, 2026-09-16 | local session transcripts |
| Two continuation aids exist. An orchestrator set a 1200-second fallback wake-up as a stall guard while a background run worked. A session also lists a loop skill that reruns a prompt on an interval or at a self-chosen pace, and no run has exercised it. | 2026-09-05; listing read 2026-09-27 | local session transcripts; a session's skill listing |
| The Workflow tool description carries a default size guideline, "keep workflows under 10 agents", which the user's prompt may override. | 2026-09-23 | local session transcripts |
| Outside the Workflow tool, one repair session fanned out seven background survey agents over page ranges. The record leaves open whether they left in one message. | 2026-09-22 | local session transcripts |
| Each progress entry's token figure is the helper's final request context size, which differs from fresh-token spend. A cost share therefore needs its basis stated. | 2026-09-05 | local workflow records |

## Headless CLI flags

These flags were read from the installed CLIs' help text on 2026-09-27. No official documentation was read for them, so each rests on help text alone.

- **Cursor agent CLI 2026.01.23.**
  - `-p` "has access to all tools, including write and bash".
  - `--output-format` takes text, json, or stream-json.
  - `--mode` takes plan or ask, and the help describes both as read-only.
  - The help lists `--model`, `--list-models`, `--workspace`, `--sandbox enabled|disabled`, `--force`, `--resume`, and `create-chat`.
  - The help lists no schema, effort, or budget flag.
- **Claude CLI 2.1.226.**
  - The help lists `--json-schema`, `--output-format`, `--model`, and `--effort` with the levels low, medium, high, xhigh, and max.
  - It lists `--permission-mode`, `--tools`, `--allowedTools`, and `--disallowedTools`.
  - It lists `--max-budget-usd`, `-w/--worktree`, `--no-session-persistence`, and `--bg`.
  - `--agents <json>` defines custom agents for one session, so an eval runner can stage a role without deploying it.
  - `-r/--resume [value]`, `-c/--continue`, `--session-id <uuid>`, and `--fork-session` carry a conversation across invocations.
- A nested `claude -p` needs the session marker stripped from its environment, which the repository's test documentation already records.
- On 2026-09-27 neither the Codex CLI nor the OpenCode CLI was on PATH, so neither host was observed.

### Cursor agent CLI help re-read on 2026-10-04

The installed agent CLI read build 2026.10.01 on 2026-10-04. Its help text adds these points to the record above.

- `-p` now "has access to all tools, including write and shell".
- `-f, --force` reads "Force allow commands unless explicitly denied", and `--yolo` is its alias.
- `--model` accepts bracketed parameter overrides on a model name, and the help's example sets an effort key. The earlier record's missing effort flag therefore has a model-parameter route, and whether that key takes effect for a print-mode worker is unprobed.
- `--sandbox enabled|disabled` now states that it overrides the configuration.
- The help lists `--auto-review`, `--trust`, `--approve-mcps`, `--add-dir`, `--plugin-dir`, `-w/--worktree` with `--worktree-base`, and the `persist` command, which the earlier record does not list.
- The help still lists no schema flag and no budget flag.

## Shell and workstation behaviour

These observations come from commands run on the workstation on 2026-09-27.

- The stock macOS `/bin/bash` is 3.2.57, and `wait -n`, `declare -A`, and `mapfile` all fail under it.
- Neither `timeout` nor `gtimeout` is installed, and BSD `xargs -P` works.
- The system python3 is 3.9.6. Neither it nor a package-manager python3 on the same workstation has the `jsonschema` module.
- A non-login `zsh -i` started from a bare environment resolves neither markdownlint nor shellcheck. It resolves jq, python3, and bash to the stock system builds, while a login `zsh -l` finds the package-manager builds. Cursor's agent shell is non-login, so this repository's lint gates cannot run there, and a standard-library helper runs under the stock python3.
- markdownlint, `jq empty`, and shellcheck each exit 0 with no output on a clean file. A fail-on-empty rule would therefore record every clean pass as a failed probe.
- Claude Code's shell snapshot defines `grep` as a function that runs ugrep with `--ignore-files --hidden -I`. It finds nothing inside a directory whose own `.gitignore` holds `*`, while the system grep finds the planted file.
- In a scratch repository, ripgrep also found nothing when searching such a directory. Both ripgrep and the shell's grep found the planted marker when given its explicit file path.
- `git status --porcelain` lists no untracked file under `-c status.showUntrackedFiles=no`, and adding `--untracked-files=all` lists it again.
- A plain `git status` refreshes and writes the index by default, as git's own documentation of background refresh states. Passing `--no-optional-locks` stops that write.

These observations come from the case evidence.

- zsh drops the backslash from an ANSI-C quoted alternation such as `$'a\|b'`, so grep cannot match it. In one sweep, 49 writers and 32 verifiers used that form, and it produced false zero counts (2026-09-05).
- `${PIPESTATUS[0]}` expands to nothing under zsh (2026-09-15).
- The desktop shell's grep function omits the `./` prefix (2026-09-06).
- Shell until-loop waits that ran past 600 seconds moved to the background (2026-09-15). Whether the task-output tool caps a blocking wait is unverified, because the 600-second timeouts observed that day used the value the orchestrator passed.

## Open questions and the probe that settles each

The research planned these probes outside any run, before the skill body changes. Each result goes on record with its date and source kind.

- **Cursor IDE and agent CLI.** First, whether print mode exposes the spawn tool and matches the IDE's attachment and spawn behaviour. Then whether read-only modes block shell writes. Then what `default` resolves to and whether a per-call model takes effect. Then whether a subagent can spawn today, and whether a background helper outlives a headless session. Then whether the model can arm a goal and whether the goal survives completion turns. The list closes with launching the CLI from the agent shell, capturing a read-only worker's standard output, and one stream-json capture of tool records and usage.
- **Claude CLI.** Schema-violation behaviour, and whether the worktree and disallowed-tools flags confine a worker. Then nested authentication from the agent shell, standard output capture, the resume path a two-turn eval needs, and session-scoped agent definitions for staging roles in evals.
- **Codex and OpenCode, once installed.** Whether helpers can write return files under the host sandbox, and whether several spawns in one message act as a batch. Then whether completion re-invokes the parent, whether a skill-relative helper path resolves and runs, and role registration with its read-only lever.
- **Background survival on the Claude CLI.** The background-survival probe applies there too, because the eval runner is single-shot and headless.
- **Router recall on Cursor.** It stays unmeasured, because the description-recall work measures the Claude router only.

The 2026-10-04 help re-read adds two questions.

- Whether a deny entry in the Cursor agent CLI's permission configuration withholds a named tool, the spawn tool included, from a print-mode worker run with `--force`. The help text says `--force` allows commands unless explicitly denied, and no probe has tested a deny entry against a tool.
- Whether the effort key in a bracketed model parameter takes effect for a print-mode worker.
