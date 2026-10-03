#!/usr/bin/env python3
"""Standalone Layer 2 re-runner — fires one vendor worker per pass.

This is the regression-test entrypoint for the wiki skill. Each invocation:

1. Restages all sandboxes via setup_scenarios.sh (one full pass).
2. Submits one worker per scenario to a ThreadPoolExecutor (default 4 workers).
   Inside each worker, passes run sequentially:
     - Build the prompt via build_prompt.py.
     - Stage the relevant knowledge-management skill trees and the
       `auto_shaper_wiki` agent into the sandbox's vendor discovery tree.
     - Run the vendor-resolved print-mode worker; capture stdout/stderr/timing
       into the pass dir.
     - Between passes within the same scenario, restage just that one
       sandbox so pass-2 starts from the same initial state as pass-1.
3. Runs grade.py and aggregate.py.
4. Compares to the most recent prior benchmark.json (if any) and reports
   regressions.

Sandbox isolation guarantees concurrent scenarios cannot collide: each scenario
has its own dir under tests/wiki/layer2/<sid>/ and each pass writes to its own
workspace/run-<ts>/<sid>/pass-N/ dir.

Layout:
    workspace/run-<ts>/
        L2-1/pass-1/{prompt.md, response.txt, report.md, timing.json, grading.json}
        L2-1/pass-2/...
        ...
        benchmark.json
        benchmark.md
        grading_summary.json

Use `--passes N` to override the default from evals.json. Use `--scenario L2-1`
to run a single scenario (useful when iterating on a specific failure).
Use `--workers N` to tune parallelism (default 4). The default worker policy
comes from `tests/lib/vendor.py`: `--vendor claude` uses `sonnet`,
`--vendor cursor` uses `auto`, and `--model ''` inherits the vendor CLI
default.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import datetime
import json
import os
import pathlib
import shutil
import subprocess
import sys
import time

THIS = pathlib.Path(__file__).resolve().parent
WIKI_TESTS = THIS.parent
EVALS_PATH = THIS / "evals.json"
SETUP_SCRIPT = THIS / "setup_scenarios.sh"
BUILD_PROMPT = THIS / "build_prompt.py"
NORMALIZE = THIS / "normalize.py"
GRADE = THIS / "grade.py"
AGGREGATE = THIS / "aggregate.py"
WORKSPACE = THIS / "workspace"
REPO_ROOT = THIS.parents[2]
KM_SKILLS = REPO_ROOT / "plugins" / "knowledge_management" / "skills"
WIKI_SKILL = KM_SKILLS / "wiki"
WIKI_AGENT_FILES = [
    REPO_ROOT / "plugins" / "knowledge_management" / "agents" / "auto_shaper_wiki.md"
]

sys.path.insert(0, str(WIKI_TESTS.parent / "lib"))
import vendor  # noqa: E402  (shared vendor helper; tests/ is gitignored)
from worker_io import as_text  # noqa: E402  (shared; tests/ is gitignored)


def latest_previous_benchmark() -> pathlib.Path | None:
    if not WORKSPACE.is_dir():
        return None
    candidates = sorted(WORKSPACE.glob("run-*/benchmark.json"))
    return candidates[-1] if candidates else None


def restage_one(scenario_id: str) -> None:
    """Restage a single scenario's sandbox. Safe to call concurrently from
    different worker threads only when each call targets a distinct scenario id.
    Within one scenario, callers must serialize this with that scenario's
    in-flight claude -p subprocess."""
    subprocess.run(
        [str(SETUP_SCRIPT), scenario_id],
        check=True, stdout=subprocess.DEVNULL,
    )


def scenario_workdir(scenario: dict, sandbox_root: pathlib.Path) -> pathlib.Path:
    return sandbox_root / scenario["cwd_subpath"]


def stage_named_agents(
    workdir: pathlib.Path, vendor_name: str, agent_files: list[pathlib.Path]
) -> None:
    vendor_root = workdir / (".cursor" if vendor_name == "cursor" else ".claude")
    agents_root = vendor_root / "agents"
    agents_root.mkdir(parents=True, exist_ok=True)
    for agent_file in agent_files:
        shutil.copy2(agent_file, agents_root / agent_file.name)


def stage_vendor_skills(
    scenario: dict,
    workdir: pathlib.Path,
    artefacts_root: pathlib.Path,
    resolved: vendor.Resolved,
) -> tuple[pathlib.Path, pathlib.Path]:
    skill_name = scenario.get("skill_name", "wiki")
    primary_skill_dir = KM_SKILLS / skill_name
    staged_primary = vendor.stage_skill_tree(
        artefacts_root / skill_name,
        primary_skill_dir,
        resolved.vendor,
    )
    staged_wiki = staged_primary
    if primary_skill_dir != WIKI_SKILL:
        staged_wiki = vendor.stage_skill_tree(
            artefacts_root / "wiki",
            WIKI_SKILL,
            resolved.vendor,
        )
    stage_named_agents(workdir, resolved.vendor, WIKI_AGENT_FILES)
    return staged_primary, staged_wiki


def rewrite_prompt_paths(
    prompt: str,
    scenario: dict,
    staged_primary: pathlib.Path,
    staged_wiki: pathlib.Path,
) -> str:
    skill_name = scenario.get("skill_name", "wiki")
    primary_skill_dir = KM_SKILLS / skill_name
    replacements = {
        str(primary_skill_dir / "SKILL.md"): str(staged_primary),
        str(WIKI_SKILL / "scripts" / "discover_wiki.sh"): str(
            staged_wiki.parent / "scripts" / "discover_wiki.sh"
        ),
        str(WIKI_SKILL / "scripts" / "init_wiki.sh"): str(
            staged_wiki.parent / "scripts" / "init_wiki.sh"
        ),
        str(WIKI_SKILL / "scripts" / "lint.py"): str(
            staged_wiki.parent / "scripts" / "lint.py"
        ),
        str(WIKI_SKILL / "scripts" / "compute_sha256.py"): str(
            staged_wiki.parent / "scripts" / "compute_sha256.py"
        ),
    }
    for src, dest in replacements.items():
        prompt = prompt.replace(src, dest)
    return prompt


def run_pass(scenario: dict, pass_num: int, run_dir: pathlib.Path,
             resolved: vendor.Resolved, timeout: int) -> dict:
    sid = scenario["id"]
    sandbox_root = THIS / scenario["sandbox_path"]
    workdir = scenario_workdir(scenario, sandbox_root)
    pass_dir = run_dir / sid / f"pass-{pass_num}"
    pass_dir.mkdir(parents=True, exist_ok=True)

    report_path = pass_dir / "report.md"
    prompt_path = pass_dir / "prompt.md"

    # Build prompt
    prompt = subprocess.run(
        [
            sys.executable, str(BUILD_PROMPT),
            sid, str(pass_num),
            "--report-path", str(report_path),
            "--sandbox-root", str(sandbox_root),
        ],
        capture_output=True, text=True, check=True,
    ).stdout
    staged_primary, staged_wiki = stage_vendor_skills(
        scenario, workdir, pass_dir / "artefacts", resolved
    )
    prompt = rewrite_prompt_paths(prompt, scenario, staged_primary, staged_wiki)
    prompt_path.write_text(prompt)

    model_label = resolved.worker_model or "<inherit>"
    print(
        f"  [{sid} pass-{pass_num}] running {resolved.config.label} "
        f"(model={model_label}) ...",
        flush=True,
    )
    cmd = vendor.build_print_cmd(
        vendor=resolved.vendor,
        bin=resolved.bin,
        model=resolved.worker_model,
        prompt=prompt,
        workspace=str(workdir),
    )
    start = time.time()
    try:
        result = subprocess.run(
            cmd,
            cwd=workdir,
            env=vendor.worker_env(resolved.vendor),
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        rc = result.returncode
        stdout = result.stdout
        stderr = result.stderr
    except subprocess.TimeoutExpired as e:
        rc = -1
        stdout = as_text(e.stdout)
        stderr = as_text(e.stderr) + f"\n[TIMEOUT after {timeout}s]"
    duration_s = time.time() - start

    (pass_dir / "response.txt").write_text(stdout)
    (pass_dir / "stderr.txt").write_text(stderr)

    # If the agent didn't Write report.md, fall back to extracting from response.
    if not report_path.is_file():
        report_path.write_text(stdout)

    # `claude -p` doesn't expose token counts via the CLI; only duration.
    timing = {
        "duration_s": duration_s,
        "duration_ms": int(duration_s * 1000),
        "worker_rc": rc,
        "claude_rc": rc,
        "total_tokens": None,
        "model": model_label,
    }
    (pass_dir / "timing.json").write_text(json.dumps(timing, indent=2))

    # Snapshot the sandbox as this pass left it. Sandboxes are restaged between
    # passes, so without a per-pass copy every filesystem assertion grades
    # against whatever the LAST pass left behind — each pass reads an identical
    # verdict and per-pass state is unrecoverable. grade.py prefers this
    # snapshot and falls back to the live sandbox when it is absent.
    snapshot = pass_dir / "sandbox-snapshot"
    if snapshot.exists():
        shutil.rmtree(snapshot)
    shutil.copytree(sandbox_root, snapshot, symlinks=True)

    return timing


def run_scenario(s: dict, passes: int, run_dir: pathlib.Path,
                 resolved: vendor.Resolved, timeout: int) -> None:
    """Run all passes of a single scenario sequentially. Between passes,
    restage just this scenario's sandbox so pass-2 sees the same initial
    state as pass-1."""
    sid = s["id"]
    for p in range(1, passes + 1):
        if p > 1:
            restage_one(sid)
        run_pass(s, p, run_dir, resolved, timeout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--passes", type=int, default=None,
                        help="Override the number of passes per scenario")
    parser.add_argument("--scenario",
                        help="Run only these scenario ids — one id or a "
                             "comma-separated list (e.g. L2-1 or AS-13,AS-14). "
                             "A subset run keeps one run dir and one grading "
                             "pass, so a targeted re-run after a skill change "
                             "still produces a single comparable benchmark.")
    vendor.add_vendor_arguments(parser)
    parser.add_argument("--timeout", type=int, default=600,
                        help="Per-pass timeout in seconds (default: 600)")
    parser.add_argument("--workers", type=int, default=4,
                        help="Number of scenarios to run in parallel (default: 4). "
                             "Passes within one scenario stay sequential.")
    args = parser.parse_args()
    resolved = vendor.resolve(args)
    if shutil.which(resolved.bin) is None and not pathlib.Path(resolved.bin).is_file():
        print(
            f"ERROR: '{resolved.bin}' not found on PATH. Install the worker CLI or pass --worker-bin.",
            file=sys.stderr,
        )
        return 2

    evals = json.loads(EVALS_PATH.read_text())
    passes = args.passes if args.passes is not None else evals.get("passes", 2)
    wanted = {s.strip() for s in args.scenario.split(",") if s.strip()} if args.scenario else None
    scenarios = [e for e in evals["evals"] if wanted is None or e["id"] in wanted]
    if not scenarios:
        print(f"No scenarios match {args.scenario!r}", file=sys.stderr)
        return 2
    if wanted is not None:
        unknown = sorted(wanted - {e["id"] for e in evals["evals"]})
        if unknown:
            print(f"ERROR: unknown scenario id(s): {', '.join(unknown)}", file=sys.stderr)
            return 2

    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    run_dir = WORKSPACE / f"run-{timestamp}"
    run_dir.mkdir(parents=True)
    print(f"Run dir: {run_dir}")
    print(
        f"Worker vendor: {resolved.vendor}; command: {resolved.config.label}; "
        f"model: {resolved.worker_model or '<inherit>'}"
    )
    print(f"Scenarios: {[s['id'] for s in scenarios]}, passes per scenario: {passes}")
    vendor.preflight_auth(resolved.vendor, resolved.bin, resolved.worker_model)

    # Initial full restage (covers all scenarios). After this, per-scenario
    # restages happen inline between passes inside each scenario worker.
    subprocess.run([str(SETUP_SCRIPT)], check=True)

    workers = max(1, min(args.workers, len(scenarios)))
    print(f"Running {len(scenarios)} scenario(s) with {workers} parallel worker(s)")
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(run_scenario, s, passes, run_dir, resolved, args.timeout): s["id"]
            for s in scenarios
        }
        for fut in concurrent.futures.as_completed(futures):
            sid = futures[fut]
            try:
                fut.result()
            except Exception as e:
                print(f"  [{sid}] scenario failed: {e}", flush=True)

    # Normalize: extract report.md from response.txt where missing,
    # strip harness-noise from response.txt
    print("\nNormalizing ...")
    subprocess.run([sys.executable, str(NORMALIZE), str(run_dir)], check=False)

    # Grade
    print("\nGrading ...")
    subprocess.run([sys.executable, str(GRADE), str(run_dir)], check=True)

    # Aggregate (with optional regression compare)
    print("\nAggregating ...")
    prev = latest_previous_benchmark()
    cmd = [sys.executable, str(AGGREGATE), str(run_dir)]
    if prev:
        cmd += ["--previous", str(prev)]
        print(f"Comparing against {prev}")
    rc = subprocess.run(cmd).returncode

    # Render HTML report (best-effort)
    render = THIS / "render_report.py"
    if render.is_file():
        subprocess.run([sys.executable, str(render), str(run_dir)], check=False)

    print(f"\nDone. See:\n  {run_dir}/report.html\n  {run_dir}/benchmark.md\n  {run_dir}/grading_summary.json")
    return rc


if __name__ == "__main__":
    sys.exit(main())
