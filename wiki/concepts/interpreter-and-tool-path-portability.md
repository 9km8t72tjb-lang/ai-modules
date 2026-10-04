---
title: Interpreter and tool-path portability
created: 2026-10-03
updated: 2026-10-04
checked: 2026-10-03
type: concept
tags: [portability, skill, authoring]
sources: [raw/notes/agent-delegation-host-observations-2026-09.md]
confidence: high
---

# Interpreter and tool-path portability

## Definition

Interpreter and tool-path portability is the gap between the shell and tools a
developer sees in a login terminal and the ones a bundled script actually gets
when an agent harness runs it. Together, these set the floor, the baseline a
portable bundled script must meet: the stock macOS bash and python3, the licence
reason bash stays at 3.2, the login-shell `PATH` mechanism that hides a newer
build from non-login shells, and the constructs that fail on the stock bash. A
bundled script runs under the interpreter its shebang line names. Two zsh
constructs therefore form a separate case: they misfire in command lines that an
agent runs directly in its shell tool.

The shipped `harness_portability` skill carries the bash floor, the rule for
`PATH` in non-login shells, and the list that pairs each failing construct with
a substitute. It has no rule yet on the stock python3's version or on the zsh
constructs. The backlog carries the work to record those observations in the
skill's references. This page holds the dated evidence for both the rules and
the observations.
[Deciding where knowledge belongs](../procedures/deciding-where-knowledge-belongs.md)
is the routing rule that puts the evidence here and the rules in the skill.

## Current state of knowledge

### Stock interpreter and why it stays

macOS ships bash 3.2.57 as `/bin/bash`. A `#!/usr/bin/env bash` shebang resolves
to that build whenever no newer bash precedes it on `PATH`. The vendor has not
moved off 3.2 because later bash releases carry a licence it does not ship.
Verified on 3 October 2026 against `/bin/bash --version` on a current macOS
build reporting `GNU bash, version 3.2.57(1)-release`.

On a macOS workstation on 27 September 2026, the stock python3 reported version
3.9.6, and it has no `jsonschema` module. A bundled Python helper that must run
under it therefore keeps to the standard library. Neither `timeout` nor
`gtimeout` was found on that workstation, while BSD `xargs -P` ran
([host observations](../raw/notes/agent-delegation-host-observations-2026-09.md)).

### Login-shell PATH trap

A newer bash on macOS normally arrives through a package manager whose `PATH`
entry is contributed by a login-shell profile. A non-login shell never reads that
profile, so it resolves `bash` to the stock interpreter. Agent harnesses commonly
spawn exactly such shells for the commands they run. An interpreter assumption
that holds in a developer's login terminal therefore fails in every harness-driven
run of the same command. The same mechanism applies to any tool reached only
through a package-manager `PATH` entry.

Observed on 27 September 2026: a non-login `zsh -i` started from a bare
environment found neither markdownlint nor shellcheck. It found the stock system
builds of jq, python3, and bash, while a login `zsh -l` found the
package-manager builds
([host observations](../raw/notes/agent-delegation-host-observations-2026-09.md)).
Each harness's own page records whether its shells run non-login, as the
[Cursor](../entities/cursor.md) page does.

### Constructs above the floor

Sixteen constructs fail on the stock interpreter. Each was verified by executing
it under `/bin/bash` 3.2.57 on 3 October 2026. Four fail at parse time and are
caught by `bash -n` without executing: `&>>`, `;;&`, `coproc`, and
`[[ -v var ]]`. The rest fail only when the line runs:

| Construct | Diagnostic under bash 3.2.57 |
| --- | --- |
| `${var^^}`, `${var,,}` | bad substitution |
| `mapfile`, `readarray` | command not found |
| `declare -n`, `wait -n`, `read -N` | invalid option |
| `shopt -s globstar` | invalid option name |
| `${var@Q}` | bad substitution |
| negative array index | bad array subscript |
| `EPOCHSECONDS` | unbound variable |
| `printf '%(fmt)T'` | invalid format character |

Associative arrays fail in two ways. A bare `declare -A m` reports
`declare: -A: invalid option`. A populated `declare -A m=([k]=v)` is read as an
arithmetic subscript, so under `set -u` it aborts with an unbound-variable error
naming the key, and without `set -u` it silently degrades to an indexed array.

The portable substitutes for each construct live in the `harness_portability`
skill's shell-features policy rule, where a reviewer applies them at authoring
time. [Skill family architecture](skill-family-architecture.md) explains why
that operative content travels with the skill rather than only with this wiki.

### Two zsh constructs that misfire

The agent shells observed on macOS run zsh, where two constructs misfire without
an error. The first is an ANSI-C quoted alternation for grep, such as
`$'a\|b'`. Under zsh it loses its backslash, so grep cannot match it. In one
orchestrated sweep on 5 September 2026, that form produced false zero counts.
The second is `${PIPESTATUS[0]}`, which expands to nothing under zsh
(15 September 2026,
[host observations](../raw/notes/agent-delegation-host-observations-2026-09.md)).
Verified on 4 October 2026: under `/bin/bash` 3.2.57 the alternation keeps its
backslash and grep matches, and `${PIPESTATUS[0]}` holds the first command's
status. Under zsh 5.9 the backslash drops and `${PIPESTATUS[0]}` stays empty.

## Open questions

None for the stock-interpreter floor itself. Whether every target harness's
spawned shell is non-login by default remains a per-harness observation rather
than a settled universal claim; the PATH trap still holds wherever a
package-manager entry depends on a login profile.

## Related concepts

- [Verification surfaces for a shipped skill](verification-surfaces.md), for how
  a floor is proven in the repository's test harnesses.
- [The deployment model](deployment-model.md), for the deploy script that first
  hit this floor in practice.
- [Deciding where knowledge belongs](../procedures/deciding-where-knowledge-belongs.md),
  for the skill-versus-wiki split this page instantiates.

## Derived from

- Direct execution under `/bin/bash` 3.2.57 on macOS (arm64-apple-darwin25),
  3 October 2026: version probe plus one invocation per construct above.
- Direct execution of the ANSI-C quoted alternation and `${PIPESTATUS[0]}` under
  `/bin/bash` 3.2.57 and zsh 5.9 on macOS, 4 October 2026.
- The bash licence and vendor-shipping constraint as stated in the macOS stock
  interpreter situation the deployment rewrite already relied on.
