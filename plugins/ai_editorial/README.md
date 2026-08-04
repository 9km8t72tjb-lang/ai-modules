# ai_editorial

A plugin for editorial craft on prose written for people to read: reports, proposals, status updates, documentation, and the everyday workplace writing that has to land with its audience. It stands beside the development and knowledge-management plugins as a peer, distinguished by its subject matter rather than by who consumes it — every skill in this collection is invoked by a person and read by a model, and what changes here is the kind of text being worked on. Text an AI reads at inference time — prompts, rule files, skill and agent definitions — is authored under the `ai_instruction_writing` and `ai_instruction_formatting` skills, which stay the authorities for that surface, including for the prose inside this plugin's own skill files.

## Skills

`language_humanizer` is the first skill to land; the other two arrive in their own changes:

- **language_humanizer**: review, rewrite, or write a document so its intended reader understands it on the first read. It runs three ordered passes — an inventory of every load-bearing element of the input, the moves that produce first-read comprehension, and a verification of the delivered text against that inventory — so a rewrite comes in no longer than the draft it replaces while each condition, requirement strength, number, actor, and causal joint carries through intact.
- **slop_catch** *(in development)*: flag the tells that mark a draft as AI-generated — the lexical giveaways alongside the structural patterns — and return concrete feedback on what to change.
- **ghost_writer** *(in development)*: rules for writing and, above all, editing strong prose, with one ruleset per genre — scientific writing, essays, blog posts, social media, and case studies.
