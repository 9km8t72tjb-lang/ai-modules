---
ingested: 2026-10-04
sha256: 33cf51db7be2daa84ff50953c2503fb0f7611e293292865260e17cad30c35e1b
---

# Delegation probes on Claude Code, Cursor, and Codex, 2026-10-04

This note records the results of live probes run on 2026-10-04 in a local session. The probe record is a local file outside the repository, and its content is excerpted below as the authoritative copy. No machine path, scratch path, or session id from the probes is given.

Each probe ran in a scratch git repository with its own `git init`, and its event stream was captured. The builds were `claude` 2.1.226 in print mode with `--model sonnet`, which resolved to `claude-sonnet-5`, the Cursor `agent` CLI 2026.10.01 in print mode with `--model auto`, and `codex-cli` 0.160.0 through `codex exec`. The run metadata adds the flags each probe ran under. The Claude probes ran with `--permission-mode bypassPermissions`, except the plan-mode probe, which ran with `--permission-mode plan`. Every Cursor probe ran with `--force` and `--sandbox disabled`, and every one but the run that read the permission file without `--trust` also passed `--trust`. The Codex probes ran with `--dangerously-bypass-approvals-and-sandbox` unless a fact names other sandbox flags, and every Codex probe after the first plain run trusted its project for the run through `-c 'projects."<dir>".trust_level="trusted"'`.

The facts fall into two groups with different consumers. The agent_spinner skill relies only on the sub-agent facts, which describe what a session and the helpers it spawns can do. The CLI facts describe how a launcher drives each host from the command line. They serve the test runner and this wiki, and agent_spinner relies on none of them.

## Sub-agent facts

### Claude Code

- The spawn tool appears as `Task` in the session's init tool list and as `Agent` in the stream's `tool_use` records. The `Workflow` tool also spawns agents, so a session without spawning needs both withheld.
- A role file staged in the project's `.claude/agents/` directory appears in the init `agents` list and spawns by name (`subagent_type: <name>`).
- A role whose frontmatter `tools:` lists `Read, Grep, Glob` ran with exactly those tools. Its write and shell attempts found no tool, so the allowlist holds.
- Tools denied to the parent session are denied inside its spawned helpers too. The refusal reads "disabled for this session, in subagents as well as here".
- A spawned helper's own tool calls appear in the parent's stream, marked with `parent_tool_use_id`.
- No goal tool exists in print mode. The session lists `ScheduleWakeup`, `CronCreate`, `CronDelete`, `CronList`, and `Monitor`, and no probe exercised them.
- Deployed user-level roles and skills reach a sandboxed session: the init lists include the user's deployed `auto_*` roles and skills.

### Cursor

- The spawn tool is `Task`. Its stream record holds `description`, `prompt`, `subagentType` (`custom.name` for a named role, `unspecified` otherwise), `model`, `agentId`, and `mode`.
- A role file staged in the project's `.cursor/agents/` directory spawns by name in print mode.
- A role whose frontmatter says `readonly: true` ran in ask mode, and both its file write and its shell command were refused, with no file created. This differs from the September observation in the IDE, where `readonly: true` left the shell callable, so each observation is recorded with its mode beside it.
- A `Task` call asked to set `readonly` recorded no read-only field (`mode: TASK_MODE_UNSPECIFIED`), and that helper wrote its file and ran its shell command. A per-call read-only setting was therefore not observed.
- A spawned helper's result reaches the parent as its final text inside the `Task` result (`conversationSteps`). The helper's own tool calls do not appear in the parent's stream.
- Deployed user-level roles from the user's agents directory did not appear among the subagent types of a sandboxed print-mode session. Deployed user-level skills did reach it: the session read the user-level agent_spinner `SKILL.md`.
- `CreateGoal` and `UpdateGoal` are callable in print mode. The goal was created and later marked complete, and a resumed turn recalled it. No probe tested whether an armed goal keeps work going past the end of a turn.
- Print-mode tool names: `Shell`, `Grep`, `Glob`, `Read`, `Write`, `StrReplace`, `Delete`, `EditNotebook`, `TodoWrite`, `Task`, `AwaitShell`, `AskQuestion`, `SwitchMode`, `WebSearch`, `WebFetch`, `ReadLints`, `CreateGoal`, `UpdateGoal`, `GenerateImage`, and dynamic or MCP tools. Built-in subagent types: `generalPurpose`, `explore`, `shell`, `cursor-guide`, `ci-investigator`, `bugbot`, `security-review`, and `best-of-n-runner`.

### Codex

