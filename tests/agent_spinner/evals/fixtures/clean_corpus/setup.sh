#!/usr/bin/env bash
# clean_corpus: the corpus carries no defect. Every documented flag is one the
# command actually parses, so the run reports zero findings, invents none, and
# records what it examined and cleared.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs" "$proj/bin"

cat > "$proj/bin/tool.sh" <<'TOOL'
#!/usr/bin/env bash
# Two subcommands. verify parses exactly one optional flag; status parses none.
set -euo pipefail

sub="${1:-}"
shift || true

case "$sub" in
  verify)
    case "${1:-}" in
      --strict) echo "verify: strict mode" ;;
      "")       echo "verify: default mode" ;;
      *)        echo "verify: unknown flag ${1}" >&2; exit 2 ;;
    esac
    ;;
  status)
    if [ "$#" -gt 0 ]; then
      echo "status: takes no flags" >&2
      exit 2
    fi
    echo "status: ok"
    ;;
  *)
    echo "usage: tool.sh {verify [--strict]|status}" >&2
    exit 2
    ;;
esac
TOOL
chmod +x "$proj/bin/tool.sh"

cat > "$proj/docs/verify.md" <<'DOC'
# verify

Run `tool.sh verify --strict` to check in strict mode.

Run `tool.sh verify` with no flag for the default mode.
DOC

cat > "$proj/docs/status.md" <<'DOC'
# status

Run `tool.sh status`. It takes no flags.
DOC

seal "$target" "$proj"
echo "clean_corpus sandbox staged at $proj"
