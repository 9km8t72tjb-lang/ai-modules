#!/usr/bin/env python3
"""Unit tests for grade.py: a faithful rewrite passes and each lossy one fails.

A grader that cannot fail proves nothing, so every scenario here stages its
real fixture, writes a hand-made faithful `delivered.md` that must pass every
mechanical and integrity check, then writes lossy variants that must fail on
exactly the checks naming what they dropped. The fidelity_padded faithful
rewrite carries all thirteen ledger items, and the test also asserts it needs
no more than half the fixture's words, which is the fixture's design claim.

No model is involved. Run from anywhere:

    python3 tests/language_humanizer/evals/test_grade.py
"""

from __future__ import annotations

import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

THIS = pathlib.Path(__file__).resolve().parent
GRADE = THIS / "grade.py"
FIXTURES = THIS / "fixtures"

sys.path.insert(0, str(THIS))
import grade as grader  # noqa: E402  (sibling module in this harness)

PASS = 0
FAIL = 0


def check(label: str, condition: bool, detail: str = "") -> None:
    global PASS, FAIL
    if condition:
        PASS += 1
        print(f"  ok   {label}")
    else:
        FAIL += 1
        print(f"  FAIL {label}{': ' + detail if detail else ''}")


def stage(eval_id: str, root: pathlib.Path) -> tuple[pathlib.Path, pathlib.Path]:
    """Stage one fixture the way stage.sh does and return (proj, source)."""

    out = subprocess.run(
        ["bash", str(FIXTURES / eval_id / "setup.sh"), str(root)],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    proj = pathlib.Path(out)
    source = proj / ("notes.md" if eval_id == "write_path" else "draft.md")
    shutil.copyfile(source, root / ".fixture_pristine")
    return proj, source


def grade(eval_id: str, delivered: str | None,
          edit_source: str | None = None) -> dict:
    """Stage a fresh fixture, write the delivered text, and grade it."""

    root = pathlib.Path(tempfile.mkdtemp(prefix="lh_grade_test_"))
    try:
        proj, source = stage(eval_id, root)
        if delivered is not None:
            (proj / "delivered.md").write_text(delivered)
        if edit_source is not None:
            source.write_text(edit_source)
        out = subprocess.run(
            [sys.executable, str(GRADE), eval_id, str(proj), str(source), "--json"],
            capture_output=True, text=True,
        )
        return json.loads(out.stdout)
    finally:
        shutil.rmtree(root, ignore_errors=True)


def failed(verdict: dict) -> set[str]:
    checks = {**verdict["mechanical"], **verdict["integrity"]}
    return {name for name, result in checks.items() if not result["passed"]}


def expect(label: str, verdict: dict, failing: set[str]) -> None:
    got = failed(verdict)
    check(label, got == failing,
          f"expected failing {sorted(failing) or 'none'}, got {sorted(got) or 'none'}")


FIDELITY_FAITHFUL = """\
# Q1 checkout reliability: status and next steps

Priya Raman must ship the checkout latency fix by 14 March, because our 200 ms
p95 latency commitment is contractual.

Checkout p95 latency is 340 ms today, so the fix is needed to meet that
commitment.

The Billing squad should migrate its retry logic onto the shared queue in the
same window. Enterprise tenants are the exception: their retries should stay on
the dedicated worker until their contracts are renegotiated.

Availability must stay at or above 99.5% for the whole migration.
"""

COMPRESSION_FAITHFUL = """\
# Why the trial-conversion drop matters more than the signup dip

Trial-to-paid conversion deserves the remediation budget first, because a
conversion decline compounds while a signup dip recovers. Signups fell 4% last
quarter, but they recovered within three weeks in each of the two previous
quarters where they dipped. Conversion, by contrast, has declined for three
consecutive quarters, from 18% to 14%. Every cohort that converts below plan
carries a smaller paying base into the next quarter, so the gap widens even
when acquisition returns to normal. That holds even though leadership asks
about signups in every review.

The decline is concentrated in self-serve accounts, since sales-assisted
conversion held flat across the same three quarters. Therefore a remediation
aimed at the assisted funnel would address the smaller half of the problem and
leave the compounding half untouched.

The new onboarding step we shipped in the second week of the quarter may be
driving the drop-off, but we have not isolated it from the pricing-page change
that landed the same week, so that reading is unconfirmed.
"""

WRITE_FAITHFUL = """\
# Incident follow-ups

Dana Okoro owns the alerting rework, due 30 April, and Marco Weiss owns the
postmortem template refresh.

Downtime must stay within the error budget of 2 hours per quarter, a hard bar
set in the service level objective (SLO) doc.

Two numbers describe the current state: 40% of last month's pages were
duplicates, and p95 page-acknowledgement time is 11 minutes against a goal of
under 5.

Two questions are still open: who updates the runbook, and whether we need a
second on-call rotation.
"""


def test_fidelity_padded() -> None:
    print("fidelity_padded")
    verdict = grade("fidelity_padded", FIDELITY_FAITHFUL)
    expect("faithful rewrite passes every check", verdict, set())
    check("faithful rewrite of all thirteen items needs at most half the "
          "fixture's words",
          verdict["delivered_words"] * 2 <= verdict["fixture_words"],
          f"{verdict['delivered_words']}w vs fixture {verdict['fixture_words']}w")

    expect("dropping the 340 ms current latency fails only that item",
           grade("fidelity_padded",
                 FIDELITY_FAITHFUL.replace("Checkout p95 latency is 340 ms today, so",
                                           "So")),
           {"item_measurement_340ms"})
    expect("dropping the Billing squad fails only that actor",
           grade("fidelity_padded",
                 FIDELITY_FAITHFUL.replace("The Billing squad should", "The team should")),
           {"item_actor_billing"})
    expect("dropping the 99.5% floor fails only that threshold",
           grade("fidelity_padded",
                 FIDELITY_FAITHFUL.replace("at or above 99.5% ", "")),
           {"item_threshold_995"})
    expect("delivering the padded fixture itself fails the 75% ceiling",
           grade("fidelity_padded",
                 (FIXTURES / "fidelity_padded" / "setup.sh").read_text()
                 .split("<<'EOF'\n", 1)[1].split("\nEOF\n", 1)[0]),
           {"length_at_most_75pct"})
    stubs = FIDELITY_FAITHFUL + (
        "\n- Priya fixes latency.\n- Billing migrates retries.\n"
        "- Enterprise retries stay.\n"
    )
    expect("a cascade of three sub-12-word bullets fails the shape check",
           grade("fidelity_padded", stubs), {"no_short_bullet_cascade"})
    expect("editing the source in place fails the integrity check",
           grade("fidelity_padded", FIDELITY_FAITHFUL, edit_source="edited\n"),
           {"fixture_unmodified"})
    missing = grade("fidelity_padded", None)
    check("a missing delivered.md fails the integrity check",
          "delivered_file_written" in failed(missing) and not missing["passed"])


def test_compression_trap() -> None:
    print("compression_trap")
    expect("faithful rewrite passes every check",
           grade("compression_trap", COMPRESSION_FAITHFUL), set())
    stubs = (
        "- Signups fell 4% but recover fast.\n"
        "- Conversion fell from 18% to 14%.\n"
        "- A conversion decline compounds.\n"
        "- Onboarding may be the cause.\n"
    )
    expect("splintering the argument into stubs fails only the prose check",
           grade("compression_trap", stubs), {"paragraph_stays_prose"})
    flat = COMPRESSION_FAITHFUL.split("The new onboarding step")[0] + (
        "The drop-off is driven by the new onboarding step we shipped in the "
        "second week of the quarter.\n"
    )
    expect("asserting the hedged claim flatly fails both hedge checks",
           grade("compression_trap", flat),
           {"hedge_kept", "no_flat_causal_assertion"})
    no_hinge = (COMPRESSION_FAITHFUL
                .replace("because a\nconversion decline compounds while a signup dip recovers",
                         "because conversion matters more")
                .replace("Every cohort that converts below plan\ncarries a smaller paying "
                         "base into the next quarter, so the gap widens even\nwhen "
                         "acquisition returns to normal. ", "")
                .replace("compounding half", "larger half"))
    expect("dropping the compounding mechanism fails only that check",
           grade("compression_trap", no_hinge), {"compounding_argument_kept"})
    longer = COMPRESSION_FAITHFUL + "\n" + COMPRESSION_FAITHFUL
    expect("running longer than the fixture fails the length check",
           grade("compression_trap", longer), {"length_at_most_fixture"})


def test_write_path() -> None:
    print("write_path")
    expect("faithful document passes every check",
           grade("write_path", WRITE_FAITHFUL), set())
    expect("dropping an owner fails only that item",
           grade("write_path",
                 WRITE_FAITHFUL.replace(", and Marco Weiss owns the\npostmortem "
                                        "template refresh", "")),
           {"item_owner_marco"})
    expect("dropping the budget window fails only that item",
           grade("write_path", WRITE_FAITHFUL.replace(" per quarter", "")),
           {"item_threshold_per_quarter"})
    expect("a stock filler phrase fails only the filler check",
           grade("write_path",
                 WRITE_FAITHFUL.replace("# Incident follow-ups\n\n",
                                        "# Incident follow-ups\n\nIt is important to "
                                        "note that these come from the retro.\n\n")),
           {"no_filler_phrases"})


def test_word_count() -> None:
    print("word_count")
    check("markdown markers carry no words",
          grader.word_count("# Title\n\n- one two\n| a | b |") == 5)


def main() -> int:
    test_word_count()
    test_fidelity_padded()
    test_compression_trap()
    test_write_path()
    print(f"\n{PASS} passed, {FAIL} failed")
    return 0 if FAIL == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
