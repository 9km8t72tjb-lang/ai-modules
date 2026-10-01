#!/usr/bin/env python3
"""Contract checks for the wiki hub's <output_contract> block.

The block names the report each core operation, and an ambiguous
discovery, returns to the user. It cites the steps that already promise
part of a report instead of restating them, so each promise keeps one
statement in the hub. A self-test runs first and proves every check fails
on the defect it exists to catch, so a broken checker cannot pass the
real block.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parents[2]
WIKI_SKILL = REPO_ROOT / "plugins/knowledge_management/skills/wiki/SKILL.md"

# A run of this many words shared with a covered block counts as a restatement.
RUN_LENGTH = 6
EDGE_CHARS = ".,;:!?()[]{}\"'<>‘’“”…"
OMISSION_RE = re.compile(
    r"\b(?:not|never|no|none|nothing|without|omit\w*|exclud\w*|except)\b"
    r"|\bleaves? out\b|\bleft out\b|\bskip(?:s|ped|ping)?\b(?!\s+reason)",
    re.IGNORECASE,
)

# Each operation entry is found by the operation tag it names. It must cite
# the listed steps and name the listed report elements.
OPERATIONS = {
    "`<ingest>`": {
        "cites": ["`<report_what_changed>`", "**Re-ingest compares before it writes**"],
        "names": ["created or updated"],
    },
    "`<capture_procedure>`": {
        "cites": ["`<update_navigation_for_procedure>`"],
        "names": ["procedure page", "created or updated", "`index.md`", "navigation"],
    },
    "`<query>`": {
        "cites": ["**Synthesize an answer**", "**Report the filing decision in one line**"],
        "names": ["citations", "filing decision", "path", "skip reason", "trigger"],
    },
    "`<archive>`": {
        "cites": [],
        "names": ["archived page", "`index.md`", "inbound", "lint"],
    },
    "`<lint_and_audit>`": {
        "cites": ["`<inline_iteration_loop>`", "`<broad_audits>`"],
        "names": ["counts", "`log.md`", "per-file change list", "audit-complete line"],
    },
    "`<present_candidates>`": {
        "cites": ["`<adopt_when_user_named_the_path>`"],
        "names": ["`AVAILABLE:`", "`EXISTING:`", "walk order", "chose", "one-line adoption report"],
    },
}

# Blocks whose wording the contract must cite rather than restate.
COVERED_BLOCKS = [
    "ingest",
    "capture_procedure",
    "query",
    "archive",
    "lint_and_audit",
    "present_candidates",
    "adopt_when_user_named_the_path",
]


def section(text: str, name: str) -> str:
    match = re.search(rf"(?m)^\s*<{name}>\n(.*?)\n\s*</{name}>", text, re.DOTALL)
    if not match:
        raise AssertionError(f"missing <{name}> section")
    return match.group(1)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def flat(text: str) -> str:
    return re.sub(r"\s+", " ", text)


def words(text: str) -> list[str]:
    tokens = text.replace("**", " ").replace("`", " ").lower().split()
    stripped = (token.strip(EDGE_CHARS) for token in tokens)
    return [token for token in stripped if token]


def runs(text: str) -> set[tuple[str, ...]]:
    seq = words(text)
    return {tuple(seq[i:i + RUN_LENGTH]) for i in range(len(seq) - RUN_LENGTH + 1)}


def shared_runs(candidate: str, source: str) -> set[tuple[str, ...]]:
    return runs(candidate) & runs(source)


def occurrences(haystack: str, needle: str) -> int:
    pattern = rf"(?<!\S){re.escape(' '.join(words(needle)))}(?!\S)"
    return len(re.findall(pattern, " ".join(words(haystack))))


def omission_words(text: str) -> list[str]:
    return [match.group(0) for match in OMISSION_RE.finditer(text)]


def lead_in_body(block: str, label: str) -> str:
    """Return a list item's text after its bold lead-in, up to the next item."""
    match = re.search(
        rf"^(?:\d+\.|-)\s+\*\*{re.escape(label)}\.?\*\*(.*?)(?=^(?:\d+\.|-)\s|\Z)",
        block,
        re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise AssertionError(f"missing list item led by **{label}**")
    return match.group(1)


def placement_problems(text: str) -> list[str]:
    openers = re.findall(r"(?m)^\s*<output_contract>\s*$", text)
    closers = re.findall(r"(?m)^\s*</output_contract>\s*$", text)
    if len(openers) != 1 or len(closers) != 1:
        return [f"expected one <output_contract> block, found {len(openers)}"]
    problems = []
    pitfalls = re.search(r"(?m)^</pitfalls>\s*$", text)
    opener = re.search(r"(?m)^\s*<output_contract>\s*$", text)
    closer = re.search(r"(?m)^\s*</output_contract>\s*$", text)
    if not pitfalls or pitfalls.start() > opener.start():
        problems.append("block does not follow </pitfalls>")
    follower = "<family>" if re.search(r"(?m)^<family>\s*$", text) else "</wiki>"
    if not re.match(rf"\s*{re.escape(follower)}", text[closer.end():]):
        problems.append(f"block is not immediately before {follower}")
    return problems


def entries(contract: str) -> list[str]:
    return [m.group(2) for m in re.finditer(
        r"(?m)^<([a-z][a-z0-9_]*)>\n(.*?)\n</\1>", contract, re.DOTALL)]


def self_test() -> None:
    good = "</pitfalls>\n\n<output_contract>\nx\n</output_contract>\n\n</wiki>\n"
    family = "<family>\ny\n</family>\n\n"
    require(not placement_problems(good), "placement check rejects a block before </wiki>")
    require(not placement_problems(good.replace("</wiki>", family + "</wiki>")),
            "placement check rejects a block before <family>")
    require(placement_problems(good.replace("<output_contract>", family + "<output_contract>")),
            "placement check accepts a block after <family>")
    require(placement_problems("<output_contract>\nx\n</output_contract>\n\n</pitfalls>\n\n</wiki>\n"),
            "placement check accepts a block before </pitfalls>")
    require(placement_problems(good.replace("</wiki>", "<output_contract>\nz\n</output_contract>\n\n</wiki>")),
            "placement check accepts two blocks")

    source = ("**Report what changed** to the user: list only files actually\n"
              "created or updated, matching what the log entry contains.")
    require(shared_runs("Return them: list only files actually created or updated.", source),
            "restatement check misses a copied clause")
    require(not shared_runs("Return the files the ingest created or updated.", source),
            "restatement check flags a citation")
    require(occurrences(f"{source}\nmore text", source) == 1, "occurrence count misses one body")
    require(occurrences(f"{source}\n{source}", source) == 2, "occurrence count misses a copy")

    require(omission_words("Skip files inspected, considered, or deliberately left unchanged."),
            "omission check misses a skip instruction")
    require(omission_words("List no unchanged files."), "omission check misses a negated shape")
    require(not omission_words("Return the filed page's path or the skip reason."),
            "omission check flags a skip-reason label")


def main() -> int:
    self_test()
    wiki = WIKI_SKILL.read_text(encoding="utf-8")

    problems = placement_problems(wiki)
    require(not problems, "; ".join(problems))
    contract = section(wiki, "output_contract")
    blocks = entries(contract)

    for marker, spec in OPERATIONS.items():
        matching = [entry for entry in blocks if marker in entry]
        require(len(matching) == 1, f"{marker} is named by {len(matching)} entries, expected 1")
        entry = matching[0]
        entry_flat = flat(entry)
        require(entry.lstrip().startswith("**"), f"{marker} entry does not lead with a bold label")
        found = omission_words(entry_flat)
        require(not found, f"{marker} entry frames its report by omission: {found}")
        for cite in spec["cites"]:
            require(cite in entry_flat, f"{marker} entry does not cite {cite}")
        for name in spec["names"]:
            require(name.lower() in entry_flat.lower(), f"{marker} entry does not name {name!r}")

    # A cited label is the citation itself, so mask it before comparing runs.
    uncited = contract
    for spec in OPERATIONS.values():
        for cite in spec["cites"]:
            uncited = uncited.replace(cite, " §cited§ ")
    for name in COVERED_BLOCKS:
        shared = sorted(shared_runs(uncited, section(wiki, name)))
        if shared:
            raise AssertionError(f"contract restates <{name}>: {' '.join(shared[0])!r}")

    query = section(wiki, "query")
    cited_bodies = {
        "<report_what_changed>": section(wiki, "report_what_changed"),
        "**Re-ingest compares before it writes**": lead_in_body(
            section(wiki, "capture_raw_source"), "Re-ingest compares before it writes"),
        "<update_navigation_for_procedure>": section(wiki, "update_navigation_for_procedure"),
        "**Synthesize an answer**": lead_in_body(query, "Synthesize an answer"),
        "**Report the filing decision in one line**": lead_in_body(
            query, "Report the filing decision in one line"),
        "<inline_iteration_loop>": section(wiki, "inline_iteration_loop"),
        "<broad_audits>": section(wiki, "broad_audits"),
        "<present_candidates>": section(wiki, "present_candidates"),
        "<adopt_when_user_named_the_path>": section(wiki, "adopt_when_user_named_the_path"),
    }
    for label, body in cited_bodies.items():
        count = occurrences(wiki, body)
        require(count == 1, f"body wording of {label} occurs {count} times in the hub, expected 1")

    print(f"wiki hub output contract: PASS ({len(blocks)} entries, "
          f"{len(cited_bodies)} cited steps stated once)")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except AssertionError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
