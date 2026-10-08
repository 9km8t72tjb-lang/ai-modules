#!/usr/bin/env bash
# Bundled-script unit tests for the git_review skill.
#
# Covers collect_review_evidence.sh, which gathers the git layer (and the
# forge layer through a stub gh) into a scratch directory, and
# extract_heading_range.sh, which cuts an inclusive heading range out of a
# drafted report, plus the grader's report-form discrimination, the eval-32
# delta-tag fail branches, and the eval-41 push-order proofs (hook log,
# TMPDIR-scoped report.md, and grader fail branches). Repository scenarios
# stage their own sandbox under scratch/<id>/; form checks read fixtures.
# shellcheck disable=SC2329

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERE="$SCRIPT_DIR"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SKILL_DIR="$REPO_ROOT/plugins/ai_dev/skills/git_review"
COLLECT="$SKILL_DIR/scripts/collect_review_evidence.sh"
RANGE="$SKILL_DIR/scripts/extract_heading_range.sh"

SCRATCH="$SCRIPT_DIR/scratch"
RESULTS="$SCRIPT_DIR/../results/layer1.log"

PASS=0
FAIL=0
FAILED_IDS=()

mkdir -p "$SCRATCH"
mkdir -p "$(dirname "$RESULTS")"
: > "$RESULTS"

log() { printf '%s\n' "$*" | tee -a "$RESULTS" >&2; }

scenario() {
    local id=$1 desc=$2 body=$3
    log ""
    log "=== $id  $desc ==="
    if "$body"; then
        PASS=$((PASS + 1))
        log "  PASS"
    else
        FAIL=$((FAIL + 1))
        FAILED_IDS+=("$id")
        log "  FAIL"
    fi
}

# `check <label> <cmd...>` reports through the same tallies, which is what
# tests/lib/plugin_version.sh expects from a sourcing harness.
check() {
    local label=$1
    shift
    log ""
    log "=== $label ==="
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS + 1))
        log "  PASS"
    else
        FAIL=$((FAIL + 1))
        FAILED_IDS+=("$label")
        log "  FAIL"
    fi
}

assert_contains() {
    local label=$1 haystack=$2 needle=$3
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    fi
    log "    [missing substring: $label]"
    log "      needle: $(printf '%q' "$needle")"
    return 1
}

assert_absent() {
    local label=$1 haystack=$2 needle=$3
    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    fi
    log "    [unexpected substring: $label]"
    log "      needle: $(printf '%q' "$needle")"
    return 1
}

assert_eq() {
    local label=$1 actual=$2 expected=$3
    if [[ "$actual" == "$expected" ]]; then
        return 0
    fi
    log "    [diff: $label]"
    log "      expected: $(printf '%q' "$expected")"
    log "      actual:   $(printf '%q' "$actual")"
    return 1
}

assert_file() {
    local label=$1 path=$2
    if [[ -s "$path" ]]; then
        return 0
    fi
    log "    [missing or empty file: $label -> $path]"
    return 1
}

# Read one `key: value` line from a size_profile.txt (or similar) file.
profile_value() {
    local file=$1 key=$2
    awk -F': ' -v k="$key" '$1 == k { print $2; exit }' "$file"
}

# Sum added and removed columns from `git diff --numstat` on stdin, skipping
# binary rows where either column is `-`. Prints "added removed".
sum_numstat_text() {
    awk '$1 != "-" && $2 != "-" { a += $1; r += $2 }
         END { printf "%d %d\n", a + 0, r + 0 }'
}

identity() {
    git config user.email "harness@example.com"
    git config user.name "Harness"
}

# Stage one bare origin plus a clone with a base commit and a feature branch
# that adds, deletes, renames, and modifies paths, so one sandbox exercises the
# whole evidence set.
fresh_repo() {
    local id=$1
    local root="$SCRATCH/$id"

    rm -rf "$root"
    mkdir -p "$root"
    git init --quiet --bare --initial-branch=main "$root/origin.git" || return 1
    git clone --quiet "$root/origin.git" "$root/repo" 2>/dev/null || return 1
    (
        cd "$root/repo" || exit 1
        identity
        printf 'alpha one\nalpha two\n' > alpha.txt
        printf 'to be deleted\n' > gone.txt
        printf 'to be renamed\nsecond line\nthird line\n' > old_name.txt
        mkdir -p vendor
        printf 'vendored\n' > vendor/lib.txt
        git add -A
        git commit --quiet -m "seed the base tree"
        git push --quiet origin main
        git remote set-head origin main

        git checkout --quiet -b feature
        printf 'alpha one\nalpha two\nalpha three\n' > alpha.txt
        git rm --quiet gone.txt
        git mv old_name.txt new_name.txt
        printf 'key = "AKIAIOSFODNN7EXAMPLE"\ncache = "/home/alice/.cache"\n' > cfg.py
        printf 'generated\n' > api_generated.go
        git add -A
        git commit --quiet -m "feature: add, delete, rename, and modify"
        git push --quiet -u origin feature
    ) || return 1
    printf '%s' "$root/repo"
}

collect() {
    local repo=$1
    shift
    local out rc
    out=$(cd "$repo" && "$COLLECT" "$@" 2>&1) && rc=0 || rc=$?
    printf '%s|%s' "$rc" "$out"
}

# --- collect_review_evidence.sh ----------------------------------------------

