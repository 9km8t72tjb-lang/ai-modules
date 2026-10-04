---
description: Make task_auto_check hand each helper its inputs as files read by path, apply approved edits exactly by id, and check every applied change before the loop moves on.
scope: plugins/ai_dev/skills/task_auto_check
created: 2026-10-03T15:54:08
updated: 2026-10-04T17:21:44
status: open
reported-by: Andreas Hoffmann
---

# Pass readiness-loop hand-offs as files and check every applied change

## Goal

`task_auto_check` is the readiness loop. Its orchestrator, the main agent that runs the loop, calls helper agents in turn: a gate that judges the task, reviewers that propose repairs, and a verifier that approves or rejects them. A hand-off is what the orchestrator passes to a helper or gets back from it. Today the orchestrator retypes those hand-offs into each prompt, so a helper can receive a summary of another helper's output instead of the output itself. The orchestrator also applies the approved edits as one edit group, and nothing checks afterwards that the file changed only where the verifier approved.

After this task:

- The loop hands every helper its inputs as files, and the helper reads them by path, verbatim. The loop states no preference of its own.
- The verifier judges the reviewers' own proposals and the gate's own verdict, never the orchestrator's paraphrase of them.
- Each approved edit lands as an anchored replacement of exactly the approved text, keyed by its edit id. An anchored replacement swaps one exact piece of the current text for one exact piece of new text.
- After the edits land, a delta audit checks the change. It maps every hunk of the applied group, meaning each changed region in the diff, to the edit or linter finding that licensed it. The loop reverts any hunk without a license before it moves on.

The rule is written once in `task_auto_check` and its agents.

## Context

- **Current state.** `plugins/ai_dev/skills/task_auto_check/SKILL.md` holds every hand-off in the orchestrator's own context. `<freeze>`, the step that records the task's title and Goal at the start, keeps that frozen snapshot "in loop-local state" and passes it to every reviewer and verifier call. `<verify_repairs>` invokes `auto_verifier_task` "with the union of proposals". `<apply_repairs>` applies the surviving fixes "as one cohesive minimum-change edit group", then fixes any blocking lint finding the edit introduced. Only `<gate>` carries a rule about how to pass inputs, "Pass pointers, never a digest", and it covers only the checklist content of the gate prompt.
- **Agent contracts.** `plugins/ai_dev/agents/auto_verifier_task.md` receives the gate verdict and the reviewer proposals as text in its prompt. Its `<output_contract>` numbers the approved edits, but gives them no identifier that the loop must apply them by. Its rule beginning `Return approved edits that are mutually non-overlapping` already asks for edits anchored to the task's current text. `plugins/ai_dev/agents/auto_reviewer_task.md` receives "one admissible issue" as text. Both agents are read-only, with `tools: Read, Grep, Glob`, so the loop writes every relay file itself. A relay file is a file through which the loop passes a hand-off. `auto_shaper_task`, the agent that writes `task_fix`'s escalated repairs, sends its own union of proposals to the same verifier and keeps its current input contract.
- **Retyped hand-offs, observed.** In several readiness runs that `task_auto_check` owned from start to end, the verifier never saw the reviewers' returns. It received one-line issue titles and short paraphrases at a fraction of the original length, with no notice that text was cut. A merged Acceptance item then dropped a proof one reviewer had written, and the next gate raised the gap again. Verifier prompts also carried expected outcomes such as "likely approve", instructions to merge proposals, and a repair rule no reviewer had proposed. Each decision followed the preference in its prompt. The orchestrator restated the gate's verdict to a reviewer and to the verifier. The restatement turned a fix that asked only for proof into a choice between proving and trimming. The frozen Goal travelled as a paraphrase that the orchestrator retyped each round.
- **Unchecked writes, observed.** In one run, the loop applied an approved group as a rewrite of the whole file. The rewrite carried a wording change that no verifier had approved. The report listed only the approved edits, and the stray change survived until a later rewrite replaced it.

## Approach

