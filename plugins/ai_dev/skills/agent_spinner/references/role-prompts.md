# Role prompt templates

Five templates: the invariant preamble every pass carries, and the four role
prompts `agent_spinner` dispatches. Each role prompt assembles from the three
parts `<prompt_assembly>` defines, namely the invariant preamble, a
hand-written per-item brief, and a kind note where the item's class needs one.

Every template's first line is the pass's first concrete action, and each
prohibition is stated as something the pass does. That is what lets the same
contract work whether the host runs the pass in its own context or inline in
this one, because a role body can arrive with no standing authority over the
conversation around it.

## Invariant preamble

Reused unchanged across producing and checking passes. Fill the bracketed
slots once per run.

```text
Read [corpus pointer] before writing anything.

Vocabulary: [the three to six terms this run keys on, one clause each].

Severity ladder, highest first: blocker (the artifact is wrong or unusable),
major (a stated requirement goes unmet), minor (a real defect that changes no
decision), note (an observation worth recording).

Settled facts, taken as given rather than re-derived: [the facts already
established this run].

Return your result in the shape the brief below names. Perform your own item
and delegate no part of it; work you cannot complete comes back as an
out-of-scope finding.
```

## Producing pass

```text
Read [the one target path], then read [CHARTER.md or the named boundary
document] where the repository carries one.

[invariant preamble]

Your target path: [exactly one path].

Situation: [what stands at that path today].
Target state: [what it reads like when this item is done].

Write only [the one path]. Leave these untouched: [the neighbouring artifact
classes]. Check your planned edit against the boundary document first; on a
conflict, write nothing, leave the file byte-for-byte unchanged, and report the
conflict.

Finish within [the wall-clock bound].

Return: the item identifier [role:item], what you changed, what you examined
and cleared, and any out-of-scope finding.
```

## Lens pass

```text
Read [the identical corpus every lens reads] under the lens named below.

[invariant preamble]

Your lens: [lens name]. The question it asks: [one sentence].

Sibling passes cover the other angles, so spend your effort on depth under
this lens rather than breadth across the others.

Return: findings under this lens only. Each finding carries a verdict from
{confirmed, likely, refuted}, a confidence, a verbatim quote, a path with a
heading or symbol anchor, and a severity from the ladder above. Close with
what this lens examined and cleared. An empty finding list is a valid and
expected result.
```

## Checking pass

```text
Read the producer's report below in full, then read [the artifact] itself.

[invariant preamble]

Producer's report, verbatim:
[report]

Open from this position: the work is incomplete or wrong. Concede it only
after running this checklist, and cite the span that settled each line:

1. [check one]
2. [check two]
3. [check three]

A clean verdict that cites no span routes back for re-checking, which costs
the run another pass, so weigh the citation you give rather than reaching for
the clean line. Narrow an overstated claim to what the artifact supports
instead of killing it, and carry the narrowed wording into your return.

Work read-only, using [the named read-only operations]. Where running a
command needs approval rather than being refused outright, stay clear of shell
use and read the files directly.

Return: a verdict per checklist line with its citing span, the findings in the
shape the lens template names, and the narrowed wording for any claim you
narrowed.
```

## Synthesis pass

```text
Read the digests below, keyed by item identifier.

[invariant preamble]

[digests, capped at [N] characters each]

Your material may have been cut at that cap. Re-read anything load-bearing
from the source at [corpus pointer] rather than resting on the digest. These
identifiers had detail trimmed: [identifiers].

Union the proposals: two passes raising the same item is shared priors rather
than confirmation, so keep each proposal and send it through its own check.
Join and partition by item identifier rather than by arrival order. Keep every
discarded finding with its one-line reason.

Return: the verdict, the claim it rests on, and the three lists kept apart:
what the run established, what a pass found beyond its brief, and what a pass
decided on its own authority.
```
