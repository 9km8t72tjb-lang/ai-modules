#!/usr/bin/env bash
# A whole-file rewrite of a several-thousand-line helpers module whose only
# defect sits in the final hunk, with no comment or docstring naming it.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$HERE/../_common.sh"

# Sized so a fresh Cursor whole-file read finishes inside the runner default
# timeout while the three-dot diff still spans several thousand lines.
HELPER_COUNT=1600

plant_rewritten_helpers() {
    local path=$1
    local count=$2
    local i
    mkdir -p "$(dirname "$path")"
    : > "$path"
    for ((i = 1; i <= count; i++)); do
        printf 'def helper_%05d(value):\n    return value * %d + 1\n\n' "$i" "$i" >> "$path"
    done
}

target="${1:?target directory required}"
repo="$(init_remote_repo "$target" main)"

cd "$repo"
mkdir -p src
plant_long_file "$repo/src/helpers.py" "$HELPER_COUNT" "# end of generated helpers"
git add -A
git commit --quiet -m "seed helpers"
git push --quiet origin main

git checkout --quiet -b extend-helpers
plant_rewritten_helpers "$repo/src/helpers.py" "$HELPER_COUNT"
cat >> src/helpers.py <<'PY'


def summarize(values):
    total = 0
    for v in values:
        total += v
    return total / len(values)
PY
git add -A
git commit --quiet -m "src/helpers.py -> rewrite every helper and add summarize at the end"
git push --quiet -u origin extend-helpers
printf '%s\n' "$repo"
