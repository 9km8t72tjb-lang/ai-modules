#!/usr/bin/env bash
# payload_cap: helper reports exceed the stated payload cap. The synthesis
# brief carries the truncation notice and the digest lists the trimmed
# identifiers.

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

for name in alpha beta gamma; do
  {
    printf 'survey:%s — 1 finding.\n' "$name"
    printf '  [major] docs/%s.md documents --jobs; the command takes --workers.\n' "$name"
    printf '    "Run `tool.sh %s --jobs 4`."\n' "$name"
    printf '    docs/%s.md, under "# %s"\n' "$name" "$name"
    printf '  Examined and cleared, at length:\n'
    for i in $(seq 1 240); do
      printf '    line %03d: read the heading, the example block, and the flag list again.\n' "$i"
    done
  } > "$proj/returns/survey-$name.txt"
done

seal "$target" "$proj"
echo "payload_cap sandbox staged at $proj"
