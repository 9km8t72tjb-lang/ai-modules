# Lower-frequency variants

Two shapes that earn their cost rarely. Reach for them when the run's specific
failure mode calls for them, rather than by default.

## Information isolation between concurrent helpers

**When.** Two or more helpers work the same question at once and the run needs
their looks to stay independent, because a shared intermediate turns two
independent looks into one look plus an echo.

**How.** Give each helper the source material and its own brief, and give it
nothing a sibling produced. Withhold sibling identities, sibling counts, and
any running tally. Where a helper needs a fact a sibling also derived, hand it
the source span rather than the sibling's rendering of it.

**Cost.** Isolation buys independence and spends re-derivation: each helper
pays again for the same reading. Spend it where the independence is the point,
such as a paired refute-by-default check, and skip it where a shared preamble
of already-settled facts is what keeps the passes consistent.

**Return.** Each helper returns its own findings with its own citations. The
orchestrator unions them and sends each through its own check, because two
isolated helpers agreeing still measures shared priors rather than truth.

## Replicated draws returned unreduced

**When.** One indivisible factual or arithmetic claim carries the verdict, and
a single draw's variance is the risk. `<width>` reserves replication of an
identical prompt for exactly this case.

**How.** Send the identical prompt N times, with N stated before dispatch.
Ask each draw to show its own derivation: the span it read, the steps it took,
and the value it reached.

**Return.** Report the draws unreduced, one line each, with its derivation. A
majority, an average, or a "3 of 5 agree" line is the reduction this variant
exists to avoid, because agreement among draws of one model measures shared
priors rather than confirmation.

**Reading the result.** Draws that agree and derive the value the same way
raise confidence in the reading. Draws that agree by different derivations are
the stronger signal. Draws that disagree hand the orchestrator a real fork:
re-derive the claim against the source, and report which derivation the source
supports.