- `codex exec` exposes native sub-agent tools: `collaboration.spawn_agent`, `wait_agent`, `send_message`, `list_agents`, `interrupt_agent`, and `followup_task`. It also exposes `create_goal`, `get_goal`, and `update_goal`.
- Spawnable roles come from the user's `~/.codex/agents/*.toml` and, in a trusted project, from `.codex/agents/*.toml`, beside the built-ins `default`, `explorer`, and `worker`.
- A role with `sandbox_mode = "read-only"` still wrote a file and ran a shell command. That held under a parent run with `--dangerously-bypass-approvals-and-sandbox`, and again under `-s workspace-write -c approval_policy="never"`. A read-only role on Codex therefore rests on its body contract alone.
- `--disable multi_agent` did not stop spawning.

## CLI facts

### Claude CLI

- `--disallowedTools Bash` removes the shell (and adds dedicated `Glob` and `Grep` tools). `--disallowedTools Edit,Write,NotebookEdit` removes file writing. `--disallowedTools Agent,Task` removes the spawn tool, while `Workflow` stays callable unless named too.
- `--tools Read,Grep,Glob` leaves exactly those tools: a clean read-only session.
- `--permission-mode plan` blocks project writes and restricts the shell to read-only use. It wrote a plan file into the user's real `~/.claude/plans/` directory, so it is unfit for evals.
- `--session-id <uuid>` on the first turn and `--resume <uuid>` on the second carry the conversation.
- A worker with a scratch `CLAUDE_CONFIG_DIR`, `CLAUDE_SECURESTORAGE_CONFIG_DIR` set to the empty string, and the test runner's `_claude_worker_env()` environment authenticated, and its init listed only built-in roles and skills, none of the user's deployed ones.
- `--output-format stream-json` needs `--verbose`. Event shapes: `system`/`init` with `tools`, `agents`, `skills`, `model`, `permissionMode`, and `session_id`; `assistant` messages whose content holds `tool_use` blocks (`id`, `name`, `input`); `user` messages whose content holds `tool_result` blocks (`tool_use_id`, `content`, `is_error`); and `result` with `result`, `session_id`, and `usage`.

### Cursor CLI

- A project-level `.cursor/cli.json` with `{"permissions": {"allow": [], "deny": [...]}}` is read with and without `--trust`.
- Deny entries `Shell(touch)` and `Shell(*)` refused the shell call with a `permissionDenied` result. Deny entries `Write(**)`, `Write(**/*)`, and `Write(*)` refused the edit call with a `writePermissionDenied` result. Both denials held inside a spawned helper as well.
- Deny entries `Task(*)` and `Task` did not withhold the spawn tool: the helper spawned and wrote its file.
- `--mode ask` under `--force` blocked nothing: the file write and the shell both succeeded. `--mode plan` refused edits to non-markdown files and left the shell callable.
- A second turn resumes with `--resume <session_id>`, taking the `session_id` from the first turn's stream. No `create-chat` call is needed.
- Stream-json event shapes: `system`/`init` with `model`, `permissionMode`, and `session_id`, and no tool list; `assistant` text; `thinking` deltas; `tool_call` events with `subtype` `started` or `completed`, whose `tool_call` object holds one key naming the tool kind (`readToolCall`, `shellToolCall`, `editToolCall`, `taskToolCall`, `createGoalToolCall`, `updateGoalToolCall`, and `getMcpToolsToolCall` were seen), with `args`, plus on completion a `result` holding `success`, `permissionDenied`, `writePermissionDenied`, or `error`; and `result` with `result`, `session_id`, and `usage` (`inputTokens`, `outputTokens`, `cacheReadTokens`, `cacheWriteTokens`).

### Codex CLI

- The binary sits at `Contents/Resources/codex-cli/bin/codex` inside the ChatGPT desktop application bundle and is not on PATH. The account was signed in through ChatGPT.
- `codex exec --json --dangerously-bypass-approvals-and-sandbox -C <dir> <prompt>` runs one turn. `codex exec ... resume <thread_id> <prompt>` resumes it. Events: `thread.started` (`thread_id`), `turn.started`, `item.started` and `item.completed` with item types `agent_message`, `command_execution`, `file_change`, and `collab_tool_call`, and `turn.completed` (`usage`). The stream itemised only the `wait` collaboration call, with empty receiver ids, and no spawn item, while the spawned helper's file appeared.
- With the project trusted through `-c 'projects."<dir>".trust_level="trusted"'`, a skill in the project's `.agents/skills/<name>/SKILL.md` was discovered and loaded. The model read its `SKILL.md` through a shell `cat` command.
- `-s read-only` blocked both patch writes and shell writes for the whole session.
