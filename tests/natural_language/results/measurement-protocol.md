# Measurement protocol

Tracked note for the `natural_language` behavioural measurement. Per-run
`run-*.{json,md}` files are gitignored; this file names the protocol runs and
labels grader edits as broadenings or weakenings per `TESTING.md`
`## Test Integrity`.

## Protocol

One baseline run and one refined run, each over five passes, graded by the
same frozen `grade.py` and `judge.py`. A miss below the bar is reported and
stopped; it is not re-run for a better draw.

```bash
git show HEAD:styles/natural-language.md > /tmp/nl-baseline-style.md
python3 tests/natural_language/evals/run.py --run-label baseline \
  --style /tmp/nl-baseline-style.md
python3 tests/natural_language/evals/run.py --run-label refined
```

## Grader edits (broaden vs weaken)

| Edit | Kind | Evidence |
| --- | --- | --- |
| Move canary/shadow-share first-use checks from `judge.py` into `grade.py` | Broadening (mechanical) | Same property, now deterministic; faithful still passes, flattened still fails. |
| Accept same-sentence alias, next-sentence definition, and plain-words-then-name windows for those glosses | Broadening | Pins the style's first-use window, not one surface phrasing of it. |
| Accept canary/shadow gloss paraphrases (`small share`/`reaches`/`traffic`, `new build`/`old`) | Broadening | Substance of the gloss, not one exact phrase set. |
| Soften `signal_inventory_kept` to accept questions/checks/signals as the inventory label | Broadening | Three-item inventory, not the word "signals". |
| Soften `paragraphs_open_with_point` for topic-headed sections (body may open with evidence) | Weakening | Baseline arithmetic paragraphs that led with counts still passed this assertion under the carve-out. |
| Tighten `paragraphs_open_with_point`: topic heading does not supply the opening; fail evidence/counts/mechanism/chronology first | Restored strength | Mechanism-first probe under a topic heading fails; faithful passes. |
| Accept counterfactual "would reach" and juxtaposition for `contrast_kept` | Weakening | Dropped: relation class and reach claim were under-pinned. |
| Fail `while`/`until` circumstances for `two_reasons_kept` | Restored strength | Cause must stay a cause. |
| Require contrast marker `but`/`yet` and drop counterfactual exception in `contrast_kept` | Restored strength | Flattened juxtaposition now fails `contrast_kept` (see `grader-validation.md`). |
| Require a gloss at the first use of "shadow share" whenever that name appears; fall back to "canary share" only when "shadow share" is absent | Restored strength | A bare "shadow share" followed by a glossed "canary share" now fails `term_referent`. `run-20261005-183830`, `run-20261005-183936`, and `run-20261005-184711` each use one name, so their recorded rates stand. |

## Protocol runs (frozen graders)

The first three rows were recorded after the `paragraphs_open_with_point`
restore and the style strengthen on cause/contrast markers. Graders were not
edited between `run-20261005-183936` and `run-20261005-184711`. The fourth
row follows the shadow-share restore and the removal of the duplicate
first-use sentence from `<keep_the_relations>`.

| Label | Run id | `connected_rewrite` | `chat_brevity` | Notes |
| --- | --- | --- | --- | --- |
| baseline | `run-20261005-183830` | 0/5 | 5/5 | Fixture discriminates. Diverging: arithmetic 0/5, paragraphs 0/5, contrast 1/5, two_reasons 2/5, plus term/canary/figures. |
| refined | `run-20261005-183936` | 0/5 | 5/5 | Below the bar before the contrast-marker strengthen. Diverging: `contrast_kept` 1/5, `paragraphs_open_with_point` 3/5, `two_reasons_kept` 4/5, `arithmetic_opens_with_conclusion` 4/5. |
| refined (contrast strengthen) | `run-20261005-184711` | 2/5 | 5/5 | Same frozen graders, style only. Below the bar. Diverging: `contrast_kept` 3/5, `two_reasons_kept` 3/5, `paragraphs_open_with_point` 4/5. Disposition to the operator; no re-run for a better draw. |
| refined (one statement per rule) | `run-20261005-192444` | 2/5 | 5/5 | After the shadow-share restore and the duplicate-rule drop. Below the bar. Diverging: `contrast_kept` 4/5, `two_reasons_kept` 3/5. Disposition to the operator; no re-run for a better draw. |
