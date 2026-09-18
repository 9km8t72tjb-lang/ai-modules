---
description: Gate the repeated-link and size checks to live task bodies, and rewrite the rules describing them so an archived finding is never reported rather than reported as a count nobody acts on.
scope: plugins/ai_dev/skills
created: 2026-09-18T21:27:49
updated: 2026-09-18T21:27:49
status: open
reported-by: Andreas Hoffmann
---

# Make the body-prose lint checks live-only, in the script and in the rules

## Goal

The archive-inclusive lint run reports findings on archived task bodies that no surface will ever repair, and the rules around those findings describe that non-action as a reporting duty rather than admitting it is one. Two checks produce them: the repeated-link warn and the oversized-page warn. Both are repaired by rewriting a task body's prose, and an archived body is a closed record that nobody rewrites. Today they account for the large majority of what the archive-inclusive run prints, so the run's output trains its reader to skim past warnings instead of acting on them.

After this task the two checks return nothing for an archived page, and the instruction set says so as a rule. Both halves are required and neither is sufficient alone. The wiring half stops the findings being produced. The rules half stops the surrounding text from describing a non-action as something to perform: the react protocol stops routing archived findings to a count, the disposition-line contract stops requiring that count, and the archive close-out stops telling its reader which unfixable warns to expect. In place of those per-finding instructions the base skill states the scope rule once, so a check added later lands on the correct side by reading one rule rather than by copying a neighbour.

The archive-inclusive run keeps every check whose repair is mechanical metadata, which is what that mode exists for.

## Context

The linter already draws this line for a third check, and its stated reason is the one this task generalises. `check_no_position_claims` opens its body with `if is_archived(tasks, page):` returning an empty list, and its docstring carries the rationale verbatim:

```text
Open tasks only — archived pages are closed records nobody maintains, so
checking them would only create permanent noise.
```

The two checks missing that guard are `check_repeated_links`, which already receives the tasks root and so can call `is_archived` directly, and `check_size`, whose signature takes the page alone and needs the tasks root threaded in along with its call site in the page walk.

The scale is what makes this worth doing. Of the repeated-link findings the archive-inclusive run currently reports, the large majority sit on archived bodies, and every oversized-page finding does. Gating both leaves the archive-inclusive run reporting only what a maintainer can act on, and its remaining output equals the live run's for these two checks.

The rules layer carries four passages that exist only to manage findings this task stops producing. In the base `task` skill, the `<lint>` warn bucket lists both checks without a scope qualifier; the **Repeated-link react protocol** ends by routing an archived finding to a count with its body left as archived; the **Repeated-link disposition line** block defines a count line shape for archived findings; and the `<archive>` close-out step tells its reader that the file-scoped run surfaces that file's own size and repeated-link warns, which close-out does not require cleared. In `task_fix`, the `<output_contract>` requires that archived count line in every report. Each passage is an instruction to handle output that will no longer exist.

One case must survive the change, and gating on the linked *file's* own location is what preserves it. A live task that links one archived target several times draws its finding on the live body, so it stays reported and stays repairable. Only a finding whose own page is archived goes silent.

The scope rule this task states belongs in the base `task` skill, because the standing repo rules place a rule governing a whole skill family in that family's base skill so the siblings inherit it. The rule's content is the dividing line the linter now draws in three places: a check whose repair rewrites an archived body's prose runs on live pages only, while a check whose repair is mechanical metadata runs archive-inclusive. Frontmatter completeness, provenance backfill, status validity, legacy archived-status migration, status and location consistency, filename collisions across both roots, and datetime normalisation all sit on the mechanical side and are the stated purpose of the archive-inclusive mode.

Coverage for the linter's rule set lives in `tests/task/script_tests/run.sh`, whose case groups already include one for the size check, so the new scenarios extend that harness rather than starting another.

The live task [repo-wide link integrity](task-family_repo-wide-link-integrity.md) edits the same script and the same rules-layer passages, widening the page walk from task files to every repo file. It states that the repeated-link warn keeps its current per-file behaviour, so the two tasks do not contradict each other, but a wider walk changes what "archived" means for a page that is not a task file at all. Whichever lands second reconciles the gate against the walk it finds.

## Approach

Add the `is_archived` guard to both checks, matching the existing one in wording and placement, and give each docstring the same one-sentence reason so the three checks read alike. Thread the tasks root into `check_size` and update its call in the page walk.

Rewrite the four rules-layer passages so each states the scope rather than managing the output. In the base skill's `<lint>` warn bucket, qualify both checks as live-only where the bucket currently lists them unqualified. Rewrite the **Repeated-link react protocol**'s closing sentence so it states that the check does not fire on an archived body, replacing the routing of such a finding to a count. Remove the archived count line from the **Repeated-link disposition line** block, leaving the per-finding shape that live findings still use. Rewrite the `<archive>` close-out step so it no longer names size and repeated-link as warns the file-scoped run surfaces, keeping the step's existing requirement that blocking findings for the moved file are resolved. In `task_fix`, remove the archived count line from the `<output_contract>` and leave the per-finding reporting requirement standing for live findings.

State the scope rule once in the base skill's `<lint>`, beside the mechanically fixable finding set it already defines, in the two-sided form the **Context** gives: a check repaired by rewriting an archived body's prose runs on live pages only, and a check repaired by mechanical metadata runs archive-inclusive. Write it so a future check is classified by reading it, rather than as a list of the three checks that currently qualify.

Extend `tests/task/script_tests/run.sh` with the scenarios the Acceptance names, following the scratch-fixture pattern its existing size-check group uses.

**Out of scope:**

- The soft-pointer check, which already carries the guard this task copies and needs no edit beyond being cited as the precedent.
- Reclassifying any check currently on the mechanical side. The rule this task states describes where the three body-prose checks already sit once the two guards land, and moves nothing else.
- The wiki linter's equivalent checks, a separate tool with its own walk and its own archive convention.
- Widening the page walk beyond task files, which the live sibling task named in **Context** owns.

## Acceptance

- `check_repeated_links` and `check_size` each return no findings for a page under `tasks/archive/`, verified on a staged archived fixture that carries one target linked several times and a body past the split threshold, where both currently report.
- The same two fixtures placed under `tasks/` still report both findings, so the gate narrowed by location rather than removing the checks.
- A live task body linking an archived target several times still reports its repeated-link finding, proving the gate keys on the linking page's own location.
- An archive-inclusive run over this repository's tasks tree reports the same count as the live run for these two checks, and its remaining findings all name pages under `tasks/`.
- An archive-inclusive run still reports a staged archived fixture carrying a frontmatter, provenance, status-validity, status-location, datetime, or filename-collision defect, so the mechanical side of the mode is untouched.
- A file-scoped run against an archived page reports neither check, and the close-out step's text no longer tells its reader to expect them.
- The base skill's `<lint>` states the live-only scope for both checks in the warn bucket, and carries the two-sided scope rule beside the mechanically fixable finding set, phrased so a check not yet written can be classified by it.
- No passage in the base skill or in `task_fix` instructs a reader to report, count, or otherwise handle a repeated-link finding on an archived task; the superseded wording is gone rather than sitting beside the new text.
- The per-finding repeated-link disposition line shape survives unchanged for live findings, and `task_fix`'s output contract still requires it.
- `tests/task/script_tests/run.sh` carries the scenarios above and passes.