s1_fetches_before_the_three_dot_diff() {
    local repo ret rc out ev fetch_line diff_line
    repo=$(fresh_repo s1) || return 1
    ev="$SCRATCH/s1/ev"

    ret=$(collect "$repo" --base main --head feature --out "$ev")
    rc=${ret%%|*}
    out=${ret#*|}

    local ok=true
    assert_eq "exit" "$rc" "0" || ok=false
    assert_file "steps.log" "$ev/steps.log" || ok=false
    assert_file "fetch.log" "$ev/fetch.log" || ok=false

    # The ordered step log is what proves the fetch preceded the diff rather
    # than merely also happening.
    fetch_line=$(grep -n 'fetch base and head refs' "$ev/steps.log" | head -1 | cut -d: -f1)
    diff_line=$(grep -n 'three-dot diff stat' "$ev/steps.log" | head -1 | cut -d: -f1)
    if [[ -z "$fetch_line" || -z "$diff_line" ]] || ((fetch_line >= diff_line)); then
        log "    [fetch did not precede the three-dot diff: fetch=$fetch_line diff=$diff_line]"
        ok=false
    fi
    assert_contains "fetch command recorded" "$(cat "$ev/fetch.log")" "git fetch --all --no-prune" || ok=false
    assert_contains "stdout points at the manifest" "$out" "manifest.txt" || ok=false
    $ok
}

# head_sync.txt answers a different question from counts.txt: how far the local
# branch sits from its own upstream, rather than from the base. It is the only
# input the fast-forward decision has, so a stale local head is reviewed
# silently when it is missing or wrong.
s20_head_sync_reports_the_upstream_relationship() {
    local repo ret ev sync side
    repo=$(fresh_repo s20) || return 1
    ev="$SCRATCH/s20/ev"

    # In sync first: feature was just pushed with an upstream set.
    ret=$(collect "$repo" --base main --head feature --out "$ev")
    sync=$(cat "$ev/head_sync.txt" 2>/dev/null)

    local ok=true
    assert_eq "exit" "${ret%%|*}" "0" || ok=false
    assert_contains "manifest lists head_sync" "$(cat "$ev/manifest.txt" 2>/dev/null)" "head_sync.txt" || ok=false
    assert_contains "branch named" "$sync" "branch: feature" || ok=false
    assert_contains "upstream named" "$sync" "upstream: origin/feature" || ok=false
    assert_contains "in sync when nothing moved" "$sync" "head_vs_upstream: in sync" || ok=false

    # A commit lands on the remote from a side clone, so the local branch falls
    # behind while its worktree stays clean.
    side="$SCRATCH/s20/side"
    git clone --quiet --branch feature "$SCRATCH/s20/origin.git" "$side" 2>/dev/null || return 1
    (
        cd "$side" || exit 1
        identity
        printf 'alpha one\nalpha two\nalpha three\nalpha four\n' > alpha.txt
        git add alpha.txt
        git commit --quiet -m "alpha.txt -> add the fourth line"
        git push --quiet origin feature
    ) || return 1

    ev="$SCRATCH/s20/ev2"
    ret=$(collect "$repo" --base main --head feature --out "$ev")
    sync=$(cat "$ev/head_sync.txt" 2>/dev/null)

    assert_eq "exit after the side push" "${ret%%|*}" "0" || ok=false
    assert_contains "behind by one" "$sync" "head_vs_upstream: behind 1" || ok=false
    # The two heads must be reported distinctly, so the report can name which
    # commit it reviewed and which one it should have.
    if [[ "$(printf '%s' "$sync" | sed -n 's/^local_head: //p')" == \
          "$(printf '%s' "$sync" | sed -n 's/^remote_head: //p')" ]]; then
        log "    [local_head and remote_head are equal after the side push]"
        ok=false
    fi

    # The remote-qualified form names the same branch, so its upstream resolves
    # rather than reading as a branch called origin/feature.
    ev="$SCRATCH/s20/ev3"
    collect "$repo" --base main --head origin/feature --out "$ev" >/dev/null
    sync=$(cat "$ev/head_sync.txt" 2>/dev/null)
    assert_contains "remote-qualified head resolves to the branch" "$sync" "branch: feature" || ok=false
    $ok
}

s2_manifest_lists_the_whole_evidence_set() {
    local repo ret ev manifest
    repo=$(fresh_repo s2) || return 1
    ev="$SCRATCH/s2/ev"
    ret=$(collect "$repo" --base main --head feature --out "$ev")
    manifest=$(cat "$ev/manifest.txt" 2>/dev/null)

    local ok=true
    assert_eq "exit" "${ret%%|*}" "0" || ok=false
    assert_contains "commits without merges" "$manifest" "commits_no_merges.txt" || ok=false
    assert_contains "commits along first parent" "$manifest" "commits_first_parent.txt" || ok=false
    assert_contains "removed hunks" "$manifest" "removed_hunks.txt" || ok=false
    assert_contains "base-side versions" "$manifest" "base_side/" || ok=false
    assert_contains "name-status" "$manifest" "name_status.txt" || ok=false
    assert_contains "merge base" "$manifest" "merge_base.txt" || ok=false
    assert_contains "counts" "$manifest" "counts.txt" || ok=false
    assert_contains "test merge" "$manifest" "merge_tree.txt" || ok=false
    assert_contains "secret scan" "$manifest" "secret_scan.txt" || ok=false
    assert_contains "size profile" "$manifest" "size_profile.txt" || ok=false
    assert_contains "gate list" "$manifest" "gates.txt" || ok=false
    $ok
}

s3_name_status_detects_the_rename() {
    local repo ev name_status
    repo=$(fresh_repo s3) || return 1
    ev="$SCRATCH/s3/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    name_status=$(cat "$ev/name_status.txt" 2>/dev/null)

    local ok=true
    assert_contains "rename status" "$name_status" "R" || ok=false
    assert_contains "rename old path" "$name_status" "old_name.txt" || ok=false
    assert_contains "rename new path" "$name_status" "new_name.txt" || ok=false
    assert_contains "deletion" "$name_status" "gone.txt" || ok=false
    assert_contains "modification" "$name_status" "alpha.txt" || ok=false
    $ok
}

s4_commit_lists_cover_both_walks() {
    local repo ev no_merges first_parent
    repo=$(fresh_repo s4) || return 1
    ev="$SCRATCH/s4/ev"

    # An in-branch merge from the base, so the two walks differ.
    (
        cd "$repo" || exit 1
        git checkout --quiet main
        # A path neither side of the merge touches, so the merge lands cleanly
        # and the two commit walks genuinely differ.
        printf 'base moved on\n' > base_only.txt
        git add base_only.txt
        git commit --quiet -m "base: add base_only.txt"
        git push --quiet origin main
        git checkout --quiet feature
        git merge --no-edit -m "merge main into feature" main >/dev/null 2>&1 || exit 1
        git push --quiet origin feature
    ) || return 1

    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    no_merges=$(cat "$ev/commits_no_merges.txt" 2>/dev/null)
    first_parent=$(cat "$ev/commits_first_parent.txt" 2>/dev/null)

    local ok=true
    assert_contains "branch work in the no-merges walk" "$no_merges" "feature: add, delete, rename, and modify" || ok=false
    assert_absent "merge commit excluded from the no-merges walk" "$no_merges" "merge main into feature" || ok=false
    assert_contains "merge commit visible along the first parent" "$first_parent" "merge main into feature" || ok=false
    $ok
}

s5_removed_hunks_and_base_side_versions() {
    local repo ev removed index deleted
    repo=$(fresh_repo s5) || return 1
    ev="$SCRATCH/s5/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    removed=$(cat "$ev/removed_hunks.txt" 2>/dev/null)
    index=$(cat "$ev/base_side/index.txt" 2>/dev/null)
    deleted=$(cat "$ev/base_side/gone.txt" 2>/dev/null)

    local ok=true
    assert_contains "removed line from the deleted file" "$removed" "-to be deleted" || ok=false
    assert_contains "deleted file in the base-side index" "$index" "gone.txt" || ok=false
    assert_contains "modified file in the base-side index" "$index" "alpha.txt" || ok=false
    assert_eq "base-side content of the deleted file" "$deleted" "to be deleted" || ok=false
    $ok
}

s6_clean_test_merge_reports_no_conflict() {
    local repo ev conflicts
    repo=$(fresh_repo s6) || return 1
    ev="$SCRATCH/s6/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    conflicts=$(cat "$ev/conflicts.txt" 2>/dev/null)

    local ok=true
    assert_contains "no conflicts" "$conflicts" "conflicts: none" || ok=false
    assert_contains "mergeable yes" "$conflicts" "structurally_mergeable: yes" || ok=false
    $ok
}

s7_conflicting_test_merge_names_the_file() {
    local repo ev conflicts
    repo=$(fresh_repo s7) || return 1
    ev="$SCRATCH/s7/ev"

    (
        cd "$repo" || exit 1
        git checkout --quiet main
        printf 'alpha one\nbase rewrote this\n' > alpha.txt
        git commit --quiet -am "base: rewrite alpha"
        git push --quiet origin main
        git checkout --quiet feature
    ) || return 1

    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    conflicts=$(cat "$ev/conflicts.txt" 2>/dev/null)

    local ok=true
    assert_contains "conflicts reported" "$conflicts" "conflicts: yes" || ok=false
    assert_contains "mergeable no" "$conflicts" "structurally_mergeable: no" || ok=false
    assert_contains "conflicting file named" "$conflicts" "alpha.txt" || ok=false
    $ok
}

s8_counts_and_merge_base() {
    local repo ev counts merge_base
    repo=$(fresh_repo s8) || return 1
    ev="$SCRATCH/s8/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    counts=$(cat "$ev/counts.txt" 2>/dev/null)
    merge_base=$(cat "$ev/merge_base.txt" 2>/dev/null)

    local ok=true
    assert_contains "ahead count" "$counts" "ahead: 1" || ok=false
    assert_contains "behind count" "$counts" "behind: 0" || ok=false
    assert_eq "merge base is the seed commit" "$merge_base" \
        "$(cd "$repo" && git rev-parse main)" || ok=false
    $ok
}

s9_secret_scan_finds_both_shapes() {
    local repo ev scan
    repo=$(fresh_repo s9) || return 1
    ev="$SCRATCH/s9/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    scan=$(cat "$ev/secret_scan.txt" 2>/dev/null)

    local ok=true
    assert_contains "credential pattern" "$scan" "AKIAIOSFODNN7EXAMPLE" || ok=false
    assert_contains "hardcoded home path" "$scan" "/home/alice/" || ok=false
    $ok
}

s10_size_profile_counts_generated_files() {
    local repo ev profile
    repo=$(fresh_repo s10) || return 1
    ev="$SCRATCH/s10/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    profile=$(cat "$ev/size_profile.txt" 2>/dev/null)

    local ok=true
    assert_contains "changed file count" "$profile" "changed_files: 5" || ok=false
    assert_contains "generated file count" "$profile" "generated_files: 1" || ok=false
    assert_contains "share is stated" "$profile" "binary_or_generated_share:" || ok=false
    assert_contains "generated path listed" "$profile" "api_generated.go" || ok=false
    $ok
}

s11_uncommitted_mode_reports_both_lanes() {
    local repo ev status worktree_diff local_commits profile
    local staged_sum unstaged_sum expect_added expect_removed actual_added actual_removed
    local sa sr ua ur untracked_lines
    repo=$(fresh_repo s11) || return 1
    ev="$SCRATCH/s11/ev"

    (
        cd "$repo" || exit 1
        git checkout --quiet main
        printf 'a local commit\n' > ahead.txt
        git add ahead.txt
        git commit --quiet -m "ahead.txt -> one commit ahead of the upstream"
        printf 'alpha one\nstaged edit\n' > alpha.txt
        git add alpha.txt
        printf 'unstaged edit\n' > vendor/lib.txt
        printf 'untracked\n' > brand_new.txt
    ) || return 1

    collect "$repo" --uncommitted --out "$ev" >/dev/null
    status=$(cat "$ev/worktree_status.txt" 2>/dev/null)
    worktree_diff=$(cat "$ev/worktree_diff.txt" 2>/dev/null)
    local_commits=$(cat "$ev/local_commits.txt" 2>/dev/null)
    profile=$(cat "$ev/size_profile.txt" 2>/dev/null)

    staged_sum=$(cd "$repo" && git diff --cached --numstat | sum_numstat_text)
    unstaged_sum=$(cd "$repo" && git diff --numstat | sum_numstat_text)
    sa=${staged_sum%% *}; sr=${staged_sum##* }
    ua=${unstaged_sum%% *}; ur=${unstaged_sum##* }
    untracked_lines=0
    while IFS= read -r f; do
        [[ -z "$f" || ! -f "$repo/$f" ]] && continue
        untracked_lines=$((untracked_lines + $(wc -l < "$repo/$f" | tr -d ' ')))
    done < <(cd "$repo" && git ls-files --others --exclude-standard)
    expect_added=$((sa + ua + untracked_lines))
    expect_removed=$((sr + ur))
    actual_added=$(profile_value "$ev/size_profile.txt" added_lines)
    actual_removed=$(profile_value "$ev/size_profile.txt" removed_lines)

    local ok=true
    assert_contains "staged path" "$status" "alpha.txt" || ok=false
    assert_contains "unstaged path" "$status" "vendor/lib.txt" || ok=false
    assert_contains "untracked path" "$status" "brand_new.txt" || ok=false
    assert_contains "staged lane" "$worktree_diff" "### staged" || ok=false
    assert_contains "unstaged lane" "$worktree_diff" "### unstaged" || ok=false
    assert_contains "untracked content included" "$worktree_diff" "+untracked" || ok=false
    assert_contains "upstream named" "$local_commits" "upstream: origin/main" || ok=false
    assert_contains "ahead count" "$local_commits" "ahead: 1" || ok=false
    assert_contains "commit message carried" "$local_commits" "one commit ahead of the upstream" || ok=false
    assert_eq "uncommitted added_lines match lane numstats plus untracked" \
        "$actual_added" "$expect_added" || ok=false
    assert_eq "uncommitted removed_lines match lane numstats" \
        "$actual_removed" "$expect_removed" || ok=false
    assert_contains "size profile present" "$profile" "added_lines:" || ok=false
    $ok
}

s12_reads_only_and_leaves_the_tree_alone() {
    local repo ev before after stash worktrees
    repo=$(fresh_repo s12) || return 1
    ev="$SCRATCH/s12/ev"

    (cd "$repo" && printf 'dirty edit\n' >> alpha.txt) || return 1
    before=$(cd "$repo" && git status --porcelain --untracked-files=all)
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    after=$(cd "$repo" && git status --porcelain --untracked-files=all)
    stash=$(cd "$repo" && git stash list)
    worktrees=$(cd "$repo" && git worktree list | wc -l | tr -d ' ')

    local ok=true
    assert_eq "working tree unchanged" "$after" "$before" || ok=false
    assert_eq "no stash created" "$stash" "" || ok=false
    assert_eq "no extra worktree" "$worktrees" "1" || ok=false
    assert_contains "dirty state recorded" "$(cat "$ev/target.txt")" "worktree_state: dirty" || ok=false
    $ok
}

s13_forge_layer_absent_is_recorded() {
    local repo ev status
    repo=$(fresh_repo s13) || return 1
    ev="$SCRATCH/s13/ev"
    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    status=$(cat "$ev/forge/status.txt" 2>/dev/null)

    local ok=true
    # The origin here is a local path, so the git-only path applies whether or
    # not the operator has gh installed.
    assert_contains "forge layer unavailable" "$status" "forge layer unavailable" || ok=false
    $ok
}

s14_forge_layer_pages_threads_and_counts_them() {
    local repo ev counts threads pages
    repo=$(fresh_repo s14) || return 1
    ev="$SCRATCH/s14/ev"
    local root="$SCRATCH/s14"
    local payloads="$root/payloads"

    stage_gh_stub "$root" "$payloads" || return 1
    (
        cd "$repo" || exit 1
        git config "url.$root/origin.git.insteadOf" "https://github.com/acme/widget.git"
        git remote set-url origin "https://github.com/acme/widget.git"
    ) || return 1

    (
        cd "$repo" || exit 1
        PATH="$root/bin:$PATH" \
        GH_STUB_LOG="$root/gh_calls.log" \
        GH_STUB_PAYLOADS="$payloads" \
        "$COLLECT" --base main --head feature --out "$ev" --pr 7 --no-fetch
    ) >/dev/null 2>&1

    counts=$(cat "$ev/forge/counts.txt" 2>/dev/null)
    threads=$(cat "$ev/forge/review_threads.json" 2>/dev/null)
    pages=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["pages"])' \
        "$ev/forge/review_threads.json" 2>/dev/null)

    local ok=true
    assert_contains "forge available" "$(cat "$ev/forge/status.txt")" "available" || ok=false
    assert_contains "issue comment count" "$counts" "issue_comments: 2" || ok=false
    assert_contains "review count" "$counts" "reviews: 1" || ok=false
    assert_contains "thread count with states" "$counts" "review_threads: 3 (resolved: 1, outdated: 1)" || ok=false
    assert_eq "both pages read" "$pages" "2" || ok=false
    assert_contains "resolved thread kept" "$threads" "T_resolved_naming" || ok=false
    assert_contains "outdated thread kept" "$threads" "T_outdated_import" || ok=false

    # The resolved thread's comments run onto a second page, which only a
    # request through the thread's own node id reaches.
    local comment_pages
    comment_pages=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["comment_pages"])' \
        "$ev/forge/review_threads.json" 2>/dev/null)
    assert_contains "comment page requested by thread id" \
        "$(cat "$root/gh_calls.log" 2>/dev/null)" "id=T_resolved_naming" || ok=false
    assert_contains "second comment page folded into its thread" "$threads" "second-page reply" || ok=false
    assert_eq "one comment page followed" "$comment_pages" "1" || ok=false
    $ok
}

s15_usage_and_argument_handling() {
    local help_out help_rc missing_rc bad_rc not_a_repo_rc tmp
    help_out=$("$COLLECT" --help 2>&1) && help_rc=0 || help_rc=$?
    (cd "$SCRATCH" && "$COLLECT" --head feature >/dev/null 2>&1) && missing_rc=0 || missing_rc=$?
    (cd "$SCRATCH" && "$COLLECT" --nonsense >/dev/null 2>&1) && bad_rc=0 || bad_rc=$?
    tmp=$(mktemp -d)
    (cd "$tmp" && "$COLLECT" --base main --head feature >/dev/null 2>&1) && not_a_repo_rc=0 || not_a_repo_rc=$?
    rm -rf "$tmp"

    local ok=true
    assert_eq "help exit" "$help_rc" "0" || ok=false
    assert_contains "usage" "$help_out" "Usage:" || ok=false
    assert_contains "exit codes documented" "$help_out" "Exit codes:" || ok=false
    assert_eq "missing --base exits 1" "$missing_rc" "1" || ok=false
    assert_eq "unknown argument exits 1" "$bad_rc" "1" || ok=false
    assert_eq "outside a repository exits 2" "$not_a_repo_rc" "2" || ok=false
    $ok
}

# The unreadable_path fixture hides one changed blob from git. The collector
# must keep the readable path in the evidence set and record the locked path as
# unread rather than emptying the whole-range diff.
s22_unreadable_path_records_unread_remainder() {
    local target repo ret ev ok=true
    local path status renamed expect_added expect_removed actual_added actual_removed path_sum pa pr
    target="$SCRATCH/s22"
    rm -rf "$target"
    mkdir -p "$target"
    repo=$("$HERE/../evals/fixtures/unreadable_path/setup.sh" "$target") || return 1
    ev="$target/ev"
    ret=$(collect "$repo" --base main --head widen --out "$ev" --no-fetch)
    assert_eq "exit" "${ret%%|*}" "0" || ok=false
    assert_contains "unread_paths lists locked.py" "$(cat "$ev/unread_paths.txt" 2>/dev/null)" \
        "src/locked.py" || ok=false
    assert_contains "manifest lists unread_paths" "$(cat "$ev/manifest.txt" 2>/dev/null)" \
        "unread_paths.txt" || ok=false
    assert_contains "full_diff keeps readable.py" "$(cat "$ev/full_diff.txt" 2>/dev/null)" \
        "src/readable.py" || ok=false
    assert_contains "diff_stat keeps readable.py" "$(cat "$ev/diff_stat.txt" 2>/dev/null)" \
        "src/readable.py" || ok=false
    assert_contains "removed_hunks keeps readable.py" "$(cat "$ev/removed_hunks.txt" 2>/dev/null)" \
        "src/readable.py" || ok=false
    assert_absent "full_diff hides secret_flag" "$(cat "$ev/full_diff.txt" 2>/dev/null)" \
        "secret_flag" || ok=false

    # Size profile counts only the readable paths the per-path fallback kept.
    expect_added=0
    expect_removed=0
    while IFS=$'\t' read -r status path renamed; do
        [[ -z "$status" ]] && continue
        case "$status" in
            R*|C*) path="${renamed:-$path}" ;;
        esac
        grep -qxF "$path" "$ev/unread_paths.txt" 2>/dev/null && continue
        path_sum=$(git -C "$repo" diff --numstat -M "main...widen" -- "$path" 2>/dev/null |
            sum_numstat_text)
        pa=${path_sum%% *}; pr=${path_sum##* }
        expect_added=$((expect_added + pa))
        expect_removed=$((expect_removed + pr))
    done < "$ev/name_status.txt"
    actual_added=$(profile_value "$ev/size_profile.txt" added_lines)
    actual_removed=$(profile_value "$ev/size_profile.txt" removed_lines)
    assert_eq "per-path fallback added_lines match readable numstat" \
        "$actual_added" "$expect_added" || ok=false
    assert_eq "per-path fallback removed_lines match readable numstat" \
        "$actual_removed" "$expect_removed" || ok=false

    # Acceptance git-command hide checks on the staged sandbox.
    git -C "$repo" show "HEAD:src/locked.py" >/dev/null 2>&1 && {
        log "    [git show HEAD:src/locked.py unexpectedly succeeded]"
        ok=false
    }
    git -C "$repo" diff "main...HEAD" -- src/locked.py >/dev/null 2>&1 && {
        log "    [git diff of src/locked.py unexpectedly succeeded]"
        ok=false
    }
    git -C "$repo" show "HEAD:src/readable.py" >/dev/null 2>&1 || {
        log "    [git show HEAD:src/readable.py failed]"
        ok=false
    }
    git -C "$repo" fetch --all >/dev/null 2>&1 || {
        log "    [git fetch --all failed]"
        ok=false
    }
    test ! -e "$repo/src/locked.py" || {
        log "    [src/locked.py is present in the worktree]"
        ok=false
    }
    $ok
}

# Range-mode size profile: content-line counts equal git diff --numstat, and the
# fixture keeps hunk lines that begin with --- / +++ so a header-inclusive or
# plain grep -v filter would miscount.
s24_size_profile_line_counts_match_numstat() {
    local root repo ev ok=true
    local expect_sum expect_added expect_removed actual_added actual_removed full_diff
    root="$SCRATCH/s24"
    rm -rf "$root"
    mkdir -p "$root"
    git init --quiet --bare --initial-branch=main "$root/origin.git" || return 1
    git clone --quiet "$root/origin.git" "$root/repo" 2>/dev/null || return 1
    (
        cd "$root/repo" || exit 1
        identity
        printf 'keep\n-- note\nalso keep\n' > notes.sql
        printf 'plain\n' > keep.txt
        printf 'rename me\n' > old_name.txt
        printf 'delete me\n' > gone.txt
        # NUL so git treats this as binary (numstat prints -, no ---/+++ pair).
        printf 'bin\000v1' > data.bin
        git add -A
        git commit --quiet -m "seed the size-profile fixture"
        git push --quiet origin main
        git remote set-head origin main

        git checkout --quiet -b feature
        # Remove the SQL comment so the hunk carries a content line "--- note".
        printf 'keep\nalso keep\n' > notes.sql
        # Add a line that begins with ++ so the hunk carries "+++ x".
        printf 'plain\n++ x\n' > keep.txt
        printf 'brand new\n' > added.txt
        git rm --quiet gone.txt
        git mv old_name.txt new_name.txt
        printf 'bin\000v2-longer' > data.bin
        git add -A
        git commit --quiet -m "feature: modify, add, delete, rename, binary, and ---/+++ content"
        git push --quiet -u origin feature
    ) || return 1
    repo="$root/repo"
    ev="$root/ev"

    collect "$repo" --base main --head feature --out "$ev" >/dev/null
    expect_sum=$(cd "$repo" && git diff --numstat -M "main...feature" | sum_numstat_text)
    expect_added=${expect_sum%% *}
    expect_removed=${expect_sum##* }
    actual_added=$(profile_value "$ev/size_profile.txt" added_lines)
    actual_removed=$(profile_value "$ev/size_profile.txt" removed_lines)
    full_diff=$(cat "$ev/full_diff.txt" 2>/dev/null)

    assert_eq "range added_lines match numstat" "$actual_added" "$expect_added" || ok=false
    assert_eq "range removed_lines match numstat" "$actual_removed" "$expect_removed" || ok=false
    # Hunk content (not the file headers): a removed "-- note" and an added "++ x".
    if ! printf '%s\n' "$full_diff" | grep -E '^--- note$' >/dev/null; then
        log "    [missing hunk content line --- note]"
        ok=false
    fi
    if ! printf '%s\n' "$full_diff" | grep -E '^\+\+\+ x$' >/dev/null; then
        log "    [missing hunk content line +++ x]"
        ok=false
    fi
    # Confirm the fixture exercised every Approach-named edit class.
    assert_contains "name-status records the rename" \
        "$(cat "$ev/name_status.txt" 2>/dev/null)" "old_name.txt" || ok=false
    assert_contains "name-status records the deletion" \
        "$(cat "$ev/name_status.txt" 2>/dev/null)" "gone.txt" || ok=false
    assert_contains "name-status records the addition" \
        "$(cat "$ev/name_status.txt" 2>/dev/null)" "added.txt" || ok=false
    # binary_files: 1 fails when data.bin is still text; a name-only check cannot.
    assert_contains "size profile counts the modified binary" \
        "$(cat "$ev/size_profile.txt" 2>/dev/null)" "binary_files: 1" || ok=false
    $ok
}

# --- extract_heading_range.sh ------------------------------------------------

write_report() {
    local path=$1
    cat > "$path" <<'REPORT'
# Review of feature/export

Reviewed commit `abc1234`. Tree state: clean.

## What the changes do and implement

The branch adds an export command.

## What it retires

The legacy format table is gone.

## What is critical

The export path opens a network connection, which CHARTER.md forbids.

## Bugs it may introduce

The loop walks one past the end of rows.

## Decisions the implementer must make before fixing

Whether retries live here or in the transport.

## Can it be structurally merged as it is

Yes.
REPORT
}

s16_inclusive_heading_range() {
    local report out
    report="$SCRATCH/s16_report.md"
    write_report "$report"
    out=$("$RANGE" "$report" "What is critical" "Decisions the implementer must make before fixing")

    local ok=true
    assert_contains "starts at the from heading" "$out" "## What is critical" || ok=false
    assert_contains "carries the from section" "$out" "CHARTER.md forbids" || ok=false
    assert_contains "carries the middle section" "$out" "## Bugs it may introduce" || ok=false
    assert_contains "ends with the to heading" "$out" "## Decisions the implementer must make before fixing" || ok=false
    assert_contains "carries the to section" "$out" "Whether retries live here" || ok=false
    assert_absent "stops before the next heading" "$out" "## Can it be structurally merged as it is" || ok=false
    assert_absent "excludes earlier sections" "$out" "## What it retires" || ok=false
    $ok
}

s17_range_to_end_of_file() {
    local report out
    report="$SCRATCH/s17_report.md"
    write_report "$report"
    out=$("$RANGE" "$report" "Bugs it may introduce")

    local ok=true
    assert_contains "starts at the named heading" "$out" "## Bugs it may introduce" || ok=false
    assert_contains "runs to the last heading" "$out" "## Can it be structurally merged as it is" || ok=false
    assert_absent "excludes earlier sections" "$out" "## What is critical" || ok=false
    $ok
}

s18_range_errors_and_listing() {
    local report missing_rc backwards_rc unreadable_rc list_out
    report="$SCRATCH/s18_report.md"
    write_report "$report"

    "$RANGE" "$report" "No Such Heading" >/dev/null 2>&1 && missing_rc=0 || missing_rc=$?
    "$RANGE" "$report" "Can it be structurally merged as it is" "What it retires" \
        >/dev/null 2>&1 && backwards_rc=0 || backwards_rc=$?
    "$RANGE" "$SCRATCH/does_not_exist.md" "Anything" >/dev/null 2>&1 && unreadable_rc=0 || unreadable_rc=$?
    list_out=$("$RANGE" --list "$report")

    local ok=true
    assert_eq "absent heading exits 3" "$missing_rc" "3" || ok=false
    assert_eq "backwards range exits 3" "$backwards_rc" "3" || ok=false
    assert_eq "unreadable file exits 1" "$unreadable_rc" "1" || ok=false
    assert_contains "listing carries a heading" "$list_out" "What is critical" || ok=false
    $ok
}

s19_single_heading_range_is_that_section_alone() {
    local report out
    report="$SCRATCH/s19_report.md"
    write_report "$report"
    out=$("$RANGE" "$report" "What it retires" "What it retires")

    local ok=true
    assert_contains "the heading itself" "$out" "## What it retires" || ok=false
    assert_contains "its body" "$out" "legacy format table" || ok=false
    assert_absent "nothing after it" "$out" "## What is critical" || ok=false
    $ok
}

# --- stub gh ------------------------------------------------------------------

# A minimal stub gh for s14: serves two pages of review threads plus the other
# surfaces, and records every call.
stage_gh_stub() {
    local root=$1 payloads=$2
    mkdir -p "$root/bin" "$payloads"
    : > "$root/gh_calls.log"

    cat > "$root/bin/gh" <<'GH'
#!/usr/bin/env bash
set -uo pipefail
printf '%s\n' "$*" >> "${GH_STUB_LOG:?}"
serve() { [[ -f "$GH_STUB_PAYLOADS/$1" ]] && cat "$GH_STUB_PAYLOADS/$1" || printf '{}\n'; }
case "${1:-}" in
  auth) exit 0 ;;
  pr)
    if [[ "$*" == *"--json comments"* ]]; then serve comments.json
    elif [[ "$*" == *"--json reviews"* ]]; then serve reviews.json
    elif [[ "$*" == *"statusCheckRollup"* ]]; then serve checks.json
    else serve pr.json
    fi
    ;;
  api)
    if [[ "$*" == *"PullRequestReviewThread"* ]]; then serve thread_comments2.json
    elif [[ "$*" == *"-F cursor="* ]]; then serve threads2.json
    elif [[ "$*" == *"query="* ]]; then serve threads1.json
    else printf '[]\n'
    fi
    ;;
  *) printf '{}\n' ;;
