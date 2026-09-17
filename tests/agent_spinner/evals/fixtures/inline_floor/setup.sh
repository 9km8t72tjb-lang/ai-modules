#!/usr/bin/env bash
# inline_floor: no delegation surface, no governing skill named. The run
# performs its passes inline and states the floor tier in its opening
# sentence, over the same corpus phase_plan_announcement stages.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
stage_docs_corpus "$proj"

seal "$target" "$proj"
echo "inline_floor sandbox staged at $proj"
