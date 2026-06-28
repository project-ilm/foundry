#!/usr/bin/env bash
# Promote a draft created by `misty publish --no-publish` to published.
# Workaround for a missing CLI feature — see docs/USE_CASES.md §4.
set -euo pipefail

DEPOSITION_ID="${1:?usage: promote_draft.sh DEPOSITION_ID [--sandbox]}"
SANDBOX="${2:-}"

BASE="https://zenodo.org/api"
[ "$SANDBOX" = "--sandbox" ] && BASE="https://sandbox.zenodo.org/api"

: "${ZENODO_TOKEN:?export ZENODO_TOKEN first}"

curl -sf -X POST \
  -H "Authorization: Bearer ${ZENODO_TOKEN}" \
  "${BASE}/deposit/depositions/${DEPOSITION_ID}/actions/publish" \
| python3 -m json.tool
