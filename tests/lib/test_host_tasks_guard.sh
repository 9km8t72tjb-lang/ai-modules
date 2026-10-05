#!/usr/bin/env bash
# Proves the host-tasks guard ignores a parallel edit of some other live task
# and fails when a sandbox fixture name lands in that tree.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=host_tasks_guard.sh
. "$HERE/host_tasks_guard.sh"

pass=0
fail=0
check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass=$((pass + 1))
    printf '  PASS  %s\n' "$label"
  else
    fail=$((fail + 1))
    printf '  FAIL  %s\n' "$label"
  fi
}

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/host-guard.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

mkdir -p "$ROOT/repo/tasks" "$ROOT/target/proj/tasks" "$ROOT/target/proj/tasks/archive"
printf 'live other\n' > "$ROOT/repo/tasks/other_real-task.md"
printf 'fixture seed\n' > "$ROOT/target/proj/tasks/api_rate-limit.md"

snapshot_isolated_host_tasks "$ROOT/target" "$ROOT/repo"
record_sandbox_task_names "$ROOT/target" "$ROOT/target/proj/tasks"
date +%s > "$ROOT/target/.eval_started_at"
# The marker must predate the parallel edit below.
sleep 1

# Parallel backlog work: a new live task, and an in-place edit of another.
printf 'edited by a parallel session\n' > "$ROOT/repo/tasks/other_real-task.md"
printf 'brand new live task\n' > "$ROOT/repo/tasks/tests_parallel-session.md"
mkdir -p "$ROOT/repo/tasks/archive"
mv "$ROOT/repo/tasks/tests_parallel-session.md" "$ROOT/repo/tasks/archive/tests_parallel-session.md"

check "unrelated live create, edit, and archive stay green" \
  host_fixture_writes_clean "$ROOT/target" "$ROOT/repo" "$ROOT/target/proj/tasks" "$ROOT/target/.eval_started_at"
check "unrelated live path change stays off the copy comparison" \
  host_fixture_copy_clean "$ROOT/target" "$ROOT/repo" "$ROOT/target/proj/tasks"

# Escape: the sandbox's fixture name appears in the live tree.
printf 'escaped\n' > "$ROOT/repo/tasks/api_rate-limit.md"
writes_fail() {
  ! host_fixture_writes_clean "$ROOT/target" "$ROOT/repo" "$ROOT/target/proj/tasks" "$ROOT/target/.eval_started_at"
}
copy_fail() {
  ! host_fixture_copy_clean "$ROOT/target" "$ROOT/repo" "$ROOT/target/proj/tasks"
}
check "a fixture name landing in the live tree fails the write check" writes_fail
check "a fixture name landing in the live tree fails the copy check" copy_fail

printf 'host_tasks_guard: %s pass, %s fail\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
