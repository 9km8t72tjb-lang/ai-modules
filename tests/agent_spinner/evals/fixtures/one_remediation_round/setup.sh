#!/usr/bin/env bash
# one_remediation_round: verification fails on one item. Exactly one
# remediation round runs, no second verification loop is attempted, and the
# report marks the remediated output unverified.

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
printf '# verify\n\nRun `tool.sh verify --strict`.\n\nAdd `--fail-fast` to stop early.\n' \
  > "$proj/docs/verify.md"
printf '# status\n\nRun `tool.sh status`.\n' > "$proj/docs/status.md"

cat > "$proj/returns/check-verify.txt" <<'R'
check:verify — FAIL.

1. Documented flags match the command: fail.
   "Add `--fail-fast` to stop early." — docs/verify.md, under "# verify".
   bin/tool.sh echoes "verify --strict" and accepts no --fail-fast.
2. Heading matches the subcommand: pass. "# verify" — docs/verify.md line 1.

Verdict: docs/verify.md needs repair.
R

cat > "$proj/returns/check-status.txt" <<'R'
check:status — PASS.

1. Documented flags match the command: pass. "Run `tool.sh status`." —
   docs/status.md, under "# status". bin/tool.sh takes no status flags.
R

seal "$target" "$proj"
echo "one_remediation_round sandbox staged at $proj"
