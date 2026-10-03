#!/usr/bin/env bash
# stage.sh: stage one git_review eval and print the agent-ready inputs.
#
# Usage:
#   stage.sh <eval_id> [target_dir]
#
# Prints name=value lines on stdout, each value already quoted with printf %q so
# the lines are safe to `eval`:
#
#   sandbox_repo=<absolute path to the git repo the skill reviews>
#   skill_path=<absolute path to the SKILL.md the agent should load>
#   prompt=<the user prompt to feed the agent>
#   target=<the fixture root, one level above the repo>
#   gh_env=<path to the stub-gh env file, or empty when the eval has none>
#
# The fixture and the prompt come from evals.json rather than from a case arm
# here, so the two files cannot drift apart as evals are added.
#
# Layout: every eval stages under $target as
#   $target/repo                 the git repo the agent reviews
#   $target/payloads/            (forge evals) the JSON the stub gh serves
#   $target/bin/gh               (forge evals) the stub gh itself
#   $target/gh_calls.log         (forge evals) every stub invocation, one per line
#   $target/gh_env               (forge evals) the env the runner passes through
#   $target/skill/git_review     the skill copy the worker loads, scripts shimmed
#   $target/skill/git_checkout   sibling copy, scripts shimmed to the same log
#   $target/skill/git_commit     sibling copy, scripts shimmed to the same log
#   $target/script_calls.log     every bundled-script invocation, one per line
#   $target/.eval_started_at     the staged HEAD SHA, for grade.sh

set -euo pipefail

eval_id="${1:?eval id required (see evals.json)}"
target="${2:-$(mktemp -d "${TMPDIR:-/tmp}/git_review_eval.XXXXXX")}"
mkdir -p "$target"
target="$(cd "$target" && pwd)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/plugins/ai_dev/skills"
SKILL_SRC="$SKILLS_SRC/git_review"
CHECKOUT_SRC="$SKILLS_SRC/git_checkout"
COMMIT_SRC="$SKILLS_SRC/git_commit"

# Which bundled script a run invoked is a transcript fact, and the runner keeps
# only the response, stderr and the stub gh log. So the worker loads copies of
# git_review and of the siblings it hands work to (git_checkout, git_commit)
# whose scripts/ are logging shims that record the invocation and then exec the
# real script. That gives bundled-script usage — including sibling handoffs —
# the same deterministic evidence the stub gh already gives forge calls, and it
# changes nothing that ships: the copies live in the eval sandbox and each shim
# delegates to the original, so the behaviour under test is the real script's.
stage_one_skill() {
    local src="$1" dest="$2" name
    mkdir -p "$dest"
    cp -R "$src/." "$dest/"

    for name in "$src"/scripts/*.sh; do
        [[ -e "$name" ]] || continue
        name="$(basename "$name")"
        cat > "$dest/scripts/$name" <<SHIM
#!/usr/bin/env bash
# Logging shim staged by tests/git_review/evals/stage.sh. Records the call, then
# runs the real bundled script so the behaviour under test is unchanged.
printf '%s %s\n' "$name" "\$*" >> "$target/script_calls.log"
exec "$src/scripts/$name" "\$@"
SHIM
        chmod +x "$dest/scripts/$name"
    done
}

stage_skill_copy() {
    rm -rf "$target/skill"
    mkdir -p "$target/skill"
    stage_one_skill "$SKILL_SRC" "$target/skill/git_review"
    stage_one_skill "$CHECKOUT_SRC" "$target/skill/git_checkout"
    stage_one_skill "$COMMIT_SRC" "$target/skill/git_commit"
    printf '%s' "$target/skill/git_review/SKILL.md"
}

read -r fixture prompt < <(python3 - "$HERE/evals.json" "$eval_id" <<'PY'
import json, sys
evals = json.load(open(sys.argv[1]))["evals"]
wanted = str(sys.argv[2])
for e in evals:
    if str(e["id"]) == wanted:
        # The fixture path is evals/fixtures/<name>/setup.sh.
        print(e["files"][0].split("/")[2], json.dumps(e["prompt"]))
        break
else:
    sys.exit("unknown eval id: %s" % wanted)
PY
)

# The prompt arrives JSON-encoded so a multi-line or quote-carrying prompt
# survives the single line above; decode it back here.
prompt="$(python3 -c 'import json,sys; sys.stdout.write(json.loads(sys.argv[1]))' "$prompt")"

"$HERE/fixtures/$fixture/setup.sh" "$target" >/dev/null

: > "$target/script_calls.log"
SKILL_MD="$(stage_skill_copy)"

sandbox_repo="$target/repo"
git -C "$sandbox_repo" rev-parse HEAD > "$target/.eval_started_at"

gh_env=""
[[ -f "$target/gh_env" ]] && gh_env="$target/gh_env"

printf 'sandbox_repo=%s\n' "$(printf %q "$sandbox_repo")"
printf 'skill_path=%s\n'   "$(printf %q "$SKILL_MD")"
printf 'prompt=%s\n'       "$(printf %q "$prompt")"
printf 'target=%s\n'       "$(printf %q "$target")"
printf 'gh_env=%s\n'       "$(printf %q "$gh_env")"
