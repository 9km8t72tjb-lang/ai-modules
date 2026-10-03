---
description: Turn make install into environment preparation: declare the runtime and development tool floor in one file, report and install what is missing or too old, and free the name from the deploy alias.
scope: "repo toolchain"
created: 2026-09-18T13:48:56
updated: 2026-10-03T14:55:53
status: open
reported-by: Andreas Hoffmann
---

# Make `make install` prepare the environment against a declared tool floor

## Goal

Nothing in this repository states which tools it needs, and nothing checks for them. `make install` is currently an alias for `make deploy`, so the name that conventionally means "prepare the environment" is taken by the deploy. A contributor on a fresh machine discovers each missing tool one failing target at a time, and each failure reports only that a command was not found.

After this task the repository declares its tool floor in one place and `make install` acts on it. The target reports every tool it checked with its status, treats a tool present below its declared minimum version the same as an absent one, installs the missing ones it knows how to install, prints each install command before running it, and names anything it cannot install along with the exact command the operator should run. It exits non-zero while a required tool is still missing, so a caller can rely on its status. The deploy keeps its own entry points, `make deploy` and `make global`, and the standing repo documentation stops presenting `install` as a third name for the deploy.

The floor is declared in two parts, because the two have different audiences. The **runtime floor** is what `deployment/deployment.sh` needs when it runs on any machine it is deployed from. The **development floor** is what the repository's own lint and test targets need. Splitting them lets the target report a machine as able to deploy while still missing test tooling, which is the common state on a machine that only consumes the artefacts.

The outcome to judge the target by is the fresh start: a clone of this repository on a machine that has never run it reaches a working state by running `make install` once, and the operator learns from that single run everything still standing between them and a working tree. That is what the declaration and the check exist to deliver, and it is the state the Acceptance checks first.

## Context

The runtime floor is about to become interesting rather than incidental. Once the deploy script runs under the stock interpreter, delivered by the sibling task [bash 3.2 floor](archive/deployment_bash-32-floor.md), every tool it needs at run time resolves to a binary the operating system already ships: the interpreter itself, plus `jq`, `perl`, and the standard file and text utilities. That makes the runtime floor satisfiable with no installation at all on a stock machine, which is a property worth asserting and keeping rather than leaving as an accident. This task's runtime check is what turns it into a checked property, and it depends on that sibling landing first to be true.

The development floor is not stock. `make lint` needs `markdownlint` and `shellcheck`, neither of which ships with the operating system, alongside `jq`, which does. The test harnesses additionally reach for `python3`, `node`, and the agent CLI used to drive the skill evals. The repository's README states in prose that the lint targets use these tools and suggests a package manager on macOS, which is guidance a reader follows by hand rather than a declaration a target can act on.

The name collision is recorded in three places that move together. The Makefile defines `install: deploy` as an alias, and both standing repo instruction files carry the same sentence presenting `global` and `install` as aliases of `make deploy`. The README's target listing repeats it in the comment beside `make deploy`. Those four passages are the edit sites for freeing the name; the standing instruction files are named here because they are themselves the implementation target.

A sibling repository solves the same problem with a declarative tool manifest read by a version manager, driven by an `install` target whose help text reads `prepare environment and install dependencies`. That precedent sets the target's name and meaning for this task. It does not set the mechanism: this repository's standing rules hold the toolchain to Make, shell, and Markdown, with jq, git, and Python 3 as the accepted standing dependencies, and add a package manager only on an explicit request. The declaration therefore lands in a form plain shell can read, which leaves a version manager available later as a backend over the same declaration rather than as a new prerequisite now.

## Approach

Declare the floor once, as a plain-text manifest the Makefile and the check both read, with one record per tool carrying its name, the command that proves it present, which floor it belongs to, whether it is required or optional, the minimum version it must satisfy where one applies, and the command that installs it on macOS and on Linux. Leave the minimum empty for a tool whose version has never mattered, so the field states a real requirement wherever it carries a value. Keep the manifest readable by `while IFS= read -r` in plain shell so no parser and no new dependency enters the repository.

