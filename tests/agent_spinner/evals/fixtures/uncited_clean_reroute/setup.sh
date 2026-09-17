#!/usr/bin/env bash
# uncited_clean_reroute: the checking pass returns a clean verdict citing no
# span. The run routes that verdict back for re-checking rather than
# accepting it.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs"
helper_returns "$proj"

printf '# deploy\n\nRun `tool.sh deploy --env prod --jobs 4`.\n' > "$proj/docs/deploy.md"
printf 'deploy takes --env only; --jobs was removed.\n' > "$proj/SPEC.txt"

cat > "$proj/returns/check-deploy.txt" <<'R'
check:deploy — all clear.

1. Documented flags match the spec: pass.
2. Example block runs as written: pass.
3. Heading matches the subcommand: pass.

No findings.
R

seal "$target" "$proj"
echo "uncited_clean_reroute sandbox staged at $proj"
