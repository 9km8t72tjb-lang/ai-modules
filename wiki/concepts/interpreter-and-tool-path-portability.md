---
title: Interpreter and tool-path portability
created: 2026-10-03
updated: 2026-10-03
checked: 2026-10-03
type: concept
tags: [portability, skill, authoring]
confidence: high
---

# Interpreter and tool-path portability

## Definition

Interpreter and tool-path portability is the gap between the shell and tools a
developer sees in a login terminal and the ones a bundled script actually gets
when an agent harness runs it. The stock macOS bash, the licence reason it stays
there, the login-shell `PATH` mechanism that hides a newer interpreter from
non-login shells, and the constructs that fail on that stock build together
define the floor a portable bundled script must meet.

The shipped `harness_portability` skill carries the operative floor and the
construct-to-substitute list. This page holds the dated verification those rules
rest on. [Deciding where knowledge belongs](../procedures/deciding-where-knowledge-belongs.md)
is the routing rule that puts the evidence here and the rules in the skill.

## Current state of knowledge

### Stock interpreter and why it stays

macOS ships bash 3.2.57 as `/bin/bash`. A `#!/usr/bin/env bash` shebang resolves
to that build whenever no newer bash precedes it on `PATH`. The vendor has not
moved off 3.2 because later bash releases carry a licence it does not ship.
Verified on 3 October 2026 against `/bin/bash --version` on a current macOS
build reporting `GNU bash, version 3.2.57(1)-release`.

### Login-shell PATH trap

A newer bash on macOS normally arrives through a package manager whose `PATH`
entry is contributed by a login-shell profile. A non-login shell never reads that
profile, so it resolves `bash` to the stock interpreter. Agent harnesses commonly
spawn exactly such shells for the commands they run. An interpreter assumption
that holds in a developer's login terminal therefore fails in every harness-driven
run of the same command. The same mechanism applies to any tool reached only
through a package-manager `PATH` entry.

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
- The bash licence and vendor-shipping constraint as stated in the macOS stock
  interpreter situation the deployment rewrite already relied on.