esac
GH
    chmod +x "$root/bin/gh"

    printf '{"number": 7, "headRefOid": "deadbeef"}\n' > "$payloads/pr.json"
    printf '{"comments": [{"body": "one"}, {"body": "two"}]}\n' > "$payloads/comments.json"
    printf '{"reviews": [{"body": "a review"}]}\n' > "$payloads/reviews.json"
    printf '{"statusCheckRollup": []}\n' > "$payloads/checks.json"

    cat > "$payloads/threads1.json" <<'JSON'
{"data": {"repository": {"pullRequest": {"reviewThreads": {
  "pageInfo": {"hasNextPage": true, "endCursor": "PAGE2"},
  "nodes": [{"id": "T_open", "isResolved": false, "isOutdated": false,
             "comments": {"nodes": [{"body": "open thread"}]}}]}}}}}
JSON
    cat > "$payloads/threads2.json" <<'JSON'
{"data": {"repository": {"pullRequest": {"reviewThreads": {
  "pageInfo": {"hasNextPage": false, "endCursor": null},
  "nodes": [{"id": "T_resolved_naming", "isResolved": true, "isOutdated": false,
             "comments": {"pageInfo": {"hasNextPage": true, "endCursor": "CPAGE2"},
                          "nodes": [{"body": "resolved thread"}]}},
            {"id": "T_outdated_import", "isResolved": false, "isOutdated": true,
             "comments": {"nodes": [{"body": "outdated thread"}]}}]}}}}}
