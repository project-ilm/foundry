# Use-Case Contracts

This document extends `docs/CLI.md` and `docs/AUTOMATION.md` with the five
integration patterns most upstream callers ask for. It does not redefine the
CLI — every snippet below calls the real, shipped `misty` commands exactly as
documented in `CLI.md`. Where the CLI has a genuine gap, that gap is named
explicitly rather than papered over with an invented flag.

Verified against `misty-doi==1.0.1` (PyPI wheel + `project-ilm/misty-doi`
source, June 2026).

---

## 1. Single artifact: upload and publish

This is the base case `AUTOMATION.md` already documents. Restated here only
as the unit the other four patterns build on:

```bash
export ZENODO_TOKEN="$MY_SECRET"
misty publish -m misty.json -f release.zip --output result.json
DOI=$(jq -r .doi result.json)
```

`state` in `result.json` is `published` on success. Nothing below changes
this contract — batch, staging, and AI-metadata are all compositions of this
one call.

---

## 2. Batch: many artifacts, many DOIs

`misty publish -f a.zip b.zip` is **not** batch — it puts every file into
*one* Zenodo record. Real batch means: N artifacts, each with its own
canonical metadata file, each minting its own DOI, in one run, with a
per-item result you can audit afterward.

There is no native `misty batch` command. The pattern below is a thin shell
loop around the single-artifact contract — it does not touch `misty`'s
internals.

`scripts/batch_publish.sh`:

```bash
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

  # Append one line to the ledger regardless of success, so a partial batch
  # is always auditable.
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
```

Manifest example (`manifest.tsv`):

```
examples/romenagri/misty.json	build/romenagri-1.0.0.tar.gz
examples/atlasviz/misty.json	build/atlasviz-1.0.0.tar.gz,build/atlasviz-1.0.0.tar.gz.sha256sums
```

Each line is independent: one item's exit code (per the standard `misty`
exit-code table in `CLI.md`) doesn't abort the rest of the batch. The ledger
(`batch_ledger.jsonl`) is the audit trail — one JSON object per item, with
either the full `result.json` payload or just the failure status. This is
deliberately the same shape `misty` already emits per item; batch only adds
sequencing and a combined log, not a new schema.

For a dry-run rehearsal of an entire batch before any token is needed:

```bash
MISTY_EXTRA_ARGS="--dry-run" ./scripts/batch_publish.sh manifest.tsv results/
```

---

## 3. Integrate into automation

`docs/AUTOMATION.md` is the canonical contract (env-only creds, stdout=JSON,
stable exit codes, Make/GitHub Actions recipes). Nothing new is needed here
— the batch script in §2 and the staging pattern in §4 are both already
automation-safe because they only call `misty` the documented way. The one
addition worth naming: in CI, treat the **ledger** from §2 as the artifact to
upload, not individual `result.json` files, so a partial batch failure is
visible in one place:

```yaml
      - run: ./scripts/batch_publish.sh manifest.tsv results/
        env:
          ZENODO_TOKEN: ${{ secrets.ZENODO_TOKEN }}
      - uses: actions/upload-artifact@v4
        with: { name: doi-batch-ledger, path: results/batch_ledger.jsonl }
```

---

## 4. Staging uploads (and a real gap)

The CLI already supports two staging primitives:

| Flag | Effect |
| --- | --- |
| `--dry-run` | package + checksum locally, **zero** network calls |
| `--no-publish` | create deposition, upload files, set metadata — leave as Zenodo **draft** |

What it does **not** support: resuming that draft later to actually publish
it. `cmd_publish` in `misty/cli.py` always runs the full
create→upload→metadata sequence; there is no `--resume-deposition-id` flag,
even though `ZenodoClient.publish(dep_id)` exists internally and would make
this trivial to add.

**Until that lands upstream**, promoting a staged draft requires one direct
Zenodo API call, using the same token, no new dependency:

`scripts/promote_draft.sh`:

```bash
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
```

Usage — stage now, promote after human review, days or weeks later:

```bash
misty publish -m misty.json -f release.zip --no-publish --output draft.json
DEP_ID=$(jq -r .deposition_id draft.json)
# ... review the draft on zenodo.org, get sign-off ...
./scripts/promote_draft.sh "$DEP_ID"
```

**This is a workaround, not a feature.** The clean fix is adding
`misty publish --resume DEP_ID` (or a dedicated `misty promote DEP_ID`
subcommand) upstream in `misty/cli.py`, which would just call the existing
`client.publish(dep_id)` that `cmd_publish` already imports. That's a code
change to the real package, not something to fake at the wrapper level —
flagging it for a PR rather than doing it silently here.

