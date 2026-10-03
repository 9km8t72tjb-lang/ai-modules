#!/usr/bin/env bash
# Eval 6 fixture: foreign drift from a concurrent session.
#
# A detached background writer drops a NEW file into the working tree
# mid-run — after prepare_commit_context.sh has captured the reviewed-set
# baseline, but before the skill's commit-time drift re-check. That new
# path is outside the baseline, so git_commit's drift guard must surface
# it and PAUSE rather than sweeping it into the commit silently.
#
# Event-driven stand-in for a real second session: the staged skill wraps
# prepare_commit_context.sh so a successful run touches a marker outside
# the repo; the writer polls that marker and only then writes. No fixed
# sleep race against worker latency.
#
# Layout staged at $1 (eval sandbox root, same shape as eval 5):
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

# The in-session work the agent legitimately reviews and means to commit:
# one modified tracked file plus a few new files. A modest multi-file set
# lengthens the agent's consume+compose phase, widening the post-prepare
# window where the marker-gated write lands before the drift re-check.
(
    cd "$repo"
    printf 'in-session edit\n' > seed.txt
    printf 'session note a\n' > session_a.txt
    printf 'session note b\n' > session_b.txt
    printf 'session note c\n' > session_c.txt
)

install_skill_with_prepare_marker "$skill_dest" "$marker"

# Concurrent session: wait for baseline capture, then drop a NEW file the
# agent never reviewed. Marker lives outside the repo so it cannot itself
# appear as foreign drift or get staged into the baseline.
foreign="$repo/concurrent_reorg.txt"
start_marker_gated_writer "$marker" \
    "printf 'concurrent session in-flight file\n' > $(printf %q "$foreign")"

echo "Eval 6 sandbox staged at $target"
echo "  in-session files: seed.txt, session_a.txt, session_b.txt, session_c.txt"
echo "  skill (prepare marker-wrapped): $skill_dest"
echo "  detached writer creates $foreign after baseline marker $marker"