JSON
    cat > "$payloads/thread_comments2.json" <<'JSON'
{"data": {"node": {"comments": {
  "pageInfo": {"hasNextPage": false, "endCursor": null},
  "nodes": [{"body": "second-page reply"}]}}}}
JSON
}

s21_delta_rereview_tag_grader() {
    local target="$SCRATCH/s21"
    local grader="$HERE/../evals/grade.sh"
    local complete="$HERE/fixtures/delta_rereview_complete.md"
    local follow_up first_sha first_py reviews comments out rc ok=true

    rm -rf "$target"
    mkdir -p "$target"
    bash "$HERE/../evals/stage.sh" 32 "$target" >/dev/null || return 1

    follow_up="$(cat "$target/repo/src/export.py")"
    first_sha="$(cat "$target/.first_round_sha")"
    first_py="$(git -C "$target/repo" show "$first_sha:src/export.py")"
    reviews="$(cat "$target/payloads/reviews.json")"
    comments="$(cat "$target/payloads/comments.json")"

    printf '%s\n' "$follow_up" | grep -qiE 'f[1-9]|closed|regressed|acknowledg|declined|concession|New in this round' && {
        log "    [follow-up export.py still names a finding id or tag stem]"
        return 1
    }
    printf '%s\n' "$follow_up" | grep -q '# TODO:' || {
        log "    [follow-up export.py lost the TODO sanitize line]"
        return 1
    }
    printf '%s\n' "$follow_up" | grep -q 'sanitize' || {
        log "    [follow-up TODO no longer names sanitize]"
        return 1
    }
    printf '%s\n' "$first_py" | grep -q 'sanitize(' || {
        log "    [first-round export.py does not call sanitize()]"
        return 1
    }
    printf '%s\n' "$first_py" | grep -qF 'str(rows[i]) + str(rows[i + 1])' || {
        log "    [first-round export.py lost the no-delimiter join]"
        return 1
    }
    printf '%s\n' "$follow_up" | grep -qF 'str(rows[i]) + str(rows[i + 1])' || {
        log "    [follow-up export.py lost the no-delimiter join]"
        return 1
    }
    printf '%s\n' "$reviews" | grep -qi 'closed in this round' || {
        log "    [prior review body does not record f6 as closed]"
        return 1
    }
    printf '%s\n' "$reviews" | grep -q 'f7' || {
        log "    [prior review body lacks f7]"
        return 1
    }
    printf '%s\n' "$reviews" | grep -qF 'str(rows[i]) + str(rows[i + 1])' || {
        log "    [prior review body does not name the no-delimiter join]"
        return 1
    }
    printf '%s\n' "$comments" | grep -q 'f7:' || {
        log "    [comments.json lacks an author acknowledgment of f7]"
        return 1
    }
    printf '%s\n' "$comments" | grep -qiE 'f3:.*unfixed|Leaving it for now' && {
        log "    [comments.json still acknowledges f3 as unfixed]"
        return 1
    }

    out=$(bash "$grader" 32 "$target/repo" "$complete" 2>&1) && rc=0 || rc=$?
    assert_eq "complete delta response grades clean" "$rc" "0" || ok=false
    assert_contains "complete delta response tags open" "$out" "a finding is tagged open" || ok=false
    assert_contains "complete delta response tags not acknowledged" "$out" \
        "a finding is tagged open and not acknowledged" || ok=false

    local stripped="$target/missing_not_acknowledged.md"
    local only_not_ack="$target/only_not_acknowledged.md"
    python3 - "$complete" "$stripped" "$only_not_ack" <<'PY'
import pathlib, sys
src = pathlib.Path(sys.argv[1]).read_text()
pathlib.Path(sys.argv[2]).write_text(src.replace("not acknowledged", ""))
pathlib.Path(sys.argv[3]).write_text(src.replace("`open`:", "`open and not acknowledged`:"))
PY

    out=$(bash "$grader" 32 "$target/repo" "$stripped" 2>&1) && rc=0 || rc=$?
    assert_eq "missing not-acknowledged text fails grading" "$rc" "1" || ok=false
    assert_contains "missing not-acknowledged text fails that check" "$out" \
        "FAIL  a finding is tagged open and not acknowledged" || ok=false

    out=$(bash "$grader" 32 "$target/repo" "$only_not_ack" 2>&1) && rc=0 || rc=$?
    assert_eq "open-only-as-not-acknowledged fails grading" "$rc" "1" || ok=false
    assert_contains "open-only-as-not-acknowledged fails the plain-open check" "$out" \
        "FAIL  a finding is tagged open" || ok=false

    $ok
}

