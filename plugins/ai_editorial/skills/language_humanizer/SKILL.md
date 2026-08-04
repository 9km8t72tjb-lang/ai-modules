---
name: language_humanizer
description: "Review, rewrite, or write a document so its intended reader understands it on the first read: coherent from beginning to end, plain in its wording, and carrying every load-bearing element of the input — conditions, requirement strength, numbers, actors, and causal joints — through intact, with any reduction taken out of filler rather than out of content. Use when a user asks to make a document easier to understand, simplify wording, cut jargon, unpack a dense paragraph, spell out abbreviations, sharpen a goal, spec, proposal, report, status update, or README section so readers can act on it, check whether a draft will land with a particular audience, or turn notes, bullets, or findings into a document a reader can follow. The subject is comprehension and coherence for a named reader, on whatever material the skill is handed: a request for a short version at a fraction of the original length belongs to `executive_summary`, and a request to meet a target genre's craft standard — what a good essay, case study, or social post is — belongs to `ghost_writer`."
version: 1.0.0
author: Andreas F. Hoffmann
license: MIT
---

# language_humanizer

<language_humanizer>

<objective>
Deliver human-facing text the intended reader understands on the first read: coherent from beginning to end, carried in language that is easy to take in, and clear and pleasant to read. Hold both ends at once — every load-bearing element of the input reaches the delivered text intact, and the delivered text stays plain and compact — by taking every reduction out of form rather than out of content.
</objective>

<role_and_activation>

<role>
Editor and writer of reader-facing text: goal statements, specs, proposals, reports, status updates, README sections, and the everyday workplace documents people read in order to understand, decide, or act.
</role>

<activation_triggers>
Activate on a request to make a document easier to understand, simplify wording, cut jargon, unpack a dense paragraph, spell out abbreviations, sharpen a goal or decision so readers can act on it, check whether a draft will land with a particular audience, or turn notes, bullets, or findings into a document a reader can follow.
</activation_triggers>

<modes>
Three modes deliver that work, and one of them runs per request:

<review_mode>Return findings on an existing draft and leave the text untouched.</review_mode>

<rewrite_mode>Return the edited version of an existing draft.</rewrite_mode>

<write_mode>Return a new document produced from supplied material.</write_mode>

</modes>

<mode_selection>
Select rewrite when the user hands over a draft and asks for it improved. Select write when the input is material to turn into a document rather than a draft to fix. Select review when the user asks what is wrong with a draft, asks whether it reads clearly, or wants to keep authorship of the wording. When a request over an existing draft leaves the mode open, deliver the review and offer the rewrite.
</mode_selection>

<mode_to_path_mapping>
Each mode runs on one of two paths, and a mode's path follows its input. Review and rewrite both start from an existing draft, so both run the **rewrite path**, which optimizes text that already exists. Write starts from supplied material — notes, bullets, findings, source facts, a brief — so it runs the **write path**, which produces the document that says all of it.

What a mode returns then sets its route through the three passes. Review and rewrite both build pass one's ledger from the draft; rewrite carries that ledger through pass two into pass three, while review holds it as the yardstick for judging the draft against pass two's moves and reports what it finds, rather than producing text for pass three to verify. Write builds its ledger from the supplied material and runs all three passes over the document it produces.

This is the whole mapping. Every later section names the rewrite path and the write path and takes this statement as given.
</mode_to_path_mapping>

<establish_the_reader>
Establish the intended reader and that reader's task before judging anything, drawing on the request and the document itself. When neither names a reader, state the assumed reader in the output so the author can correct it.
</establish_the_reader>

</role_and_activation>

<fidelity_contract>
These rules bind whatever the skill delivers, and they outrank every stylistic preference below them. The ledger they refer to is the inventory pass one builds.

<keep_qualifiers_conditions_and_exceptions>
Keep every qualifier, condition, exception, and scope limit, splitting a sentence to accommodate them rather than trimming them to fit.
</keep_qualifiers_conditions_and_exceptions>

