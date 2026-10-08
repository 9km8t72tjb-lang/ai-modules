# Isolation comparison: language_humanizer

Isolation left the skill below the bar on all three scenarios, and the same
failure classes held, so the earlier unisolated results describe real
weaknesses of the skill rather than an artifact of the host's instructions.
The comparison also changes the vendor, though, so no single movement below
can be attributed to isolation alone.

## The two runs

- **Isolated run:** `run-20261008-105117`, denominator 5. The worker is
  Cursor (`agent -p`, model `auto`) and the judge runs on `auto`. Every worker
  and judge call starts from an isolated root created by
  `tests/lib/worker_isolation.py`, and the skill copy is staged as a project
  skill of that root.
- **Baseline:** `run-20261008-101519`, denominator 5, the latest non-regrade
  `results/run-*` before isolation that reports all three scenarios. The
  worker is Claude (`claude -p`, model `sonnet`) and the judge inherits the
  default model. Worker and judge both started inside the repository, so the
  host's standing-instruction files reached them.
- **Left out:** `run-20261008-103951` and `run-20261008-104748` are one-pass
  write_path plumbing checks of the isolated runner, not measurements, and
  `run-20261003-082239` recorded a harness fault on every pass and measured
  nothing.

## Rates by scenario and assertion

### fidelity_padded

Scenario pass rate: baseline 1/5, isolated 2/5.

| Assertion | Baseline | Isolated |
| --- | --- | --- |
| `delivered_file_written` | 5/5 | 5/5 |
| `delivered_text_present` | 5/5 | 5/5 |
| `fixture_unmodified` | 5/5 | 5/5 |
| `item_actor_billing` | 5/5 | 5/5 |
| `item_actor_priya` | 5/5 | 5/5 |
| `item_causal_joint` | 5/5 | 5/5 |
| `item_deadline_14_march` | 5/5 | 5/5 |
| `item_exception_enterprise` | 5/5 | 5/5 |
| `item_strength_must` | 5/5 | 5/5 |
| `item_strength_should` | 5/5 | 5/5 |
| `item_threshold_200ms` | 5/5 | 5/5 |
| `item_threshold_995` | 5/5 | 5/5 |
| `length_at_most_75pct` | 5/5 | 5/5 |
| `no_invented_content` | 5/5 | 4/5 |
| `no_short_bullet_cascade` | 5/5 | 5/5 |
| `reads_plainly` | 2/5 | 2/5 |
| `strength_unchanged` | 4/5 | 5/5 |

### compression_trap

Scenario pass rate: baseline 1/5, isolated 2/5.

| Assertion | Baseline | Isolated |
| --- | --- | --- |
| `argument_stays_connected_prose` | 1/5 | 3/5 |
| `compounding_argument_kept` | 5/5 | 5/5 |
| `delivered_file_written` | 5/5 | 5/5 |
| `delivered_text_present` | 5/5 | 5/5 |
| `fixture_unmodified` | 5/5 | 5/5 |
| `hedge_intact` | 5/5 | 5/5 |
| `hedge_kept` | 5/5 | 5/5 |
| `length_at_most_fixture` | 5/5 | 5/5 |
| `no_flat_causal_assertion` | 5/5 | 5/5 |
| `paragraph_stays_prose` | 5/5 | 5/5 |
| `reads_plainly` | 5/5 | 4/5 |

### write_path

Scenario pass rate: baseline 0/5, isolated 0/5.

| Assertion | Baseline | Isolated |
| --- | --- | --- |
| `delivered_file_written` | 5/5 | 5/5 |
| `delivered_text_present` | 5/5 | 5/5 |
| `five_items_at_strength` | 5/5 | 5/5 |
| `fixture_unmodified` | 5/5 | 5/5 |
| `item_deadline_30_april` | 5/5 | 5/5 |
| `item_owner_dana` | 5/5 | 5/5 |
| `item_owner_marco` | 5/5 | 5/5 |
| `item_strength_must` | 5/5 | 5/5 |
| `item_threshold_2h` | 5/5 | 5/5 |
| `item_threshold_per_quarter` | 5/5 | 5/5 |
| `no_filler_or_restatement` | 0/5 | 1/5 |
| `no_filler_phrases` | 5/5 | 5/5 |
| `no_invented_content` | 5/5 | 5/5 |
| `no_short_bullet_cascade` | 4/5 | 5/5 |
| `opens_with_main_point` | 5/5 | 3/5 |
| `reads_as_connected_prose` | 5/5 | 5/5 |

## Assertions that moved

- `fidelity_padded` / `no_invented_content`: 5/5 to 4/5.
- `fidelity_padded` / `strength_unchanged`: 4/5 to 5/5.
- `compression_trap` / `argument_stays_connected_prose`: 1/5 to 3/5.
- `compression_trap` / `reads_plainly`: 5/5 to 4/5.
- `write_path` / `no_filler_or_restatement`: 0/5 to 1/5.
- `write_path` / `no_short_bullet_cascade`: 4/5 to 5/5.
- `write_path` / `opens_with_main_point`: 5/5 to 3/5.

Every move is one or two passes out of five, which is within the sampling noise
of a five-pass run, and the two vendors differ as well as the isolation. The
failure classes stayed the same: `reads_plainly` held at 2/5 on
fidelity_padded, and write_path missed the bar on every pass in both runs,
mostly on `no_filler_or_restatement`.

## What stays open

The disposition of the earlier unisolated results (the 3 August runs on
`claude-sonnet-4-6` and the 8 October audit run above) belongs to the user.
One finding bears on any Cursor result recorded before this change: an
isolated Cursor worker told to path-read a staged skill copy read the deployed
`~/.cursor/skills` copy instead (traced on 8 October 2026), until the copy was
staged as a project skill of the worker's workspace. This harness has no
earlier Cursor result, so its baseline is unaffected.
