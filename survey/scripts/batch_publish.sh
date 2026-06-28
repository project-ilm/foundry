#!/usr/bin/env bash
# Batch-publish: one misty.json + one artifact per line in a manifest.
#
# Manifest format (TSV, one record per line):
#   <metadata.json path>\t<artifact path>[,<artifact2>...]
#
# Usage:
#   ZENODO_TOKEN=... ./batch_publish.sh manifest.tsv results/
set -euo pipefail

MANIFEST="${1:?usage: batch_publish.sh manifest.tsv results_dir}"
OUTDIR="${2:?usage: batch_publish.sh manifest.tsv results_dir}"
mkdir -p "$OUTDIR"

LEDGER="$OUTDIR/batch_ledger.jsonl"
: > "$LEDGER"

FAILED=0

while IFS=$'\t' read -r META FILES; do
  [ -z "$META" ] && continue
  IFS=',' read -ra FILE_ARR <<< "$FILES"

  NAME="$(basename "$META" .json)"
  OUT="$OUTDIR/${NAME}.result.json"

  echo "[batch] publishing ${NAME} (${#FILE_ARR[@]} file(s))" >&2

  if misty publish -m "$META" -f "${FILE_ARR[@]}" \
      ${MISTY_EXTRA_ARGS:-} \
      --package-dir "$OUTDIR/${NAME}-package" \
      --output "$OUT"; then
    STATUS="ok"
  else
    STATUS="failed_exit_$?"
    FAILED=$((FAILED + 1))
  fi

  python3 - "$NAME" "$STATUS" "$OUT" >> "$LEDGER" <<'PY'
import json, sys, os
name, status, out_path = sys.argv[1:4]
record = {"item": name, "status": status}
if os.path.exists(out_path):
    with open(out_path) as fh:
        record["result"] = json.load(fh)
print(json.dumps(record))
PY

done < "$MANIFEST"

echo "[batch] done. $FAILED failure(s). Ledger: $LEDGER" >&2
exit $([ "$FAILED" -eq 0 ] && echo 0 || echo 1)
