#!/usr/bin/env bash
# probe_definitions_no_spawn: role definitions sit on disk while the host
# exposes no callable spawn surface. The run reports the delegation surface
# as absent and claims no host-enforced read-only.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
stage_docs_corpus "$proj"

mkdir -p "$proj/helpers"
for role in surveyor checker synthesiser; do
  cat > "$proj/helpers/$role.md" <<ROLE
---
name: $role
description: Deployed role definition for the $role pass.
---

# $role

Read the assigned path and report against the brief.
ROLE
done

seal "$target" "$proj"
echo "probe_definitions_no_spawn sandbox staged at $proj"
