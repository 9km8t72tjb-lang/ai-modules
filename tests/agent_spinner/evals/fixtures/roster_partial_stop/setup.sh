#!/usr/bin/env bash
# roster_partial_stop: the run stops after two of four writers. The roster
# carries per-item state, and the closing report enumerates the modified,
# untouched, and unknown-state artifacts from it.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs"

for name in setup deploy upgrade rollback; do
  printf '# %s\n\nRun `tool.sh %s --jobs 4`.\n' "$name" "$name" > "$proj/docs/$name.md"
done
printf 'The flag is now --workers everywhere.\n' > "$proj/NOTES.txt"

seal "$target" "$proj"
echo "roster_partial_stop sandbox staged at $proj"
