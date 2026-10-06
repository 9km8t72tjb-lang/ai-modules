# Grader validation

Recorded after the relation-class restore and the
`paragraphs_open_with_point` tighten. `grade.py` and `judge.py` both saw the
same draft from `evals/fixtures/connected_rewrite/setup.sh`.

## grade.py

`faithful.md` passed: word count under the draft's 465, no pronoun-opening
run, the intake/review/release series as a colon series, no em dash, canary
and shadow share defined in their first-use window, `delivered.md` present,
and the draft untouched.

`flattened.md` failed: the pronoun-opening run reached 3, the series was prose
rather than a list or a colon series, and both canary and shadow share were
bare at first use with the gloss only later. Word count, the em dash check,
and the untouched draft still passed, so the failure is the shape the sample
was written to break.

The same two samples, hard-wrapped at 72 columns, grade identically for the
series and pronoun checks. `python3 tests/natural_language/evals/test_grade.py`
holds those wrapped variants and the first-use definition checks.

## judge.py

`faithful.md` passed every qualitative assertion: `contrast_kept`,
`two_reasons_kept`, `condition_kept`, `signal_inventory_kept`,
`paragraphs_open_with_point`, `figures_tied`,
`arithmetic_opens_with_conclusion`, and `connected_prose`.

`flattened.md` failed `contrast_kept`, `two_reasons_kept`, `condition_kept`,
`paragraphs_open_with_point`, `arithmetic_opens_with_conclusion`, and
`connected_prose`. It dropped the contrast marker between the automated-check
and client-library claims (separate sentences with no `but` or `yet`), named
signals weakly or not as an inventory, and kept a figure frame, so
`figures_tied` passed when that frame remained.

A topic-heading probe that opens a body paragraph with mechanism ("The checks
run inside the service...") before its claim fails `paragraphs_open_with_point`.