form_discrimination() {
    local eval_id out rc ok=true
    local grader="$HERE/../evals/grade.sh"
    for eval_id in 1 2; do
        out=$(bash "$grader" --form-only "$eval_id" "$HERE/fixtures/prose_report.md" 2>&1) && rc=0 || rc=$?
        assert_eq "eval $eval_id accepts prose and quoted H3 evidence" "$rc" "0" || ok=false
        assert_contains "eval $eval_id runs every form check" "$out" "6 passed, 0 failed" || ok=false

        out=$(bash "$grader" --form-only "$eval_id" "$HERE/fixtures/field_block_report.md" 2>&1) && rc=0 || rc=$?
        assert_eq "eval $eval_id rejects field-block form" "$rc" "1" || ok=false
        assert_contains "eval $eval_id detects every seeded form violation" "$out" "0 passed, 6 failed" || ok=false
    done
    $ok
}

s23_push_approval_order_proofs() {
    local target="$SCRATCH/s23"
    local grader="$HERE/../evals/grade.sh"
    local response="$target/response.md"
    local evidence="$target/tmp/evidence"
    local out rc ok=true
    local push_line tmpdir_val ev_path

    rm -rf "$target"
    mkdir -p "$target"
    bash "$HERE/../evals/stage.sh" 41 "$target" >/dev/null || return 1

    tmpdir_val="$(grep '^TMPDIR=' "$target/gh_env" | cut -d= -f2-)"
    assert_contains "TMPDIR points into the eval target" "$tmpdir_val" "$target/" || ok=false
    [[ -d "$tmpdir_val" ]] || {
        log "    [TMPDIR directory missing: $tmpdir_val]"
        ok=false
    }

    # A collector run that inherits the fixture gh_env must land its evidence
    # directory under the eval target, not under the host /tmp.
    ev_path="$(
        set -a
        # shellcheck disable=SC1091
        . "$target/gh_env"
        set +a
        cd "$target/repo" || exit 1
        PATH="${GH_STUB_BIN}:${PATH}" \
            "$COLLECT" --base main --head HEAD --pr 7 --no-fetch 2>/dev/null | tail -1
    )"
    assert_contains "collector evidence directory under eval target" "$ev_path" "$target/" || ok=false

    # Pre-push forge noise, then a real push through the insteadOf rewrite so
    # the post-receive hook appends after those lines.
    {
        printf '%s\n' 'pr view 7 --json number,title,statusCheckRollup,mergeable'
        printf '%s\n' 'api repos/acme/widget/rulesets'
    } >> "$target/gh_calls.log"
    git -C "$target/repo" push --quiet origin HEAD 2>/dev/null || {
        log "    [push of the unpushed commit failed]"
        return 1
    }
    push_line="$(grep -E '^push refs/heads/feature/export ' "$target/gh_calls.log" | tail -1)"
    [[ -n "$push_line" ]] || {
        log "    [missing push refs/heads/feature/export <epoch> line]"
        ok=false
    }
    if ! python3 - "$target/gh_calls.log" <<'PY'