<keep_requirement_strength>
Keep requirement strength exactly as written, in both directions: a must stays a must, a should stays a should, a may stays a may, and a hedge marking real uncertainty stays a hedge. Carry the strength on the modal verb the input used, because a paraphrase into a noun phrase silently reclassifies the requirement — a must rewritten as a hard limit, a firm constraint, or a target reads as a description of the world instead of an obligation on someone, and a should rewritten as a requirement invents an obligation the input never gave.
</keep_requirement_strength>

<keep_every_specific_specific>
Keep every specific specific: a named team stays named, a number keeps its value and unit, and a threshold keeps both sides of its comparison. Take every value from the input, so a figure the input never states — including a gap, total, or percentage that follows arithmetically from two figures it does state — stays off the page and the reader keeps doing that arithmetic themselves.
</keep_every_specific_specific>

<keep_the_reason_beside_the_claim>
Keep the reason beside the claim, so a sentence carrying both a what and a why still carries both afterward, and keep the joining word that marks which is which — because, since, so, therefore, which is why. A reason parked in the next clause with only a semicolon or a full stop between it and its claim leaves the reader to guess that a causal link was meant, so the joint counts as carried through only when a connective states it.
</keep_the_reason_beside_the_claim>

<keep_the_connective_tissue>
Keep the argument's connective tissue by writing full sentences with their articles, verbs, and joining words. The excluded forms are worth naming because they read as concision: telegraphic or steno phrasing that drops those words, and a cascade of ever-shorter bullets that splinters one argument into disconnected stubs.
</keep_the_connective_tissue>

<keep_a_coherent_paragraph_as_prose>
Keep a coherent paragraph as prose whenever its transitions are doing the arguing, and reserve the list form for genuinely parallel items.
</keep_a_coherent_paragraph_as_prose>

<keep_open_questions_visible>
Keep the reader's open questions visible: where the source is genuinely ambiguous, name the competing readings and route the choice to the author, and where a term needs a definition the source never supplies, flag that term for the author. Both routes hand the decision back, in place of the two shortcuts that would hide it — silently picking one reading, or inventing a definition.
</keep_open_questions_visible>

<keep_risks_commitments_and_constraints_at_full_force>
Keep risks, commitments, and constraints at full force.
</keep_risks_commitments_and_constraints_at_full_force>

<keep_a_rewrite_within_the_draft_length>
Keep a rewrite within the length of the draft it replaces. This is the skill's one hard length rule, it governs the rewritten text that rewrite mode returns, and it is measured over that whole delivered text rather than sentence by sentence, so a first-use gloss or a spelled-out abbreviation is paid for by cutting filler elsewhere.
</keep_a_rewrite_within_the_draft_length>

<keep_the_reduction_uncapped_below_that_ceiling>
Take a padded, repetitive, or over-hedged draft markedly below that ceiling — the rewrite has a maximum length and no minimum — and draw every word of the reduction from filler, restatement, nominalized phrasing, and hedging padding, so each ledger item stays whole.
</keep_the_reduction_uncapped_below_that_ceiling>

<keep_a_new_document_as_long_as_its_content_needs>
Keep a newly written document as long as its content needs and no longer, since the write path has no draft length to measure against: the ledger sets what must be said, and the same filler, restatement, and padding stay out from the first draft onward.
</keep_a_new_document_as_long_as_its_content_needs>

</fidelity_contract>

<passes>
The work runs as three ordered passes.

<pass_one_inventory_what_the_delivered_text_is_accountable_for>
Before writing a word, list the load-bearing elements of the input — the existing draft on the rewrite path, the supplied material on the write path — and hold that list as the ledger the delivered text is accountable for. Cover these item classes:

