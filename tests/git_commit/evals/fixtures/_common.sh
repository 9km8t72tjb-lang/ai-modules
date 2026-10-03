#!/usr/bin/env bash
# Shared helpers for git_commit eval fixtures.
#
# Each fixture sources this file, then calls `init_sandbox "$1"` to get
# a fresh git repo at the target dir with one seed commit.

set -euo pipefail

_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

init_sandbox() {
    local target="$1"
    if [[ -z "$target" ]]; then
        echo "init_sandbox: target dir is required" >&2
        return 2
    fi
    rm -rf "$target"
    mkdir -p "$target"
    (
        cd "$target"
        git init --quiet --initial-branch=main
        git config user.email "evals@example.com"
        git config user.name "Evals"
        printf 'seed\n' > seed.txt
        git add seed.txt
        git commit --quiet -m "seed"
    )
}

# Copy the git_commit plugin skill into <skill_dest> and wrap
# prepare_commit_context.sh so a successful run touches <marker_abs>
# after the real prepare finishes (stdout protocol unchanged). Drift
# fixtures use the marker to fire a concurrent write without a fixed
# sleep race against worker latency.
install_skill_with_prepare_marker() {
    local skill_dest="$1" marker_abs="$2"
    local harness_root skill_src marker_dir
    if [[ -z "$skill_dest" || -z "$marker_abs" ]]; then
        echo "install_skill_with_prepare_marker: skill_dest and marker_abs required" >&2
        return 2
    fi
    harness_root="$(git -C "$_COMMON_DIR" rev-parse --show-toplevel)"
    skill_src="$harness_root/plugins/ai_dev/skills/git_commit"
    if [[ ! -d "$skill_src" ]]; then
        echo "install_skill_with_prepare_marker: cannot find git_commit skill at $skill_src" >&2
        return 1
    fi
    rm -rf "$skill_dest"
    cp -R "$skill_src" "$skill_dest"
    mv "$skill_dest/scripts/prepare_commit_context.sh" \
        "$skill_dest/scripts/prepare_commit_context.sh.real"
    marker_dir="$(dirname "$marker_abs")"
    cat > "$skill_dest/scripts/prepare_commit_context.sh" <<EOF
#!/usr/bin/env bash
# Eval harness wrapper: run the real prepare, then signal baseline capture.
set -uo pipefail
here="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
"\$here/prepare_commit_context.sh.real" "\$@"
status=\$?
if [[ \$status -eq 0 ]]; then
  mkdir -p $(printf %q "$marker_dir")
  : > $(printf %q "$marker_abs")
fi
exit \$status
EOF
    chmod +x "$skill_dest/scripts/prepare_commit_context.sh"
}

# Detach a writer that waits until <marker_abs> exists, then runs
# <write_cmd> via bash -c. Optional GIT_COMMIT_DRIFT_MARKER_TIMEOUT
# (default 240s) bounds the wait; optional GIT_COMMIT_DRIFT_POST_MARKER_DELAY
# (default 0) is a settle sleep after the marker before the write.
start_marker_gated_writer() {
    local marker_abs="$1" write_cmd="$2"
    local timeout_s post_delay
    if [[ -z "$marker_abs" || -z "$write_cmd" ]]; then
        echo "start_marker_gated_writer: marker_abs and write_cmd required" >&2
        return 2
    fi
    timeout_s="${GIT_COMMIT_DRIFT_MARKER_TIMEOUT:-240}"
    post_delay="${GIT_COMMIT_DRIFT_POST_MARKER_DELAY:-0}"
    nohup env \
        MARKER="$marker_abs" \
        TIMEOUT_S="$timeout_s" \
        POST_DELAY="$post_delay" \
        WRITE_CMD="$write_cmd" \
        bash -c '
set -uo pipefail
start=$(date +%s)
while [[ ! -f "$MARKER" ]]; do
  now=$(date +%s)
  if (( now - start >= TIMEOUT_S )); then
    exit 0
  fi
  sleep 0.25
done
if [[ "${POST_DELAY}" != "0" && -n "${POST_DELAY}" ]]; then
  sleep "$POST_DELAY"
fi
bash -c "$WRITE_CMD"
' >/dev/null 2>&1 &
}

# Stage a sandbox scaffold that plants one agent-directed pre-commit
# obligation, then commit it so the only dirty path left is whatever
# change the calling fixture makes afterwards.
#
#   plant_obligation_scaffold <target> <gate_name> <rule_paragraph>
#
# Writes and commits:
#   AGENTS.md            the standing rule, addressed to the agent
#   tools/<gate>.sh      observable stand-in for the real gate: it records
#                        that it ran by writing its epoch second to
#                        .eval/markers/<gate>
#   .gitignore           keeps .eval/ out of git status and out of the commit
#   docs/handbook.md     the documentation surface a fixture can edit
#   src/app.py           the Python surface a fixture can edit
#
# The marker is the whole observation: grade.sh reads its presence to tell
# whether the pre-flight relevance test ran or skipped the obligation, and
# its epoch second to tell that a run happened before the commit landed.
plant_obligation_scaffold() {
    local target="$1" gate="$2" rule="$3"
    if [[ -z "$target" || -z "$gate" || -z "$rule" ]]; then
        echo "plant_obligation_scaffold: target, gate name and rule are required" >&2
        return 2
    fi
    (
        cd "$target"
        mkdir -p tools docs src

        printf '.eval/\n' > .gitignore

        cat > AGENTS.md <<AGENTS_EOF
# Sandbox project rules

This repository holds a small Python package under \`src/\` and its handbook
under \`docs/\`.

## Before every commit

$rule
AGENTS_EOF

        cat > "tools/$gate.sh" <<GATE_EOF
#!/usr/bin/env bash
# Observable stand-in for the real gate: it records that it ran.
set -euo pipefail
root="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "\$root/.eval/markers"
date +%s > "\$root/.eval/markers/$gate"
echo "$gate: ok"
GATE_EOF
        chmod +x "tools/$gate.sh"

        printf '# Handbook\n\nHow this project is used.\n' > docs/handbook.md
        printf 'def main():\n    return "ok"\n' > src/app.py

        git add .gitignore AGENTS.md "tools/$gate.sh" docs/handbook.md src/app.py
        git commit --quiet -m "scaffold: standing pre-commit rule and its gate"
    )
}
