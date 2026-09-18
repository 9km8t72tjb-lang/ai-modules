#!/usr/bin/env bash
# grade.sh - programmatic grader for the task_fix repeated-link evals.
#
# Usage:
#   grade.sh <eval_id> <sandbox_proj>
#
# Two graded surfaces, because the base `<lint>` repeated-link react protocol
# obliges both. The task file's bytes are read from the sandbox: a regroup must
# land, and a kept or surfaced finding must leave the file exactly as staged.
# The per-finding disposition line exists only in the run's report, read from
# $RESPONSE_FILE when the runner exports it and otherwise from the conventional
# `<sandbox_proj>/../../response.txt` that run.py's workspace layout puts it at.
# A report check with no readable response FAILS rather than passing vacuously.
#
# Judgements that stay prose - whether the gathered sentence reads well, whether
# a surfaced reason is the *right* reason - are the `expectations` in evals.json
# and the agent-attest notes below.

set -uo pipefail

eval_id="${1:?eval id required}"
proj="${2:?sandbox proj path required}"

if [[ ! -d "$proj" ]]; then
  echo "FAIL: $proj is not a directory" >&2
  exit 1
fi

target="$(cd "$proj/.." && pwd)"
marker="$target/.eval_started_at"
if [[ ! -s "$marker" ]]; then
  echo "FAIL: $marker missing or empty (did stage.sh run?)" >&2
  exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
LINT="$REPO_ROOT/plugins/ai_dev/skills/task/scripts/lint.py"
TASKS="$proj/tasks"
RESPONSE="${RESPONSE_FILE:-$target/../response.txt}"

pass=0
fail=0
failures=()

check() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass=$((pass + 1)); printf '  PASS  %s\n' "$label"
  else
    fail=$((fail + 1)); printf '  FAIL  %s\n' "$label"; failures+=("$label")
  fi
}
note_agent_attest() { printf '  -     agent-attest  %s\n' "$1"; }

# --- helpers -----------------------------------------------------------------

fm_field() {
  sed -n '/^---$/,/^---$/p' "$1" | grep -m1 "^$2:" \
    | sed "s/^$2:[[:space:]]*//; s/^[\"']//; s/[\"']$//"
}

body_text() {
  awk 'BEGIN {front=0; seen=0}
       /^---$/ && seen == 0 {front=1; seen=1; next}
       /^---$/ && front == 1 {front=0; next}
       front == 0 {print}' "$1"
}

# byte_identical <repo-relative task path> -> the file is exactly as staged.
# The staged tree is one commit, so HEAD is the fixture's own bytes.
byte_identical() {
  local rel="$1"
  git -C "$proj" show "HEAD:$rel" >"$target/.staged.md" 2>/dev/null \
    && cmp -s "$target/.staged.md" "$proj/$rel"
}

tree_lints() { python3 "$LINT" "$TASKS" --include-archive >/dev/null 2>&1; }

# no_repeated_link_finding <abs task file> -> the file carries no repeated-link
# warn. The protocol makes the gathered account, not the surviving link count,
# the measure of a resolved finding; in these fixtures the repeats that must go
# earn no link of their own, so a genuine regroup necessarily clears the warn.
# Reading the linter's verdict keeps the check off any sentence the regroup
# happened to write.
no_repeated_link_finding() {
  ! python3 "$LINT" "$TASKS" --file "$1" 2>/dev/null | grep -q 'repeated-link'
}

# sections_naming <file> <needle> -> how many H2 sections name the needle, so
# "the account sits in one place" is checked as a section count rather than as
# a match on prose the run chose.
sections_naming() {
  body_text "$1" | awk -v n="$2" '
    /^## / { sec=$0 }
    index($0, n) > 0 && sec != "" { seen[sec]=1 }
    END { c=0; for (k in seen) c++; print c }'
}

# section_body <file> <heading> -> one H2 section's text, unwrapped.
section_body() {
  body_text "$1" | awk -v h="$2" '
    $0 == h { f=1; next }
    /^## / { f=0 }
    f { print }' | tr '\n' ' ' | tr -s ' '
}

response_readable() { [[ -s "$RESPONSE" ]]; }
response_has() { response_readable && grep -qiE -- "$1" "$RESPONSE"; }

# disposition_blocks -> one line per `repeated-link:` lead-in, with that line's
# own wrapping collapsed. A report hard-wraps a disposition line across several
# physical lines, often inside a fenced block, so a line-based grep misses a
# perfectly well-formed line. Splitting on the lead-in keeps one finding's
# fields from bleeding into the next finding's, and the 400-character cap stops
# the last block from swallowing whatever prose follows it.
disposition_blocks() {
  response_readable || return 1
  tr '\n' ' ' < "$RESPONSE" | tr -s ' ' \
    | sed 's/repeated-link:/\n&/g' \
    | awk 'NR>1 { print substr($0, 1, 400) }'
}

# disposition_line <needle-for-the-target> <disposition> -> the report carries
# one shared-shape line naming this target with this disposition. Anchored on
# the `repeated-link:` lead-in the base block fixes, so a passing report is one
# that used the shape rather than one that merely mentioned the words.
disposition_line() {
  disposition_blocks | grep -qiE -- "repeated-link:.*$1.*$2"
}

no_real_repo_writes() {
  local hits
  hits="$(find "$REPO_ROOT/tasks" -type f -name 'api_*.md' -newer "$marker" 2>/dev/null)"
  [[ -z "$hits" ]]
}