import sys
lines = open(sys.argv[1]).read().splitlines()
push_idx = next(
    (i for i, line in enumerate(lines) if line.startswith("push refs/heads/feature/export ")),
    None,
)
if push_idx is None:
    sys.exit(1)
prefix = "\n".join(lines[:push_idx])
if "pr view" not in prefix and "rulesets" not in prefix:
    sys.exit(1)
parts = lines[push_idx].split()
float(parts[-1])
PY
    then
        log "    [push line missing a float epoch or landed before forge calls]"
        ok=false
    fi

    mkdir -p "$evidence"
    cat > "$response" <<'MD'
The push will dismiss peer's approval under the rule that dismisses stale reviews on push.
Closing answer: yes
MD
    cat > "$evidence/report.md" <<'MD'
Warning: pushing dismisses the existing approval because stale reviews are dismissed on push.
MD

    # Happy-path sandbox: push logged, post-push re-reads present, report mtime
    # strictly before the push epoch.
    cat > "$target/gh_calls.log" <<'LOG'
pr view 7 --json number,title,statusCheckRollup,mergeable,mergeStateStatus
api repos/acme/widget/rulesets
push refs/heads/feature/export 1000.5
pr view 7 --json statusCheckRollup
pr view 7 --json mergeable,mergeStateStatus
LOG
    python3 - "$evidence/report.md" <<'PY'
