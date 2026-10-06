#!/usr/bin/env bash
# stage.sh stages one natural_language eval and prints the agent-ready inputs.
#
# Usage:
#   stage.sh <eval_id> [target_dir]
#
# Valid eval ids:
#   connected_rewrite  argumentative draft, relations kept, shape repaired
#   chat_brevity       short question, one-sentence answer in a context file
#
# Prints name=value lines on stdout, each value already quoted with
# printf %q so the block is safe to `eval`:
#
#   sandbox_proj=<abs path to the project the worker should operate in>
#   source_file=<abs path to the fixture document inside that project>
#   prompt=<the user prompt to feed the worker>
#
# Run the worker with $sandbox_proj as its working directory. A pristine copy
# of the source document is kept at $target/.fixture_pristine so grade.py can
# prove the worker left that file untouched.

set -euo pipefail

eval_id="${1:?eval id required (connected_rewrite|chat_brevity)}"
target="${2:-$(mktemp -d "${TMPDIR:-/tmp}/nl_eval.XXXXXX")}"
mkdir -p "$target"
target="$(cd "$target" && pwd)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$eval_id" in
  connected_rewrite)
    sandbox_proj="$("$HERE/fixtures/connected_rewrite/setup.sh" "$target")"
    source_file="$sandbox_proj/draft.md"
    prompt="Rewrite draft.md so a reader follows the reasoning on the first read. Save only the rewritten document to delivered.md and leave draft.md unchanged."
    ;;
  chat_brevity)
    sandbox_proj="$("$HERE/fixtures/chat_brevity/setup.sh" "$target")"
    source_file="$sandbox_proj/question.md"
    prompt="Answer the question in question.md. Use context.md. Write the answer as your reply."
    ;;
  *)
    echo "unknown eval id: $eval_id" >&2
    exit 2
    ;;
esac

cp "$source_file" "$target/.fixture_pristine"

printf 'sandbox_proj=%q\n' "$sandbox_proj"
printf 'source_file=%q\n'  "$source_file"
printf 'prompt=%q\n'       "$prompt"
