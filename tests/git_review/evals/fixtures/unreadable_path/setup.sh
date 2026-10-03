#!/usr/bin/env bash
# One changed path's new blob is unreachable through git and absent from the
# worktree, so the run has to name the unread remainder rather than call the
# change approvable.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$HERE/../_common.sh"

target="${1:?target directory required}"
repo="$(init_remote_repo "$target" main)"

cd "$repo"
mkdir -p src
printf 'readable = 1\n' > src/readable.py
printf 'locked = 1\n' > src/locked.py
git add -A
git commit --quiet -m "seed sources"
git push --quiet origin main

git checkout --quiet -b widen
printf 'readable = 2\n' > src/readable.py
printf 'locked = 2\nsecret_flag = True\n' > src/locked.py
git add -A
git commit --quiet -m "src -> widen both modules"
git push --quiet -u origin widen

# Resolve the locked blob from origin only. Asking the clone would fetch it
# through the promisor remote and put the content back in reach.
locked_oid="$(git --git-dir="$target/origin.git" rev-parse "widen:src/locked.py")"

# Delete one object from a git directory in loose and packed form so neither
# store can serve it.
purge_object() {
    local gitdir=$1 oid=$2
    local loose="$gitdir/objects/${oid:0:2}/${oid:2}"
    local packdir="$gitdir/objects/pack"
    local idx pack

    rm -f "$loose"
    [[ -d "$packdir" ]] || return 0

    shopt -s nullglob
    for idx in "$packdir"/*.idx; do
        if git --git-dir="$gitdir" verify-pack -v "$idx" 2>/dev/null |
            grep -q "^${oid} "; then
            break
        fi
        idx=""
    done
    shopt -u nullglob

    # No pack carries the object once the loose copy is gone.
    [[ -n "${idx:-}" ]] || return 0

    shopt -s nullglob
    for pack in "$packdir"/*.pack; do
        git --git-dir="$gitdir" unpack-objects -q < "$pack" >/dev/null 2>&1 || true
    done
    rm -f "$packdir"/*.pack "$packdir"/*.idx "$packdir"/*.rev "$packdir"/*.promisor
    shopt -u nullglob
    rm -f "$loose"
}

git -C "$target/origin.git" config uploadpack.allowFilter true
cd "$target"
rm -rf "$target/repo"
git clone --filter=blob:none --no-checkout "file://$target/origin.git" "$target/repo"
cd "$target/repo"
setup_identity

# Materialize every path except the locked one so its blob stays unfetched.
git sparse-checkout init --no-cone
git sparse-checkout set '/*' '!/src/locked.py'
git checkout --quiet widen
git branch --quiet --set-upstream-to=origin/widen widen

# Pull the readable blob into the local store without touching the locked path.
git show "HEAD:src/readable.py" >/dev/null

# Purge origin first so a promisor fetch cannot rehydrate the blob, then purge
# the clone (a no-op when sparse-checkout never requested it).
purge_object "$target/origin.git" "$locked_oid"
purge_object "$target/repo/.git" "$locked_oid"

# Confirm the combined hide before any grader or collector relies on it.
git show "HEAD:src/locked.py" >/dev/null 2>&1 && {
    printf 'unreadable_path: git show HEAD:src/locked.py still succeeds\n' >&2
    exit 1
}
git diff "main...HEAD" -- src/locked.py >/dev/null 2>&1 && {
    printf 'unreadable_path: git diff of src/locked.py still succeeds\n' >&2
    exit 1
}
git show "HEAD:src/readable.py" >/dev/null 2>&1 || {
    printf 'unreadable_path: git show HEAD:src/readable.py failed\n' >&2
    exit 1
}
git fetch --all >/dev/null 2>&1 || {
    printf 'unreadable_path: git fetch --all failed\n' >&2
    exit 1
}
test ! -e src/locked.py || {
    printf 'unreadable_path: src/locked.py is present in the worktree\n' >&2
    exit 1
}

printf '%s\n' "$target/repo"
