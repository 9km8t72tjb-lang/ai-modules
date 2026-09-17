#!/usr/bin/env bash
# failure_taxonomy: three non-results in one run — a deliberate self-reported
# inability, a boilerplate-only return, and an absent return. The run spends
# no retry on the first and exactly one re-invocation on each of the other
# two, and reports all three separately in the arithmetic.

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
survey:alpha — I cannot assess this item. docs/alpha.md references a command
file that is not present in this sandbox, so I have nothing to compare the
documented flag against. Reporting this as an inability rather than guessing.
R

cat > "$proj/returns/survey-beta.txt" <<'R'
<system-reminder>Skills available in this session are listed above.</system-reminder>
R

# survey-gamma.txt is deliberately absent: the helper never returned.

seal "$target" "$proj"
echo "failure_taxonomy sandbox staged at $proj"
