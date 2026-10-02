# Wiki Index

> Content catalog. Every wiki page listed under its type with a one-line summary.
> Read this first to find relevant pages for any query.
> Last updated: 2026-10-02 | Total pages: 32

## Entities

<!-- Alphabetical within section -->

- [Anthropic Claude Code](entities/anthropic-claude-code.md): configuration roots and the setting sources a headless worker reads, the hardcoded CLAUDE.md / AGENTS.md standing-instruction pair and its walk past the repository root, agent frontmatter tolerance, the file-edit read state, hooks, safe mode, and the retired `claude config` subcommand.
- [Cursor](entities/cursor.md): rules as the whole instruction mechanism, agent fields, and the undocumented home-directory rules folder.
- [GitHub Copilot in VS Code](entities/github-copilot-vs-code.md): one user root shared with the CLI, instruction roots, the preview hook contract, deep adoption of the Claude tree, custom agents, and preview plugins.
- [Google Antigravity](entities/google-antigravity.md): the `.agents/` workspace tree, skills and subagents, the hook contract and its SDK second surface, rules and workflows, and four open verification gaps.
- [OpenAI Codex](entities/openai-codex.md): configuration layers, the CLI binary shipped off `PATH`, TOML agent roles, the single instructions slot, personalities, profiles, and hook trust.
- [SST OpenCode](entities/sst-opencode.md): its own config tree, foreign-directory discovery, pass-through frontmatter, prompt assembly, and code-only hooks.

## Concepts

- [Agent definition portability](concepts/agent-definition-portability.md): three tolerance categories, disjoint tool vocabularies, read-only levers, and when a generated variant is required.
- [Agent-delegated automation](concepts/agent-delegated-automation.md): how a thin front-end skill delegates a whole-artifact audit-and-repair job to spawned agents, with read fan-out for coverage, one serialized writer for integrity, refute-by-default verification, frozen intent, judgement calls routed to the human, and where the general, harness-independent form of the rule now ships as a skill.
- [Antigravity global configuration roots](concepts/antigravity-global-roots.md): the two artefact classes that split across its three products, what that costs a global deploy, and the output tree that is not a root.
- [Antigravity tool vocabulary](concepts/antigravity-tool-vocabulary.md): the two incomplete name lists, the missing canonical registry, and why a wrong name hangs instead of failing.
- [Claude output style selection](concepts/claude-output-style-selection.md): the `outputStyle` key and its precedence, a headless worker honouring a project selection, the interactive routes that all write local scope, next-message switching, the retired and restored command, and the desktop route.
- [Claude output styles](concepts/claude-output-styles.md): the two-layer system prompt and the append flag beside it, the two delivery modes, file locations, plugin bundling, and the four-key frontmatter the loader checks without enforcing.
- [Foreign directory adoption](concepts/foreign-directory-adoption.md): which harnesses read another's config tree, why that is contamination rather than delivery, and the isolation switches.
- [Guardrail documents as normative rules](concepts/guardrail-documents-as-rules.md): presence-gated lookup, optional adoption, the description misreading, the three paths to true, and the guarding/describing split.
- [Hook delivery design](concepts/hook-delivery-design.md): the shared-script layout, the uneven per-target deploy routing, the foreign hook files Copilot parses, and the decision to deliver Copilot natively.
- [Hook surface portability](concepts/hook-surface-portability.md): four configuration schemas plus one that is code, four signalling contracts, additive layers, and guarantees that vary with the interception point.
- [Instruction-defect classes](concepts/instruction-defect-classes.md): three ways an AI-consumed instruction passes review and fails at runtime (reach, disposition, intra-file contradiction), why review misses each, why measurement found them, and the measured limit where instruction repair ends and a mechanism must carry the property.
- [Output style delivery design](concepts/output-style-delivery-design.md): the decision record behind the `styles/` source, the per-target delivery matrix, the marked-block write, and the scope rejections.
- [Plugin packaging and versioning](concepts/plugin-packaging-and-versioning.md): why two manifests, the lockstep version contract, where a missed bump surfaces, and the two distribution options.
- [Skill family architecture](concepts/skill-family-architecture.md): naming by invocation mode, rules living once in the base skill, bundled scripts, the cost of a large skill body, and the checker that reads those rules rather than restating them and takes its severity lines from the harness.
- [Skill load paths](concepts/skill-load-paths.md): what makes a skill load and route on Claude Code and Codex, read out of installed builds, and which repository rules are convention rather than harness constraint.
- [The deployment model](concepts/deployment-model.md): two discovery roots, per-tool configuration, generated variants, scope precedence, and the prior-value restore on uninstall.
- [Verification surfaces for a shipped skill](concepts/verification-surfaces.md): script tests against behavioral evals, harnesses committed but never deployed, the pinned model under test, a worker isolated from the host's instructions and style, trigger coverage as its own question, and why a grader that tests surface form or hides a conjunction misreports the behaviour.

## Comparisons

- [System prompt substitution across harnesses](comparisons/system-prompt-substitution-across-harnesses.md): the native, synthesizable, and append-only tiers, what each global deploy must write, and the price of synthesis.

## Queries

- [What remains unverified about Google Antigravity?](queries/antigravity-open-verification-gaps.md): the four open gaps, the evidence behind each, and which one gates a design decision.

## Summaries

- [System prompt substitution experiments](summaries/system-prompt-substitution-experiments.md): an unrun programme testing this repository's authoring rules against vendor base prompts.
- [The ai-modules repository](summaries/ai-modules-repository.md): what the repository is, what it ships, its toolchain and conventions, and where this wiki sits beside its other document sets.

## Procedures

- [Deciding where knowledge belongs](procedures/deciding-where-knowledge-belongs.md): the three genres, their three homes, and the travels-or-not test that routes between them.
- [Isolating Cursor from foreign harness config](procedures/isolating-cursor-from-foreign-config.md): the one settings toggle, how to confirm it in the state database, and what it takes away with the skills.
- [Isolating OpenCode from foreign harness config](procedures/isolating-opencode-from-foreign-config.md): picking the narrowest variable, and the three placements that reach a GUI application when a shell profile cannot.
- [Isolating VS Code from foreign harness config](procedures/isolating-vs-code-from-foreign-config.md): per-path location maps, the agent switch, and the separate lever for the aggregated session list.
- [Splitting a shipped skill](procedures/splitting-a-shipped-skill.md): move the reference material out, audit the split in three directions, and repair the inbound references.