import os, sys
os.utime(sys.argv[1], (999.0, 999.0))
PY

    out=$(bash "$grader" 41 "$target/repo" "$response" 2>&1) && rc=0 || rc=$?
    assert_eq "complete push-order sandbox grades clean" "$rc" "0" || ok=false
    assert_contains "complete sandbox logs the push" "$out" "the push was logged" || ok=false
    assert_contains "complete sandbox re-reads after push" "$out" \
        "the checks and merge state were re-read after the push" || ok=false
    assert_contains "complete sandbox warning order" "$out" \
        "the warning was emitted before the push ran" || ok=false

    # Fail branch: no checks read after the push line.
    cat > "$target/gh_calls.log" <<'LOG'
pr view 7 --json number,title,statusCheckRollup,mergeable,mergeStateStatus
push refs/heads/feature/export 1000.5
pr view 7 --json mergeable,mergeStateStatus
LOG
    python3 - "$evidence/report.md" <<'PY'
import os, sys
os.utime(sys.argv[1], (999.0, 999.0))
PY
    out=$(bash "$grader" 41 "$target/repo" "$response" 2>&1) && rc=0 || rc=$?
    assert_eq "missing post-push checks read fails grading" "$rc" "1" || ok=false
    assert_contains "missing post-push checks read fails that check" "$out" \
        "FAIL  the checks and merge state were re-read after the push" || ok=false

    # Fail branch: no merge-state read after the push line.
    cat > "$target/gh_calls.log" <<'LOG'
