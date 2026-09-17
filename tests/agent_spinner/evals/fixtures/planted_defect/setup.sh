#!/usr/bin/env bash
# planted_defect: a produced artifact carries one planted defect. The
# checking pass names it.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs" "$proj/bin"

cat > "$proj/bin/tool.sh" <<'TOOL'
#!/usr/bin/env bash
set -euo pipefail
# verify accepts exactly one flag: --strict
case "${1:-}" in
  verify) echo "verify --strict" ;;
  *)      echo "usage: tool.sh verify [--strict]" ;;
esac
TOOL
chmod +x "$proj/bin/tool.sh"

cat > "$proj/docs/verify.md" <<'DOC'
# verify

Run `tool.sh verify --strict` for the ordinary check.

Add `--fail-fast` to stop at the first failure.
DOC

seal "$target" "$proj"
echo "planted_defect sandbox staged at $proj"
