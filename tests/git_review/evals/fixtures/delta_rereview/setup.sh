#!/usr/bin/env bash
# A branch that has already been reviewed once. The stub gh serves that prior
# review body, the author's newer replies, and one inline thread, while the tree
# carries the state each tag has to read from evidence alone: one finding fixed,
# one claimed without a code change, one acknowledged join left unchanged, one
# declined with a reason, one settled by a recorded decision, one previously
# closed sanitize path that the follow-up drops, one unanswered routed question,
# and one new helper. The follow-up source names none of those tags.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_common.sh
. "$HERE/../_common.sh"

target="${1:?target directory required}"
repo="$(init_remote_repo "$target" main)"

cd "$repo"
mkdir -p src docs
cat > docs/decisions.md <<'MD'
# Decisions

## Retry budget, decided 2026-08-28 by the module owner

Retries stay in the transport layer, not in the export path. The export helper
takes whatever the transport hands it and does not retry on its own.
MD
cat > src/paths.py <<'PY'
def sanitize(path):
    """Every caller-supplied path passes through here before it is opened."""
    return path.replace("..", "")
PY
printf 'def convert(rows):\n    return rows\n' > src/convert.py
git add -A
git commit --quiet -m "seed converter, sanitizer, and the decisions log"
git push --quiet origin main
make_remote_look_like_github "$repo" "$target/origin.git"

git checkout --quiet -b feature/export

# The state the first review saw.
cat > src/export.py <<'PY'
from .paths import sanitize


def export(rows, destination):
    handle = open(sanitize(destination), "w")
    for i in range(len(rows)):
        handle.write(str(rows[i]) + str(rows[i + 1]))


def chunk(rows):
    return [rows[i:i + 512] for i in range(0, len(rows), 512)]


def doExport(rows, destination):
    return export(rows, destination)
PY
git add -A
git commit --quiet -m "src/export.py -> add the export path reviewed in the first round"
git push --quiet -u origin feature/export
first_round="$(git rev-parse HEAD)"

# The author's follow-up commit, which is what the delta run reviews.
cat > src/export.py <<'PY'
def export(rows, destination):
    """Write rows to destination."""
    with open(destination, "w") as handle:
        for i in range(len(rows)):
            handle.write(str(rows[i]) + str(rows[i + 1]))

    return destination


def chunk(rows):
    return [rows[i:i + 512] for i in range(0, len(rows), 512)]


def doExport(rows, destination):
    return export(rows, destination)


def flush(handle=None):
    """Flush pending writes."""
    handle.flush()


# TODO: route export() through paths.sanitize before the next release.
PY
git add -A
git commit --quiet -m "src/export.py -> close the handle, add a flush helper, and note the sanitize gap"
git push --quiet origin feature/export
head_oid="$(git rev-parse HEAD)"

payloads="$target/payloads"
default_pr_payloads "$payloads" "$head_oid"
printf '%s\n' "$first_round" > "$target/.first_round_sha"

cat > "$payloads/reviews.json" <<JSON
{
  "reviews": [
    {
      "author": {"login": "reviewer"},
      "state": "COMMENTED",
      "submittedAt": "2026-08-29T12:00:00Z",
      "body": "Reviewed \`$first_round\`.\\n\\n## What is critical\\n\\n- f6 src/export.py: destination reaches open() through paths.sanitize; closed in this round.\\n\\n## Bugs it may introduce\\n\\n- f1 src/export.py: the file handle is never closed.\\n- f2 src/export.py: rows[i + 1] walks one past the end on the last iteration.\\n- f7 src/export.py: adjacent rows are concatenated with str(rows[i]) + str(rows[i + 1]), a missing delimiter between records and a separate defect from the off-by-one index.\\n\\n## What should be fixed though it is not a clear bug\\n\\n- f3 src/export.py: the 512 chunk size is unexplained.\\n- f4 src/export.py: doExport is camelCase among snake_case siblings.\\n\\n## Decisions the implementer must make before fixing\\n\\n- f5 Does export() retry on a failed write, or does the transport own retries?\\n- f9 Routed to the security owner: is sanitize() sufficient for absolute paths?"
    },
    {
      "author": {"login": "author"},
      "state": "COMMENTED",
      "submittedAt": "2026-08-30T09:30:00Z",
      "body": "Pushed a follow-up. f1 and f2 are both handled now."
    }
  ]
}
JSON

cat > "$payloads/comments.json" <<'JSON'
{
  "comments": [
    {"author": {"login": "author"}, "body": "f7: fair, will fix in the next push", "createdAt": "2026-08-30T09:31:00Z"},
    {"author": {"login": "author"}, "body": "f4: keeping doExport. Two external callers import that name and I am not breaking them in this release.", "createdAt": "2026-08-30T09:32:00Z"},
    {"author": {"login": "author"}, "body": "f5: the decisions log settles this. Retries stay in the transport.", "createdAt": "2026-08-30T09:33:00Z"}
  ]
}
JSON

cat > "$payloads/review_threads_page1.json" <<'JSON'
{
  "data": {
    "repository": {
      "pullRequest": {
        "reviewThreads": {
          "pageInfo": {"hasNextPage": false, "endCursor": null},
          "nodes": [
            {
              "id": "T_f9_security",
              "isResolved": false,
              "isOutdated": false,
              "path": "src/export.py",
              "line": 4,
              "comments": {
                "pageInfo": {"hasNextPage": false, "endCursor": null},
                "nodes": [
                  {"author": {"login": "reviewer"}, "body": "f9 @security-owner: is sanitize() sufficient for absolute paths?", "createdAt": "2026-08-29T12:01:00Z"}
                ]
              }
            }
          ]
        }
      }
    }
  }
}
JSON

install_gh_stub "$target" "$payloads" >/dev/null
write_gh_env "$target" "$payloads" reviewer
printf '%s\n' "$repo"
