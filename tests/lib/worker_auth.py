"""Backward-compatible Claude wrappers around the shared vendor helpers."""

from __future__ import annotations

from vendor import preflight_auth as _vendor_preflight_auth
from vendor import worker_env as _vendor_worker_env


def worker_env() -> dict[str, str]:
    """Return the Claude worker environment via `vendor.py`."""

    return _vendor_worker_env("claude")


def preflight_auth(claude_bin: str = "claude", model: str = "") -> None:
    """Run the Claude-specific auth probe via `vendor.py`."""

    _vendor_preflight_auth("claude", claude_bin, model)
