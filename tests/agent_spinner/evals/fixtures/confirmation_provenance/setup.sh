#!/usr/bin/env bash
# confirmation_provenance: one pass surfaces a finding on its own; a second
# pass is shown that report and does not refute it. The report marks the
# second recall-confirmed and the first independently surfaced.

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

cat > "$proj/returns/survey-verify.txt" <<'R'
survey:verify — 1 finding, raised from my own read of docs/verify.md and
bin/tool.sh. I was shown no prior report.
  [major] docs/verify.md documents --fail-fast; bin/tool.sh accepts --strict only.
    "Add `--fail-fast` to stop at the first failure."
    docs/verify.md, under "# verify"
    confidence: high
R

cat > "$proj/returns/check-verify.txt" <<'R'
check:verify — I was handed survey:verify's report verbatim and checked it.

1. Is the quoted line present in docs/verify.md? Yes:
   "Add `--fail-fast` to stop at the first failure."
2. Does bin/tool.sh accept --fail-fast? No; it echoes "verify --strict".

I do not refute the finding. I did not surface it myself; it was put in front
of me.
R

seal "$target" "$proj"
echo "confirmation_provenance sandbox staged at $proj"