Repoint `install` at a new environment-preparation recipe and keep `global` as the deploy alias. Rewrite the alias sentence in both standing repo instruction files in place so each names `global` alone, rewrite the README's target listing the same way, and rewrite the README prose that today suggests installing the lint tools by hand so it points at the target instead. Rewrite the Makefile's own header comment block, which lists the targets, to match.

Implement the check as a shell recipe that walks the manifest, resolves each tool, and prints a per-tool line carrying the tool, its floor, and its status. For a missing tool with a known install command, print the command and run it, then re-resolve the tool and report whether the install succeeded. For a missing tool with no install command for the current platform, print what the operator should do. Exit non-zero while any required tool is still missing after the pass, and exit zero when only optional tools are absent.

Check the declared minimum in the same pass, for every tool whose record carries one. Read the installed version through the tool's own `--version` output and take the first dotted number from it, which resolves correctly for every tool the manifest declares today. Compare it against the minimum with `sort -V`, which the stock `sort` provides on both target platforms. Report a tool present below its minimum as its own status, distinct from absent and from satisfied, carrying the version found and the version required, and offer the same install command that an absent tool would get.

Detect the platform from `uname` and select the matching install command from the manifest record, treating an unknown platform as the no-install-command case rather than guessing. Where the install command names a package manager that is itself absent, report that manager as the thing to install first rather than invoking a command that does not exist.

Keep the runtime and development floors separately reportable so an operator can see that a machine can deploy without being able to lint, and give the target a way to check one floor rather than both.

**Out of scope:**

- Adopting a version manager or a package-manager manifest format as a new repository prerequisite. The standing repo rules admit a further package manager only on an explicit request, and the plain-text declaration leaves that adoption available later over the same records.
- Pinning an exact tool version. Neither lint tool offers a versioned package on the platforms this repository installs from, so an exact pin would need a separate fetch path or the version manager this task already rejects. The declared minimum catches the failure that reaches a fresh machine, which is a tool too old to carry the checks the repository relies on.
- Committing a linter configuration file to stabilise the enabled check set. A shellcheck configuration governs the optional checks, which are off by default, so it addresses how strict the lint is rather than how much it varies between versions, and that is a separate decision.
- Installing the agent CLI the skill evals drive. It is declared as an optional development tool and reported when absent, and its installation path is the vendor's own.
- Continuous integration that runs the target. This repository has no workflow directory, and adding one is separate work.

## Acceptance

- A clone of this repository placed in a scratch directory, run with a shell environment where the non-stock development tools do not resolve, reaches a state where `make lint` succeeds after a single `make install`, and the run named every tool it installed to get there.
- That same clone, before `make install` runs, reports its runtime floor as already satisfied without installing anything, confirming the deploy path needs nothing beyond what the operating system ships.
- A tool whose manifest record declares a minimum version, resolved at a lower version, is reported under a status distinct from both absent and satisfied, naming the version found and the version required, and `make install` exits non-zero while it stays below the minimum.
- The version read for each tool the manifest declares matches that tool's own reported version, confirming the extraction works across their differing `--version` output formats.
- A tool manifest exists in the repository declaring each tool with its detection command, its floor, its required or optional status, and its per-platform install command, and the Makefile recipe reads the tool list from that file rather than restating it.
- `make install` on a machine with every declared tool present prints one status line per tool, reports both floors as satisfied, installs nothing, and exits 0.
- `make install` run with a required development tool made unresolvable prints that tool as missing, prints the install command before running it, and exits non-zero if the tool is still unresolvable afterwards.
- `make install` run with a tool whose manifest record carries no install command for the current platform names the tool and what the operator should do, without invoking an install.
- `make install` reports the runtime floor as satisfied on a machine where only development tools are missing, and the two floors appear as separately labelled groups in its output.
- `make install` no longer runs the deploy, and `make deploy` and `make global` both still deploy.
- `make help` lists `install` with its environment-preparation description.
- Neither standing repo instruction file presents `install` as an alias of `make deploy`, the README's target listing names only `global` as the deploy alias, and the Makefile header comment matches.
- The README passage that today tells the reader to install the lint tools by hand points at `make install` instead, and no remaining README passage instructs a manual install of a tool the manifest declares.
