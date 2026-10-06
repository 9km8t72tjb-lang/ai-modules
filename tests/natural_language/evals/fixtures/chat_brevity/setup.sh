#!/usr/bin/env bash
# setup.sh stages the chat_brevity fixture.
#
# Usage: setup.sh <target_dir>
#
# Writes a short question and a small context file. The context answers the
# question in one sentence. The worker's reply is what the harness grades.

set -euo pipefail

target="${1:?target dir required}"
mkdir -p "$target/proj"
proj="$(cd "$target/proj" && pwd)"

cat >"$proj/context.md" <<'EOF'
The canary reaches one user in twenty.
The rollback line is three errors in the first hour.
EOF

cat >"$proj/question.md" <<'EOF'
What share of users does the canary reach?
EOF

printf '%s\n' "$proj"
