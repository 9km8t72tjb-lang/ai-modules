#!/usr/bin/env bash
# setup.sh stages the connected_rewrite fixture.
#
# Usage: setup.sh <target_dir>
#
# Writes <target_dir>/proj/draft.md, a synthetic argumentative draft of about
# 400 to 500 words with no real-world names. The header comment above this
# usage block is the inventory of relations and shapes the draft carries:
#
# - a contrast joined by "but" inside one sentence of about 25 to 30 words
# - a two-reason "because …, and because …" sentence
# - a condition introduced by "only if"
# - a colon-introduced series of three parallel items: intake, review, release
# - an appositive that defines "canary" at first use
# - a paragraph whose two supporting figures come after its claims
# - a section whose conclusion comes last after its arithmetic
# - a term, "shadow share", used in an earlier section and defined only in a later one

set -euo pipefail

target="${1:?target dir required}"
mkdir -p "$target/proj"
proj="$(cd "$target/proj" && pwd)"

cat >"$proj/draft.md" <<'EOF'
# How the release gate decides

The operator starts from a canary, a release that reaches a small share of users first, and the gate stays shut until that share has something to say. The new build can pass every automated check in the gate, but a quiet failure in one client library still reaches users who never opted into the trial. The gate holds the release because the shadow share is still climbing, and because the error count in that share has not yet fallen below the rollback line. The release advances to the full user base only if the shadow share stays under the error line for a full day. The gate checks three signals: intake, review, and release.

Intake asks whether the build is the one the operator named. Review asks whether the checks that already ran still describe this build. Release asks whether the share that has seen the build is wide enough to trust and still quiet enough to continue. Those three questions are one decision. A build that fails intake never reaches review, and a build that fails review never reaches the users past the canary. The operator keeps the gate on that order so a late failure cannot hide an earlier one.

The client library is the case the automated checks miss. The checks run inside the service, against the build the service holds. A library that lives in a caller can still speak the old contract after the service has moved on. The trial the user never opted into is then the only place that mismatch appears, which is why a green check is not the same thing as a quiet caller. The gate exists so that mismatch has a place to show up before the rest of the user base sees the build. A green run of the checks is only the start of that decision.

The quieter signal should decide, and the review asked for that choice in so many words. Support tickets stayed flat through the watched hours. The error count in the shadow share fell from 40 in the first hour to 6 in the third.

## What the counts add up to

The first hour saw 40 errors across 800 requests, which is 5 in every 100. The third hour saw 6 errors across 800 requests, which is under 1 in every 100. The shadow share is therefore inside the rollback line, and the release can advance.

## The term the earlier sections used

The shadow share is the portion of traffic that sees the new build while the old build still serves the rest. The count above is a count of that portion, and the rollback line is the error rate that portion is allowed to reach before the gate sends the build back.
EOF

printf '%s\n' "$proj"
