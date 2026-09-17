# Degradation examples

One job worked at two tiers. The quality contract is identical; the mechanism
is not. Read these alongside `<degradation>` in the skill body.

## The job

Nine markdown files under `docs/` have drifted from the commands they
document. The ask: find the drift and report it, changing nothing.

## At full fan-out

1. **Probe.** A delegation surface is callable, a depth control is available,
   concurrent execution is available, and a host-enforced read-only lever is
   absent.
2. **Announce.** Three phases, nine items, a four-minute per-helper bound,
   nine included and two excluded (`docs/CHANGELOG.md` is generated,
   `docs/index.md` documents no command).
3. **Roster.** Nine lines written to a scratch file before dispatch, each with
   its identifier, its one path, and the state `dispatched`.
4. **Survey.** Nine helpers, one per path, each carrying the invariant
   preamble, its single path, the negative list, and the no-further-delegation
   clause. Each returns findings and what it cleared.
5. **Check.** One checker per survey that raised a finding, each receiving the
   producer's report verbatim and opening from the refute-by-default position.
6. **Synthesise.** The orchestrator unions the cleared findings, keys them by
   identifier, re-derives the one claim the verdict rests on, and writes the
   closing report.

## At the inline floor

1. **Probe.** No delegation surface is callable. Every other capability
   resolves to absent. The opening sentence says so.
2. **Announce.** The same three phases, the same nine items, the same bound,
   the same inclusions and exclusions. The plan is the mechanism's input, not
   its output, so it does not change with the tier.
3. **Roster.** The same nine lines, written to the same scratch file. The
   roster matters more here, not less: one context holding nine passes is
   exactly where an item goes quietly unattributed.
4. **Survey.** Nine separately prompted passes in this context. Each pass
   opens on its own brief, reads its one path, and closes on its own return
   contract before the next brief is read. Nothing carries over between passes
   except what the roster records.
5. **Check.** The same refute-by-default pass per finding, prompted
   separately, receiving the producing pass's report verbatim as text rather
   than as remembered context.
6. **Synthesise.** Identical. The re-derivation step matters more here,
   because a single context can agree with itself by recall.

## What the floor gives up, stated out loud

The floor buys the same coverage at a different cost, so name the difference
rather than implying equivalence:

- A pass can recall an earlier pass's reasoning instead of re-deriving it, so
  a finding the checking pass was shown reads as recall-confirmed and carries
  less weight.
- No process boundary holds a reading pass to reads, so the read-only
  contract rests on the prompt alone, which `<prompt_assembly>` writes as an
  action for exactly this reason.
- The passes run one after another, so the run takes longer. The skill claims
  no wall-clock benefit from fan-out either way, because no concurrency
  contract is established for any host.

## The governed exception

Where a named skill governs the run and states its own stop-and-ask boundary
for a host with no spawn surface, the floor does not apply to that run. Offer
that skill's manual routes, perform no helper role inline, and say which
boundary held.
