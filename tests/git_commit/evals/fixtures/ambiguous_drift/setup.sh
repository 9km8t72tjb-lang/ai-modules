#!/usr/bin/env bash
# Eval 7 fixture: ambiguous same-path drift.
#
# Reuses eval 6's marker-gated writer with one change: both the
# pre-existing dirty state and the background write target a path that is
# ALREADY present in the reviewed-set baseline. seed.txt is dirtied before
# the agent starts, so it appears in the <status_after_staging_new_files>
# snapshot; the detached writer then re-edits that SAME path after the
# prepare wrapper touches the baseline marker. No path outside the
# baseline newly appears, so the drift check cannot tell foreign drift
# from this session's own further edit — the ambiguous case.
# git_commit's tiebreaker must commit all (no pause) and the commit must
# include that path's latest content, proving no file is silently dropped.
#
# Layout staged at $1 (eval sandbox root, same shape as eval 5 / eval 6):
#   repo/                 git repo the agent commits in
#   skill_under_test/     git_commit copy with prepare wrapped to touch
#                         .eval/baseline_captured after a successful run

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required (eval sandbox root)}"
rm -rf "$target"
mkdir -p "$target"
target="$(cd "$target" && pwd)"

repo="$target/repo"
skill_dest="$target/skill_under_test"
marker="$target/.eval/baseline_captured"

init_sandbox "$repo"

# Pre-dirty a tracked file so it is already present (as modified) in the
# reviewed-set baseline the script captures.
(
    cd "$repo"
    printf 'baseline dirty edit\n' > seed.txt
)

install_skill_with_prepare_marker "$skill_dest" "$marker"

# Concurrent session re-edits that SAME tracked file after baseline
# capture, appending a distinctive marker line. Because seed.txt is
# already in the baseline, no path outside it newly appears.
seedfile="$repo/seed.txt"
append_marker='CONCURRENT_APPEND_MARKER'
start_marker_gated_writer "$marker" \
    "printf '%s\n' $(printf %q "$append_marker") >> $(printf %q "$seedfile")"

echo "Eval 7 sandbox staged at $target"
echo "  baseline-dirty file: seed.txt (already in the reviewed-set baseline)"
echo "  skill (prepare marker-wrapped): $skill_dest"
echo "  detached writer appends '$append_marker' to seed.txt after baseline marker $marker"
