#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/../_common.sh"

target="${1:?target dir required}"
init_proj "$target"

mkdir -p "$target/proj/docs" "$target/proj/src/api"

cat > "$target/proj/src/api/webhooks.py" <<'EOF'
"""Outbound webhook delivery."""

SIGNATURE_HEADER = "X-Signature"


def sign(payload, secret):
    """Return the HMAC signature sent in SIGNATURE_HEADER."""
    return f"sha256={hash((payload, secret)) & 0xffffffff:08x}"
EOF

cat > "$target/proj/docs/webhooks.md" <<'EOF'
# Webhooks

## Delivery

Each outbound webhook carries a signature header so a receiver can verify the
payload came from us.

## Verification

A receiver recomputes the signature over the raw request body.
EOF

# Target task. Context introduces docs/webhooks.md as background, naming what
# the page documents today, and Approach names the same page as an edit site with
# its own account of the change. Two distinct roles, so each site earns its
# link under the grouping rule's carve-out and the finding's disposition is
# kept rather than regrouped.
cat > "$target/proj/tasks/api_webhook-timestamp.md" <<'EOF'
---
description: Add a signed timestamp header to outbound webhooks so receivers can reject replayed deliveries.
scope: src/api
created: 2026-01-01T00:00:00
updated: 2026-01-01T00:00:00
status: open
reported-by: Harness
---

# Signed timestamp header on outbound webhooks

## Goal

Add a signed timestamp header to outbound webhooks so a receiver rejects a
replayed delivery instead of processing it twice.

## Context

`src/api/webhooks.py` signs each payload in `sign()` and sends the result in
`SIGNATURE_HEADER`. [The webhook reference](../docs/webhooks.md) is the page
receivers read today: its `## Delivery` section describes the signature
header and its `## Verification` section describes recomputing the signature
over the raw body. Neither section mentions replay.

## Approach

Include the delivery timestamp in the signed material and send it in its own
header alongside `SIGNATURE_HEADER`. Then edit
[the webhook reference](../docs/webhooks.md): extend its `## Verification`
section with the timestamp check and the freshness window a receiver applies
before accepting a delivery.

## Acceptance

- `src/api/webhooks.py` signs the timestamp together with the payload and
  sends it in its own header.
- `docs/webhooks.md` documents the timestamp check and the freshness window
  under its `## Verification` section.
EOF

commit_proj "$target"
