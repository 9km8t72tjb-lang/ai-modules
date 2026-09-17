#!/usr/bin/env bash
# governed_stop: the ask names a task readiness loop and the host exposes no
# delegation surface. The governing skill's stop-and-ask boundary holds, so
# the run offers that loop's manual routes and performs no helper role inline.

set -euo pipefail
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$THIS_DIR/../_common.sh"

target="${1:?target dir required}"
proj="$(new_project "$target")"
mkdir -p "$proj/tasks/archive"

cat > "$proj/tasks/demo_widget-cache.md" <<'TASK'
---
description: Add a cache in front of the widget lookup so repeat reads skip the store.
scope: src
created: 2026-09-01T10:00:00
updated: 2026-09-01T10:00:00
status: open
reported-by: Evals
---

# Cache the widget lookup

## Goal

Repeat widget reads hit an in-process cache instead of the store.

## Context

`src/widgets.py` reads the store on every call.

## Approach

Add a small dictionary cache keyed by widget id.

## Acceptance

- A second read of the same id performs no store call.
TASK

mkdir -p "$proj/src"
printf 'def get_widget(wid):\n    return store_read(wid)\n' > "$proj/src/widgets.py"

seal "$target" "$proj"
echo "governed_stop sandbox staged at $proj"