pr view 7 --json number,title,statusCheckRollup,mergeable,mergeStateStatus
push refs/heads/feature/export 1000.5
pr view 7 --json statusCheckRollup
LOG
    python3 - "$evidence/report.md" <<'PY'
import os, sys
os.utime(sys.argv[1], (999.0, 999.0))
PY
    out=$(bash "$grader" 41 "$target/repo" "$response" 2>&1) && rc=0 || rc=$?
    assert_eq "missing post-push merge-state read fails grading" "$rc" "1" || ok=false
    assert_contains "missing post-push merge-state read fails that check" "$out" \
        "FAIL  the checks and merge state were re-read after the push" || ok=false

    # Fail branch: report lacks the dismissal warning.
    cat > "$target/gh_calls.log" <<'LOG'
pr view 7 --json number,title,statusCheckRollup,mergeable,mergeStateStatus
push refs/heads/feature/export 1000.5
pr view 7 --json statusCheckRollup
pr view 7 --json mergeable,mergeStateStatus
LOG
    printf 'A plain report with no push warning.\n' > "$evidence/report.md"
    python3 - "$evidence/report.md" <<'PY'
import os, sys
os.utime(sys.argv[1], (999.0, 999.0))
PY
    out=$(bash "$grader" 41 "$target/repo" "$response" 2>&1) && rc=0 || rc=$?
    assert_eq "report without dismissal warning fails grading" "$rc" "1" || ok=false
    assert_contains "report without dismissal warning fails that check" "$out" \
        "FAIL  the warning was emitted before the push ran" || ok=false

    # Fail branch: report mtime is not strictly before the push epoch.
    cat > "$evidence/report.md" <<'MD'
Warning: pushing dismisses the existing approval because stale reviews are dismissed on push.
MD
    python3 - "$evidence/report.md" <<'PY'
import os, sys
os.utime(sys.argv[1], (1000.5, 1000.5))
PY
    out=$(bash "$grader" 41 "$target/repo" "$response" 2>&1) && rc=0 || rc=$?
    assert_eq "report mtime not before push epoch fails grading" "$rc" "1" || ok=false
    assert_contains "report mtime not before push epoch fails that check" "$out" \
        "FAIL  the warning was emitted before the push ran" || ok=false

    $ok
}

# --- run ----------------------------------------------------------------------

scenario s1  "fetch precedes the three-dot diff"                      s1_fetches_before_the_three_dot_diff
scenario s2  "manifest lists the whole evidence set"                  s2_manifest_lists_the_whole_evidence_set
scenario s3  "name-status detects the rename"                         s3_name_status_detects_the_rename
scenario s4  "commit lists cover the no-merges and first-parent walks" s4_commit_lists_cover_both_walks
scenario s5  "removed hunks and base-side versions of deleted files"  s5_removed_hunks_and_base_side_versions
scenario s6  "clean test merge reports no conflict"                   s6_clean_test_merge_reports_no_conflict
scenario s7  "conflicting test merge names the file"                  s7_conflicting_test_merge_names_the_file
scenario s8  "merge base and ahead/behind counts"                     s8_counts_and_merge_base
scenario s9  "secret scan finds a credential and a home path"         s9_secret_scan_finds_both_shapes
scenario s10 "size profile counts binary and generated files"         s10_size_profile_counts_generated_files
scenario s11 "uncommitted mode reports both lanes"                    s11_uncommitted_mode_reports_both_lanes
scenario s12 "collection reads only and leaves the tree alone"        s12_reads_only_and_leaves_the_tree_alone
scenario s13 "an absent forge layer is recorded, not assumed"         s13_forge_layer_absent_is_recorded
scenario s14 "forge layer pages threads and their comments, keeps resolved/outdated" s14_forge_layer_pages_threads_and_counts_them
scenario s15 "flags: help, missing, unknown, and outside a repo"      s15_usage_and_argument_handling
scenario s16 "heading range is inclusive of both named headings"      s16_inclusive_heading_range
scenario s17 "a single heading runs to the end of the file"           s17_range_to_end_of_file
scenario s18 "range errors and the heading listing"                   s18_range_errors_and_listing
scenario s19 "the same heading twice is that section alone"           s19_single_heading_range_is_that_section_alone
scenario s20 "head_sync reports the upstream relationship"            s20_head_sync_reports_the_upstream_relationship
scenario s21 "delta rereview fixture and tag grader fail branches" s21_delta_rereview_tag_grader
scenario s22 "unreadable path records unread remainder and keeps readable diffs" \
    s22_unreadable_path_records_unread_remainder
scenario s23 "push_approval logs the push, scopes TMPDIR, and grades order fail branches" \
    s23_push_approval_order_proofs
scenario s24 "size profile line counts match numstat and keep ---/+++ content lines" \
    s24_size_profile_line_counts_match_numstat
scenario form_discrimination "form checks distinguish prose from field blocks" form_discrimination

# The standing repo rules keep the plugin metadata in lockstep; assert the
# invariant rather than the literal version this change shipped at.
# shellcheck source=../../lib/plugin_version.sh
. "$HERE/../../lib/plugin_version.sh"
check_plugin_version_lockstep ai_dev

log ""
log "================================================================"
log "  $((PASS + FAIL)) scenarios - $PASS pass, $FAIL fail"
if ((FAIL > 0)); then
    log "  failed: ${FAILED_IDS[*]}"
fi
log "================================================================"

if ((FAIL > 0)); then
    exit 1
fi
exit 0