---

## 5. Metadata worked out by AI

`misty validate` / `misty publish` both consume the canonical
`misty.json` shape from `docs/METADATA.md` — they have no opinion about how
that file was produced. The pattern is: AI drafts the canonical record, a
human (or a CI gate) reviews it, then the existing pipeline takes over
unchanged.

`scripts/ai_metadata.py`:

```python
#!/usr/bin/env python3
"""Draft a canonical misty.json from a free-text description + files,
then hand off to the *real* `misty validate` for the actual ground truth —
this script never decides validity itself.

Usage:
    export ANTHROPIC_API_KEY=...
    python3 ai_metadata.py --description notes.md --files src/ -o misty.json
    misty validate -m misty.json     # ground truth, not this script
"""
import argparse, json, subprocess, sys
import anthropic

SCHEMA_HINT = """
Required fields: title, description, creators (list of {name: "Family, Given", ...}),
license (Zenodo id, e.g. "gpl-3.0"), upload_type (one of: publication, poster,
presentation, dataset, image, video, software, lesson, physicalobject, workflow, other).
If upload_type == "publication", publication_type is also required.
Optional: version, access_right, keywords, repository, programming_language.
Output ONLY the JSON object. No prose, no markdown fences.
"""

def draft_metadata(description: str, repo_hint: str | None) -> dict:
    client = anthropic.Anthropic()
    prompt = (
        f"{SCHEMA_HINT}\n\nProject description:\n{description}\n"
        + (f"\nRepository URL: {repo_hint}\n" if repo_hint else "")
    )
    resp = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        messages=[{"role": "user", "content": prompt}],
    )
    text = "".join(b.text for b in resp.content if b.type == "text")
    return json.loads(text)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--description", required=True, help="path to free-text notes")
    ap.add_argument("--repo", default=None, help="repository URL, optional")
    ap.add_argument("-o", "--output", default="misty.json")
    args = ap.parse_args()

    with open(args.description, encoding="utf-8") as fh:
        desc = fh.read()

    metadata = draft_metadata(desc, args.repo)
    with open(args.output, "w", encoding="utf-8") as fh:
        json.dump(metadata, fh, indent=2, ensure_ascii=False)

    print(f"[ai_metadata] drafted -> {args.output}", file=sys.stderr)
    print("[ai_metadata] running real `misty validate` now...", file=sys.stderr)

    # The AI never gets to decide its own output is correct.
    result = subprocess.run(["misty", "validate", "-m", args.output])
    if result.returncode != 0:
        print("[ai_metadata] draft failed validation — review by hand before publishing.",
              file=sys.stderr)
        sys.exit(result.returncode)

    print("[ai_metadata] draft is schema-valid. Still read it before `misty publish`.",
          file=sys.stderr)

if __name__ == "__main__":
    main()
```

The load-bearing design choice: **the AI step only drafts; `misty validate`
is still the authority**, and the script's own exit code is `misty
validate`'s exit code, not its own opinion. This keeps the existing exit-code
contract in `AUTOMATION.md` intact — nothing downstream (CI gates, batch
ledgers) needs to know an AI was involved upstream of the metadata file.

Composing this with batch (§2): run `ai_metadata.py` once per item to
populate the manifest's metadata column, with a mandatory human diff-review
step before the manifest is fed to `batch_publish.sh` — AI-drafted metadata
should never go straight to a `--no-publish`-free batch run.

---

## Summary of what's net-new vs. what already existed

| Use case | Status before this doc | What was added |
| --- | --- | --- |
| Single artifact | Fully covered (`CLI.md`, `AUTOMATION.md`) | Nothing — restated for context |
| Batch | Missing | `scripts/batch_publish.sh` + ledger pattern |
| Automation integration | Fully covered | One CI note (upload the ledger) |
| Staging | Half covered (`--dry-run`, `--no-publish` exist) | Named the missing resume/promote command; workaround script + upstream fix recommendation |
| AI-determined metadata | Missing | `scripts/ai_metadata.py`, with `misty validate` kept as sole authority |

## Also noticed while verifying against source

- `misty/__init__.py` reports `__version__ = "1.0.0"` while the PyPI wheel is
  tagged `1.0.1`. Worth a one-line fix in the next release so
  `misty --version` matches the package version.