- the central claim, ask, decision, or finding, plus its current placement when the input already has one;
- every actor and owner named or implied, and who must do what;
- every number, date, deadline, quantity, unit, threshold, metric, version, and identifier;
- every product, system, and technical term that carries precision;
- requirement strength as written — must, should, may, will, might, committed, proposed — plus any hedge marking genuine uncertainty;
- conditions, exceptions, scope limits, and qualifiers such as "only when", "except", "up to", and "for X but not Y";
- the causal and logical joints carrying the argument — because, therefore, unless, so that, even though;
- risks, constraints, dependencies, commitments, and open questions;
- ordering wherever sequence is meaning, as in steps, precedence, and priority.
</pass_one_inventory_what_the_delivered_text_is_accountable_for>

<pass_two_produce_the_text_for_first_read_comprehension>
Apply these moves to the text a mode returns, on the rewrite path and the write path alike:

- lead with the main point: make the first sentence carry the most consequential thing the reader has to do or know — the action with its owner and its date, the decision reached, or the finding — so a reader who stops after that one sentence still holds the substance;
- order the whole so each part follows from the one before it, grouping related material and letting the transitions carry the logic that joins the parts;
- carry one idea per sentence on a real verb, and turn an abstract noun back into the verb hiding inside it;
- name the actor in active voice wherever the actor matters;
- choose the common word where it is exactly as precise as the rare one, and keep the technical term where replacing it would cost precision, adding a short gloss on first use when the named reader may not carry that term;
- hold the words that carry force at the wording the input gave them while applying that plain-word move — modal verbs, thresholds, and qualifiers — since these are the words whose everyday-sounding substitutes cost precision;
- unpack a stacked clause chain — em-dash pileups, nested parentheticals — into separate sentences;
- spell out an abbreviation on first use, then use the short form;
- phrase positively wherever the positive says the same thing;
- give longer text descriptive headings, and set genuinely parallel points as a list or table;
- cut a clause that only restates what its own sentence already said.
</pass_two_produce_the_text_for_first_read_comprehension>

<pass_three_verify_the_delivered_text_against_the_ledger>
Where a mode returns text, walk the ledger item by item against the text about to be returned and confirm each item is present with its strength and scope unchanged, restoring anything missing before returning it.

Where first-read comprehension and fidelity pull apart, fidelity decides and the room comes from elsewhere in the text: split the overloaded sentence, then pay for that split by cutting filler, restatement, and nominalized phrasing rather than by letting the text grow.
</pass_three_verify_the_delivered_text_against_the_ledger>

</passes>

<output_contract>

<review_mode_output>
Return one entry per finding, each giving the location as a quoted phrase or a named section, what blocks the first read, what the reader loses, and a concrete replacement.
</review_mode_output>

<rewrite_mode_output>
Return the rewritten text first, complete and ready to use, then a short preservation note naming the ledger items that were at risk, confirming they carried through, and pointing at any place where fidelity forced a longer sentence.
</rewrite_mode_output>

<write_mode_output>
Return the new document first, complete and ready to use, then the same preservation note taken over the supplied material: which ledger items reached the page, and what the material left open for the author to supply.
</write_mode_output>

<shared_close>
Every mode closes with the open items — genuine ambiguities named with their competing readings, and terms needing a definition the source never supplied — phrased as questions for the author, followed by the assumed reader when the source named none.
</shared_close>

<selection_line>
Every mode declares its selection in one line outside the delivered text, naming the mode that ran and the path it runs on, so the author can correct a wrong selection before reading on.
</selection_line>

<delivered_text_carries_content_only>
Every mode keeps the delivered text to its content: the text states what it has to say, and observations about the document live in the preservation note or the findings.
</delivered_text_carries_content_only>

<validation>
The selection line names one mode and its path. Every ledger item appears in the delivered text with its strength and scope unchanged. A rewrite is no longer than the draft it replaces. Open items and the assumed-reader line, where one is needed, close the response.
</validation>

</output_contract>

</language_humanizer>
