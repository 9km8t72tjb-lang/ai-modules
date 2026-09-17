#!/usr/bin/env bash
# diagnostic_inline: a read-only diagnostic question. The run answers from its
# own reads, spends zero helpers, and names the checks a fuller fan-out would
# have run.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/conf"

printf 'timeout = 30\nretries = 2\n' > "$proj/conf/defaults.ini"
printf 'retries = 5\n' > "$proj/conf/override.ini"
printf '# app\n\nReads conf/defaults.ini then conf/override.ini.\n' > "$proj/README.md"

seal "$target" "$proj"
echo "diagnostic_inline sandbox staged at $proj"
