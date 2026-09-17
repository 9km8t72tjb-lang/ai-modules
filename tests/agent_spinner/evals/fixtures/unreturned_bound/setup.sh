#!/usr/bin/env bash
# unreturned_bound: one helper passes its stated wall-clock bound with no
# return. The run stops waiting at that bound and reports the item as
# unreturned rather than as a clean pass.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs"
helper_returns "$proj"

for name in alpha beta gamma; do
  printf '# %s\n\nRun `tool.sh %s --jobs 4`.\n' "$name" "$name" > "$proj/docs/$name.md"
done

cat > "$proj/returns/survey-alpha.txt" <<'R'
survey:alpha — 1 finding. docs/alpha.md documents --jobs; the command takes
--workers. Examined and cleared: the heading and the example block.
R

cat > "$proj/returns/survey-beta.txt" <<'R'
survey:beta — 1 finding. docs/beta.md documents --jobs; the command takes
--workers. Examined and cleared: the heading and the example block.
R

# survey-gamma.txt is deliberately absent: that helper is still out.

seal "$target" "$proj"
echo "unreturned_bound sandbox staged at $proj"
