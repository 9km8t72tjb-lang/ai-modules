---
description: Make a scoped `--uninstall` remove only the logged artefacts of the scope `--global` or `--project-dir DIR` names, deriving each entry's scope from its deployed path.
scope: deployment
created: 2026-10-07T08:53:36
updated: 2026-10-07T08:53:36
status: open
reported-by: Andreas Hoffmann
---

# Limit a scoped `--uninstall` to the scope it names

## Goal

`deployment.sh --uninstall --global` removes only artefacts deployed into the global scope, and `deployment.sh --uninstall --project-dir DIR` removes only artefacts deployed into that project. Entries from every other scope stay deployed and stay in the deploy log. A scopeless `--uninstall`, which `make uninstall` runs, keeps removing matching entries from every scope. This task is the point-fix for uninstall: it adds a helper that derives a logged entry's scope from its deployed path and applies it to uninstall's selection.

## Context

`uninstall_logged_artifacts` in `deployment/deployment.sh` walks every line of the deploy log and selects an entry when `logged_path_matches_active_targets` accepts its target and `logged_type_matches_filter` accepts its type. Neither check looks at where the entry was deployed, so `--global` and `--project-dir` change nothing about which entries are removed. A project uninstall therefore deletes global copies as well, without a backup, because the main flow skips backups whenever `PROJECT_DIR` is set. A global uninstall likewise deletes every project's copies. On 7 October 2026, `--project-dir <empty scratch directory> --target claude --type skill --uninstall --dry-run` listed every logged global Claude skill and every Claude skill entry of a second project for removal, while the named project had no entries at all.

The log records no scope, but each deployed path implies it. A global entry lies under one of the roots `backup_roots` backs up for its target, and a project entry lies under the project-level configuration directory that the `# Target directories` block assigns its target when `--project-dir` is set. For Claude, those are `~/.claude` and `<project>/.claude`. A JSON-merge entry appends its key to the settings file's path as a `[key]` suffix. The run's own target-directory variables follow its scope flag, so under `--project-dir` they point into the project and cannot place a global entry.

The scopeless form is a deliberate maintenance mode, which the explicit-scope check marks with `NO_SCOPE_UNINSTALL`. The `style_run.sh` scenario under the comment `# --- Legacy four-field path[key] still strips ---` relies on it removing an entry whose settings file lies outside every target directory.

[The `make update` task](deployment_update-from-deploy-log.md) groups every log entry by this same derived scope and reuses the helper, which is why the helper serves any logged entry rather than only the entries of the run's own scope.

`tests/deployment/script_tests/run.sh` stages a scratch home through `HOME` and a scratch project, copies the deploy log aside and restores it on exit, and already runs project-scoped uninstalls for OpenCode, Antigravity, and Codex. Each of those runs while the log holds only that project's entries, so their assertions hold after the fix.

## Approach

Add one helper to `deployment/deployment.sh` that returns the scope of any logged entry from its deployed path, after stripping a `[key]` suffix. It returns the global scope when the path lies under one of its target's global roots, the project directory that precedes its target's project-level configuration directory otherwise, and no scope when the path fits neither form or the script no longer knows the target. Compute every target's global roots and project-level directory names whatever scope flag the run carries. Because the helper reads only the path, it works on every line the log already holds, four-field and five-field alike, and the log format stays as it is.

In `uninstall_logged_artifacts`, select only entries whose derived scope is global when `--global` is set, and only entries whose derived scope is that project directory when `--project-dir DIR` is set, comparing against the directory in the form the script already resolves `--project-dir` to. Leave every unselected entry deployed and in the log, the way entries outside the target and type filters stay today. An entry with no derivable scope is unselected under a scope flag, and the run reports it as unrecognized. Without a scope flag, keep today's selection, so a scopeless uninstall still reaches every scope, entries with no derivable scope included.

Rewrite each passage that describes what uninstall selects so it states that a scope flag limits removal to that scope and that a scopeless run covers every scope:

- In `deployment/README.md`, the `--uninstall` row of the **Flags** table and the sentence "`--uninstall` removes only log entries that match the active filters." in the **Deploy Log and Uninstall** section.
- In `deployment/deployment.sh`, the `--uninstall` entry of `print_usage`, which today reads "Uninstall mode; remove matching logged deployed artifacts after backup."

Add the scenarios that **Acceptance** lists to `tests/deployment/script_tests/run.sh`, and name the new coverage in the `script_tests/run.sh` description within the deployment entries of `tests/README.md` and `tests/CLAUDE.md`.

## Acceptance

Each scenario runs in `run.sh` after the same skill type for one target is deployed globally into the scratch home and into two scratch projects.

- `--project-dir <first project> --uninstall` removes the first project's copies and log entries, and leaves the global copies, the second project's copies, and their log entries in place.
- `--global --uninstall` removes the global copies and their log entries, and leaves both projects' copies and log entries in place.
- `--project-dir <first project> --uninstall --dry-run` lists only paths under the first project.
- A scopeless `--uninstall` with the same target and type filters removes the copies and log entries of all three scopes.
- Under `--global --uninstall`, a log entry for that target whose deployed path fits neither form is reported as unrecognized, its path stays in place, and the entry stays in the log.
- The `--uninstall` row of the **Flags** table in `deployment/README.md` and its **Deploy Log and Uninstall** section both state that a scope flag limits uninstall to that scope, and the sentence "`--uninstall` removes only log entries that match the active filters." no longer appears there as written.
- The `--uninstall` entry that `deployment.sh --help` prints states the scope limit.
- The deployment entries in `tests/README.md` and `tests/CLAUDE.md` name scope-limited uninstall in their `script_tests/run.sh` description.