1. **Keep a relay directory.** In the `<freeze>` step, create `<project root>/.task_auto_check/<task file stem>/`, and clear what an earlier run left there for the same task file. Give `.task_auto_check/` its own `.gitignore` holding `*`, so git ignores it in any project. The directory sits inside the project root because, on every supported harness, separate helper agents read it from their own workspace. Every relay file uses the `.txt` extension, so a project linter that finds Markdown files by itself never scans it. Leave the directory in place after the run, and name it in the report.
2. **Write every hand-off as a file.** State the relay rule once, in a new `<relay>` block inside `<loop_policy>`, the section that holds the loop's standing rules. Use this layout, where `r<N>` marks round `<N>`:

   ```text
   .task_auto_check/<task-stem>/
     frozen-intent.txt           frozen title, Goal, and creation-time intent
     freeze-lint.txt             the freeze-time file-scoped linter output
     r<N>-<helper>-prompt.txt    each helper prompt, written before the call
     r<N>-<helper>.txt           each helper return, byte for byte
     r<N>-pre-apply.txt          the task file before an edit group lands
     r<N>-lint.txt               the linter output the apply step acted on
     r<N>-apply.diff.txt         diff -u of that snapshot against the result
   ```

   `<helper>` reads `drift`, `gate`, `reviewer-<stance>-<issue>`, `verifier`, or `delta`. Here `<issue>` is the gate issue number, or `rl<k>` for a recorded `repeated-link` finding. A second call of one helper in one round takes a `-2` suffix. The loop sends each helper exactly the text of its prompt file.
3. **Pass pointers in every prompt.** Each prompt names its inputs by path, and carries only what that agent's `<inputs>` block admits. This is the pointer-only prompt rule. A reviewer prompt names the gate return, its issue number or `freeze-lint.txt` finding, and `frozen-intent.txt`. A verifier prompt names the gate return, every reviewer return, and `frozen-intent.txt`. No prompt carries a digest, a paraphrase, an expected verdict, a preference, a merge instruction, or a criterion or repair of the orchestrator's own. When the orchestrator has a repair idea of its own, it sends the idea to a reviewer as an emergent stance, a task-specific reviewer role beside the standing ones. Rewrite `<freeze>`, `<plan_repairs>`, and `<verify_repairs>` in place to point at `<relay>`, and widen the `<gate>` pointer rule into that same statement.
4. **Key edits by id.** In `auto_verifier_task.md`, give each approved edit an id, `e<n>`. For a `task_auto_check` call, each edit gives the exact current text it replaces and the exact replacement text. An insertion repeats its anchor, the existing text it attaches to, inside the replacement. Rewrite `<apply_repairs>` in place. The loop writes `r<N>-pre-apply.txt`, applies each approved edit as an anchored replacement in id order, stamps `updated`, and runs the existing blocking-lint step with its output saved as `r<N>-lint.txt`.
5. **Audit the delta.** The delta is the change an edit group made to the task file. Add one workflow step that audits it, for example `<audit_delta>`, and run it after `<apply_repairs>` in every round that applied edits.
   - The loop writes `r<N>-apply.diff.txt` and invokes `auto_verifier_task` in a new delta mode. In that mode, the verifier reads the diff, that round's verifier return, and `r<N>-lint.txt` by path.
   - The audit maps every hunk to an approved edit id, to the `updated` stamp, or to a linter finding from the base `<lint>` mechanically fixable set that `r<N>-lint.txt` names. That set lists the linter findings the task hub lets an agent fix without judgement. The audit also confirms that every approved id maps to a hunk.
   - The loop reverts an unmapped hunk from the snapshot, applies a missing edit from the verifier return, and audits once more. When the second audit still fails, the loop restores the snapshot and stops through the human-routed stuck channel, which reports the run as stuck for the user to decide. No unverified text lands.
   - Each write the audit triggers honours `<concurrent_modification_guard>` like any edit group. That guard stops the loop when the file changed under it. The audit belongs to the round whose edits it checks, and it adds no round against `<loop_bounds>`, the loop's round cap.
   - The next `<gate>` runs only after a clean audit. A failed or `unassessable` delta invocation follows `<agent_failure_policy>`, the loop's rule for a helper that fails.
