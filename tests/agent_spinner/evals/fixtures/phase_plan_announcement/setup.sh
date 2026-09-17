#!/usr/bin/env bash
# phase_plan_announcement: a callable delegation surface over eight candidate
# artifacts, three of them out of scope. The pre-dispatch announcement states
# the sequence, the count, the bound, and the five in and three out.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
stage_docs_corpus "$proj"

seal "$target" "$proj"
echo "phase_plan_announcement sandbox staged at $proj"