# --- universal ---------------------------------------------------------------

# no_real_tasks_moved -> the real repo's tasks tree holds exactly the paths it
# held at stage time. Catches an escape that archives, creates, renames or
# deletes a real task, which the fixture-name probe above cannot see.
no_real_tasks_moved() {
  local manifest="$target/.real_tasks_manifest"
  [[ -s "$manifest" ]] || return 0
  diff -q "$manifest" <(cd "$REPO_ROOT" && find tasks -type f -name '*.md' | sort) >/dev/null
}

check "isolation: no writes to the real repo's tasks/ tree" no_real_repo_writes
check "isolation: the real repo's tasks/ tree is unmoved" no_real_tasks_moved
check "tasks tree lints clean, archive included"            tree_lints

# --- per-eval ----------------------------------------------------------------

case "$eval_id" in
  regroup_live_skip_archived)
    live="$TASKS/api_export-gzip.md"
    warn_cleared() { no_repeated_link_finding "$live"; }
    account_in_context_only() {
      [[ "$(sections_naming "$live" "api_export-schema")" == "1" ]] \
        && section_body "$live" "## Context" | grep -q 'api_export-schema'
    }
    goal_still_delivers() {
      section_body "$live" "## Goal" | grep -qiE 'gzip|compress'
    }
    handoff_survives() { grep -q 'api_export-schema' "$live"; }
    updated_bumped() {
      [[ "$(fm_field "$live" updated)" != "2026-01-01T00:00:00" ]]
    }
    link_target_untouched() { byte_identical "tasks/api_export-schema.md"; }
    archived_untouched() { byte_identical "tasks/archive/api_legacy-export.md"; }
    archived_pair_untouched() { byte_identical "tasks/archive/api_legacy-columns.md"; }
    live_line_regrouped() { disposition_line "api_export-gzip" "regrouped"; }
    archived_count_line() { disposition_blocks | grep -qiE 'repeated-link:.*archived'; }
    check "the live task's repeated-link warn is cleared"        warn_cleared
    check "the gathered account sits in ## Context only"         account_in_context_only
    check "## Goal still states what the task delivers"          goal_still_delivers
    check "the handoff account survives the regroup"             handoff_survives
    check "the live task's updated stamp is bumped"              updated_bumped
    check "the live link target is byte-identical"               link_target_untouched
    check "the archived task is byte-identical"                  archived_untouched
    check "the archived link target is byte-identical"           archived_pair_untouched
    check "the report is readable"                               response_readable
    check "the report carries the live finding's line as regrouped" live_line_regrouped
    check "the report carries the archived-count line"           archived_count_line
    note_agent_attest "the regrouped finding is counted in the closing line's N issues resolved"
    note_agent_attest "the gathered Context sentence reads as one account rather than two stitched clauses"
    ;;

  kept_each_site_earns_link)
    f="$TASKS/api_webhook-timestamp.md"
    body_unchanged() { byte_identical "tasks/api_webhook-timestamp.md"; }
    both_links_stand() {
      [[ "$(grep -c '(\.\./docs/webhooks\.md)' "$f")" == "2" ]]
    }
    kept_line() { disposition_line "api_webhook-timestamp" "kept"; }
    check "the task file is byte-identical"                  body_unchanged
    check "both links to the reference page still stand"     both_links_stand
    check "the report is readable"                           response_readable
    check "the report's line for this finding reads kept"    kept_line
    note_agent_attest "the report says each site earns its link rather than reporting the finding as resolved"
    note_agent_attest "the kept finding enters neither the resolved count nor the flagged-for-review count"
    ;;

  surfaced_acceptance_contract)
    f="$TASKS/api_retirement-audit-log.md"
    body_unchanged() { byte_identical "tasks/api_retirement-audit-log.md"; }
    link_target_untouched() { byte_identical "tasks/api_token-rotation.md"; }
    # The escape the base protocol's disposition rule closes: a link travels
    # with the clause that carried it, so a clause that stays keeps its link.
    acceptance_link_intact() {
      [[ "$(grep -c '(api_token-rotation\.md)' "$f")" == "2" ]]
    }
    surfaced_line() { disposition_line "api_retirement-audit-log" "surfaced"; }
    reason_names_acceptance() {
      disposition_blocks \
        | grep -qiE 'repeated-link:.*api_retirement-audit-log.*surfaced.*(acceptance|goal|outcome|contract|retention window)'
    }
    check "the task file is byte-identical"                        body_unchanged
    check "the link target is byte-identical"                      link_target_untouched
    check "both links stand, neither downgraded to plain text"     acceptance_link_intact
    check "the report is readable"                                 response_readable
    check "the report's line for this finding reads surfaced"      surfaced_line
    check "the surfaced reason names the contract it protects"     reason_names_acceptance
    note_agent_attest "the surfaced finding is counted in the closing line's K flagged for review"
    note_agent_attest "the reason states that gathering the account out would leave the Acceptance item nothing to measure"
    ;;

  *)
    echo "unknown eval id: $eval_id" >&2
    exit 2
    ;;
esac

echo "---"
printf 'eval-%s: %s pass, %s fail\n' "$eval_id" "$pass" "$fail"
if (( fail > 0 )); then
  printf 'failed checks:\n'
  for f in "${failures[@]}"; do printf '  - %s\n' "$f"; done
  exit 1
fi
exit 0
