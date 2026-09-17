# Worked report shapes

The three surfaces a run writes: the opening announcement before the first
helper, the digest the synthesis pass reads, and the closing report.

## Opening announcement

Written before the first helper, after `<capability_probe>` returns.

```text
Capability tier: spawned roles in their own context. Established: a
delegation surface and a depth control. Assumed absent: a host-enforced
read-only lever, and concurrent execution.

Phases:
1. Survey — one helper reads one skill directory and reports its contract.
2. Check — one helper refutes one survey report against the directory.
3. Synthesise — the orchestrator merges the cleared findings.

Items: 5 of 8 candidates. Per-helper bound: 4 minutes.

Included: git_commit, git_review, task_check, task_audit, wiki_import.
Excluded: format_markdown (ships no bundled script, nothing to survey),
spr (out of the named plugin), executive_summary (already surveyed last run
and unchanged since).
```

## Inline-floor opening

The same announcement at the floor. The tier sentence changes; the plan does
not.

```text
Capability tier: inline floor — no delegation surface is callable here, so
each pass below runs as its own separately prompted pass in this context.
Established: nothing beyond reads. Assumed absent: a delegation surface, a
host-enforced read-only lever, a depth control, and concurrent execution.

Phases, items, bound, inclusions, and exclusions: [identical to the spawned
form].
```

## Digest handed to synthesis

One record per item, keyed by the stable identifier the roster carries.

```text
survey:git_commit — 2 findings.
  [major] The prepare script's binary probe runs per path.
    "for f in $changed; do file --mime \"$f\"; done"
    plugins/ai_dev/skills/git_commit/scripts/prepare.sh, fn stage_all
    confidence: high | independently surfaced
  [note] The manual fallback reference carries no size cap.
    ...
  Examined and cleared: frontmatter, the message template, the status-4 path.

survey:task_check — 0 findings.
  Examined and cleared: the checklist wiring, the premise check, the stamp.
```

## Closing report

```text
Five of the five surveyed skills hold their stated contract, reached at the
spawned-roles tier, 11 helpers dispatched against 11 returned.

The verdict rests on one claim: every surveyed skill's bundled script matches
the path its SKILL.md cites. Re-derived against the files rather than the
helper reports. The two findings below were taken on a helper's word and are
labelled as such.

**Established.** git_commit's prepare script probes binaries per path
(re-derived). task_check's premise gate reads the codebase before stamping
(re-derived).

**Found beyond the brief.** The git_review survey noted a stale line in its
plugin README. Recall-confirmed by the checking pass, not independently
surfaced, so it carries less weight.

**Decided on a helper's own authority, for your review.** The task_audit
survey treated a missing RUNBOOK as out of scope rather than as a finding.

Coverage narrowing: the three excluded candidates went unsurveyed, so a
contract drift in format_markdown, spr, or executive_summary would not have
surfaced here. A second phase over those three would surface it.

Yield: 11 helpers dispatched for 2 findings and 1 decision, which is a thin
return for the cost.
```

## Early-stop report from the roster

```text
Stopped after 2 of 4 writers, at the spawned-roles tier, 2 dispatched against
2 returned.

From the roster at .agent_spinner/roster.tsv, settled by reading the files:

- Modified: docs/setup.md, docs/deploy.md.
- Untouched: docs/upgrade.md, docs/rollback.md.
- Unknown at stop, now settled by reading: none.

**Established.** Both modified pages carry the flag NOTES.txt records, verified
against the files after the stop. The remaining two items are unstarted, so the
tree is consistent as it stands.

**Found beyond the brief.** None.

**Decided on a helper's own authority, for your review.** None.

Yield: 2 helpers dispatched for 2 edits.
```

A stop report carries the same closing parts as a completed one. An early stop
is where a reader most needs to tell an empty bucket from a forgotten one, so
the `none` lines and the yield clause stay.
