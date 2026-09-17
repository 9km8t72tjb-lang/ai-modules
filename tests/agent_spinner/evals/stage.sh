#!/usr/bin/env bash
# stage.sh — stage one agent_spinner eval and print worker-ready inputs.
#
# Usage:
#   stage.sh <eval_id> [target_dir]
#
# Prints name=value lines (printf %q quoted) for:
#   sandbox_proj, sandbox_target, skill_path, prompt
#
# After setup, verifies the sandbox is its own git toplevel so a failed or
# blocked init cannot leave us pointing at the host checkout, and verifies both
# hash inventories exist.

set -euo pipefail

eval_id="${1:?eval id required}"
target="${2:-$(mktemp -d "${TMPDIR:-/tmp}/agent_spinner_eval.XXXXXX")}"
mkdir -p "$target"
target="$(cd "$target" && pwd)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
SKILL_MD="$REPO_ROOT/plugins/ai_dev/skills/agent_spinner/SKILL.md"

# shellcheck source=fixtures/_common.sh
. "$HERE/fixtures/_common.sh"

setup="$HERE/fixtures/$eval_id/setup.sh"
if [[ ! -x "$setup" ]]; then
  echo "unknown eval id: $eval_id (no executable $setup)" >&2
  exit 2
fi
"$setup" "$target" >/dev/null

proj="$target/proj"
if [[ ! -d "$proj" ]]; then
  echo "stage.sh: setup produced no $proj" >&2
  exit 1
fi
ensure_sandbox_git "$proj"

for inventory in .tree_sha256 .outside_sha256; do
  if [[ ! -s "$target/$inventory" ]]; then
    echo "stage.sh: missing $target/$inventory (setup incomplete)" >&2
    exit 1
  fi
done

prompt="$(
  python3 - "$eval_id" "$HERE/evals.json" <<'PY'
import json, sys
eid, path = sys.argv[1], sys.argv[2]
data = json.load(open(path))
for e in data["evals"]:
    if e["id"] == eid:
        print(e["prompt"])
        break
else:
    raise SystemExit(f"prompt not found for {eid}")
PY
)"

date +%s > "$target/.eval_started_at"

printf 'sandbox_proj=%q\n' "$proj"
printf 'sandbox_target=%q\n' "$target"
printf 'skill_path=%q\n' "$SKILL_MD"
printf 'prompt=%q\n' "$prompt"
