#!/usr/bin/env bash
# Isolated host-tasks guard for task-family evals.
#
# Stage copies the host tasks tree into the eval's temp directory and records
# the sandbox's task basenames. Grade compares the live tree to that copy only
# for those names. A parallel session that creates, edits, or archives some
# other real task leaves the check green. A sandbox escape that writes one of
# the fixture names into the live tree still fails.

# snapshot_isolated_host_tasks <target> <repo_root>
snapshot_isolated_host_tasks() {
  local target="$1" repo="$2"
  local dest="$target/.isolated_host_tasks"
  rm -rf "$dest"
  mkdir -p "$dest"
  if [[ -d "$repo/tasks" ]]; then
    cp -a "$repo/tasks/." "$dest/"
  fi
}

# record_sandbox_task_names <target> <sandbox_tasks_dir>
record_sandbox_task_names() {
  local target="$1" sandbox_tasks="$2"
  if [[ -d "$sandbox_tasks" ]]; then
    find "$sandbox_tasks" -type f -name '*.md' -exec basename {} \; \
      | sort -u > "$target/.sandbox_task_names"
  else
    : > "$target/.sandbox_task_names"
  fi
}

# Names staged before the worker, plus names the sandbox holds at grade time.
_guard_names() {
  local target="$1" sandbox_tasks="$2"
  {
    if [[ -f "$target/.sandbox_task_names" ]]; then
      cat "$target/.sandbox_task_names"
    fi
    if [[ -d "$sandbox_tasks" ]]; then
      find "$sandbox_tasks" -type f -name '*.md' -exec basename {} \;
    fi
  } | sort -u
}

# Relative paths of files named $2 under a tasks root, one per line.
_rel_paths_named() {
  local root="$1" base="$2"
  [[ -d "$root" ]] || return 0
  (
    cd "$root" && find . -type f -name "$base" | sed 's|^\./||' | sort
  )
}

# host_fixture_writes_clean <target> <repo_root> <sandbox_tasks> <marker>
# A fixture-named file under the live tasks tree that is newer than the
# marker, or present when the isolated copy has no such path, fails.
host_fixture_writes_clean() {
  local target="$1" repo="$2" sandbox_tasks="$3" marker="$4"
  local dest="$target/.isolated_host_tasks"
  local base rel live iso
  while IFS= read -r base; do
    [[ -n "$base" ]] || continue
    live="$(_rel_paths_named "$repo/tasks" "$base")"
    if [[ -d "$dest" ]]; then
      iso="$(_rel_paths_named "$dest" "$base")"
      [[ "$live" == "$iso" ]] || return 1
    fi
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      if [[ -n "$marker" && -f "$marker" && "$repo/tasks/$rel" -nt "$marker" ]]; then
        return 1
      fi
    done <<<"$live"
  done < <(_guard_names "$target" "$sandbox_tasks")
  return 0
}

# host_fixture_copy_clean <target> <repo_root> <sandbox_tasks>
# Fixture-named paths and bytes in the live tree still match the isolated
# copy. Paths outside that name set are not part of the comparison.
host_fixture_copy_clean() {
  local target="$1" repo="$2" sandbox_tasks="$3"
  local dest="$target/.isolated_host_tasks"
  local base rel live iso
  [[ -d "$dest" ]] || return 0
  while IFS= read -r base; do
    [[ -n "$base" ]] || continue
    live="$(_rel_paths_named "$repo/tasks" "$base")"
    iso="$(_rel_paths_named "$dest" "$base")"
    [[ "$live" == "$iso" ]] || return 1
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      cmp -s "$repo/tasks/$rel" "$dest/$rel" || return 1
    done <<<"$live"
  done < <(_guard_names "$target" "$sandbox_tasks")
  return 0
}
