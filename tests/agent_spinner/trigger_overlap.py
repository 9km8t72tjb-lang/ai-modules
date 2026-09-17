#!/usr/bin/env python3
"""Name the trigger-eval sets whose queries can compete with agent_spinner.

The deploy-time regression sweep in RUNBOOK.md is worth its cost only against a
set whose queries share vocabulary with this skill's deployed `description:`. A
set with no overlap cannot bleed, so re-running it re-measures its own sampling
noise, which is the case TESTING.md's re-run economy rule excludes.

Prints one `<set> <n>` line per qualifying set, and nothing when none qualifies.
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

# The trigger words this skill's description actually competes on.
VOCAB = re.compile(
    r"\b(helpers?|agents?|sub-?agents?|fan[- ]out|parallel|orchestrat\w*"
    r"|dispatch\w*|verif\w*|cross-check\w*|aggregat\w*|lens|judge|roster"
    r"|spawn\w*)\b",
    re.I,
)

SETS = pathlib.Path(__file__).resolve().parents[1] / "trigger_evals"


def main() -> int:
    qualifying = 0
    for path in sorted(SETS.glob("*.json")):
        if path.stem == "agent_spinner":
            continue
        hits = [q["query"] for q in json.loads(path.read_text())
                if VOCAB.search(q["query"])]
        if hits:
            qualifying += 1
            print(f"{path.stem} {len(hits)}")
            for q in hits:
                print(f"    {q}")
    if not qualifying:
        print("no set overlaps this skill's description; the sweep buys nothing",
              file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
