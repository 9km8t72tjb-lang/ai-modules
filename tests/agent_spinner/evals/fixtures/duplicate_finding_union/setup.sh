#!/usr/bin/env bash
# duplicate_finding_union: two passes raise the same finding. The run sends it
# through its own refute-by-default check and counts no agreement.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/docs" "$proj/bin"
helper_returns "$proj"

printf '#!/usr/bin/env bash\necho "verify --strict"\n' > "$proj/bin/tool.sh"
chmod +x "$proj/bin/tool.sh"
cat > "$proj/docs/verify.md" <<'DOC'
# verify

Run `tool.sh verify --strict`.

Add `--fail-fast` to stop at the first failure.
DOC

cat > "$proj/returns/lens-accuracy.txt" <<'R'
lens:accuracy — 1 finding.
  [major] docs/verify.md documents --fail-fast; bin/tool.sh accepts --strict only.
    "Add `--fail-fast` to stop at the first failure."
    docs/verify.md, under "# verify"
    confidence: high
  Examined and cleared: the heading, the --strict example.
R

cat > "$proj/returns/lens-completeness.txt" <<'R'
lens:completeness — 1 finding.
  [major] docs/verify.md documents --fail-fast, which the command does not accept.
    "Add `--fail-fast` to stop at the first failure."
    docs/verify.md, under "# verify"
    confidence: high
  Examined and cleared: the heading, the flag list.
R

seal "$target" "$proj"
echo "duplicate_finding_union sandbox staged at $proj"