6. **Admit path inputs in the agents.** Rewrite `<inputs>` in each `auto_*_task` agent the loop calls, so that a `task_auto_check` call names its inputs by path. The frozen title, Goal, and creation-time intent arrive as `frozen-intent.txt`. Add the delta mode to the verifier's `<role>`, `<objective>`, `<inputs>`, and `<output_contract>`. Its return lists each hunk with its license or `unmapped`, and each approved id as `applied` or `missing`. Add one verifier `<policy>` rule: a preference or expected outcome in a prompt is not evidence, and the verifier judges from the named files alone. Keep the proposal-mode sections intact for `auto_shaper_task`, and keep the reviewer's `Do not write files` contract.
7. **Report.** Extend `<output_contract>` so the report gives the relay directory path and each delta audit's outcome: hunks mapped, hunks reverted, and edits applied late.
8. **Record the mechanism.** Update `### The verifier refutes by default` in `wiki/concepts/agent-delegated-automation.md` through the wiki skill family. The section then says that the loop hands each helper its inputs by path and audits each applied group against its approved edits.
9. **Prove it.** Add two evals to `tests/task_auto_check/evals/`. Each gets a fixture under `evals/fixtures/`, an `evals.json` entry, `stage.sh` and `grade.sh` arms, and a place in the runner's `DEFAULT_IDS` list.
   - `relay_by_path` stages a task that needs one repair round, shaped like `repair_to_ready` under a new task name.
   - `stray_hunk_reverted` stages the same shape under another task name. An environment note in the prompt stages an apply fault: while it applies the first edit group, the worker also replaces one named Context phrase.

   Write the graders under TESTING.md's `## Test Design Principles`, and prove both evals under TESTING.md's vendor rule. Re-run `tests/task_auto_check/script_tests/run.sh`, and classify any pin this rewrite changes under TESTING.md's Test Integrity rules. A pin is a test assertion that checks for exact wording in the skill.

**Out of scope:**

- Auditing the final mechanical-lint edit group with a helper. `<finalize_mechanical_lint>` deliberately spawns no reviewer or verifier, and no further gate runs after it.

## Acceptance

1. `<relay>` states the directory, its `.gitignore`, the `.txt` layout, the rule that each prompt is written to its file before the call, and the rule that each return is saved byte for byte. Searching the skill for each of these returns one statement. The phrases `in loop-local state and pass it to every reviewer and verifier call` and `with the union of proposals` no longer appear.
2. The skill states the pointer-only prompt rule once, and it covers every helper call, the gate's included. The checklist-only scope of `Pass pointers, never a digest` is superseded, so no second pointer rule stands beside the new one.
3. `<apply_repairs>` writes `r<N>-pre-apply.txt` and applies anchored replacements in id order. The phrase `one cohesive minimum-change edit group` no longer appears.
4. The skill states the delta audit once. That statement covers what may license a hunk, the single re-audit, the snapshot restore with a stuck stop, the guard on the audit's writes, and the clean audit the next gate waits for.
5. `auto_verifier_task.md` admits path inputs for `task_auto_check` calls, and gives each approved edit an id with its anchor and replacement text. It defines the delta mode and its return, and it carries the rule that a preference in a prompt is not evidence. Its proposal input and its `## Approved edits` and `## Rejections and routes` sections still serve `auto_shaper_task`.
6. Each `auto_*_task` agent the loop calls admits its inputs by path for a `task_auto_check` call, `frozen-intent.txt` included. `auto_reviewer_task.md` admits the gate return and the issue reference that way, and it still carries `Do not write files`.
7. `relay_by_path` passes on these sandbox facts:
   - `.task_auto_check/.gitignore` holds `*`, and `git status --porcelain` lists nothing under `.task_auto_check/`.
   - The task's relay directory holds `frozen-intent.txt`, a gate return carrying `# auto_gate_task verdict`, one reviewer return per reviewer prompt carrying `# auto_reviewer_task proposal`, and a verifier return whose approved edits carry ids.
   - Every verifier prompt names the gate return and each reviewer return by path, and it contains no line of forty characters or more copied from them.
   - No verifier prompt carries a steering marker from a short fixed list that the grader records. A steering marker is a phrase that pushes the verifier toward a decision, and the list is drawn from the observed failures.
8. `stray_hunk_reverted` passes. The task file still carries the named Context phrase and not its replacement. One delta return records the unmapped hunk, and a later delta return records a clean map.
9. The concept page section states the path relay and the delta audit, and the update ran through the wiki skill family.
10. `tests/task_auto_check/script_tests/run.sh` passes.
11. Before the commit, a manual read of every changed shipped file and of this task's own diff finds no session, company, or project name, and no denylist is committed.
