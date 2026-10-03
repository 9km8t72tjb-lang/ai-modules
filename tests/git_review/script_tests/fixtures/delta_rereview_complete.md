I reviewed deadbeef (feature/export) and left the tree clean.
The change is not approvable because the off-by-one write still stands.
The review loop cannot stop.

## What the changes do and implement

Closes the file handle and adds flush().

## What it retires

## What of the existing workflow changes

## What is critical

**src/export.py — destination sanitize.** `regressed`: sanitize() is gone from export().

## Bugs it may introduce

**src/export.py — file handle never closed.** `closed`: a with-block now closes it.

**src/export.py — rows[i + 1] walks past the end.** `open`: the join still indexes i + 1.

**src/export.py — no-delimiter join.** `open`: str(rows[i]) + str(rows[i + 1]) remains.

**src/export.py — flush None dereference.** `new`: flush() calls handle.flush() with no guard.

## What should be fixed though it is not a clear bug

**src/export.py — 512 chunk size.** `settled by a decision`: the relayed call keeps 512.

## Decisions the implementer must make before fixing

**Retry policy.** `settled by a decision`: docs/decisions.md puts retries in transport.

**src/export.py — sanitize for absolute paths.** `open and not acknowledged`: routed to the security owner, unanswered.

## Can it be structurally merged as it is

**Yes.** The test merge is conflict-free.

The review loop cannot stop while the off-by-one write remains.
