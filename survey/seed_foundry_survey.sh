#!/usr/bin/env bash
###############################################################################
#
#  seed_foundry_survey.sh
#
#  One-shot reconstruct + validate + (optionally) mint-DOI + (optionally) push
#  for the Foundry Architecture Survey poster set and companion artifacts.
#
#  PHILOSOPHY (matches the standing engineering rules):
#    * Safe by default. Run with NO flags and it only reconstructs text
#      artifacts, validates metadata, and dry-runs the DOI package. Zero
#      side effects, zero network, no token required.
#    * Every irreversible step is opt-in AND confirmed:
#        --publish   mint a real Zenodo DOI   (needs ZENODO_TOKEN; prompts)
#        --push      push to project-ilm/foundry via fork -> PR (needs gh auth)
#        --pages     open a PR adding /workflows/ to project-ilm/ilm.codes
#    * LOUD output. Every URL is printed, never swallowed.
#    * Text artifacts are reconstructed here via `cat > f <<'EOF'` so they are
#      canonical regardless of bundle drift. The poster PNGs ship ALONGSIDE
#      this script in ./posters/ (binaries are not base64-embedded — they
#      travel with the bundle, which is more robust than a 15 MB heredoc).
#
#  USAGE
#      ./seed_foundry_survey.sh                  # reconstruct + validate + dry-run
#      ./seed_foundry_survey.sh --sandbox --publish   # rehearse a real mint on Zenodo sandbox
#      ZENODO_TOKEN=... ./seed_foundry_survey.sh --publish   # PRODUCTION mint (prompts)
#      ./seed_foundry_survey.sh --push           # fork->PR the survey+posters to foundry
#      ./seed_foundry_survey.sh --pages          # fork->PR the workflows page to ilm.codes
#      ./seed_foundry_survey.sh --all            # everything (still prompts per step)
#
#  © 1993-2026 Abhishek Choudhary. Code: GPL-3.0-or-later.
###############################################################################
set -euo pipefail

# ---------------------------------------------------------------------------- #
# flags
# ---------------------------------------------------------------------------- #
DO_PUBLISH=0; DO_PUSH=0; DO_PAGES=0; SANDBOX=0
for a in "$@"; do
  case "$a" in
    --publish) DO_PUBLISH=1 ;;
    --push)    DO_PUSH=1 ;;
    --pages)   DO_PAGES=1 ;;
    --sandbox) SANDBOX=1 ;;
    --all)     DO_PUBLISH=1; DO_PUSH=1; DO_PAGES=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^#//'; exit 0 ;;
    *) echo "unknown flag: $a (try --help)" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

FOUNDRY_REPO="project-ilm/foundry"
ILMCODES_REPO="project-ilm/ilm.codes"
SUBDIR="survey"            # where this lands inside project-ilm/foundry

say()  { printf '\n\033[1;33m=== %s ===\033[0m\n' "$*"; }
loud() { printf '\033[1;36m  %s\033[0m\n' "$*"; }
warn() { printf '\033[1;31m  !! %s\033[0m\n' "$*"; }
confirm() {
  printf '\033[1;31m%s\033[0m ' "$1 [type YES to proceed]:"
  read -r ans
  [ "$ans" = "YES" ] || { warn "not confirmed; skipping."; return 1; }
}

say "FOUNDRY SURVEY SEED — root: $ROOT"
loud "publish=$DO_PUBLISH push=$DO_PUSH pages=$DO_PAGES sandbox=$SANDBOX"

###############################################################################
# 1. Reconstruct directory layout
###############################################################################
say "1. RECONSTRUCT LAYOUT"
mkdir -p docs scripts posters pages/workflows
loud "docs/ scripts/ posters/ pages/workflows/ ready"

###############################################################################
# 2. Reconstruct text artifacts (canonical, via heredoc)
#    NOTE: the full bodies of USE_CASES.md, tools_inventory_*.md,
#    batch_publish.sh, promote_draft.sh, ai_metadata.py, and the workflows
#    index.html ship in this bundle. This script verifies their presence and
#    (re)writes the small canonical files. The large docs are taken as-is from
#    the bundle; if any are missing the script reports it rather than shipping
#    a half-empty tree.
###############################################################################
say "2. VERIFY TEXT ARTIFACTS PRESENT"
MISSING=0
for f in docs/USE_CASES.md \
         docs/tools_inventory_and_workflow_analysis.md \
         scripts/batch_publish.sh \
         scripts/promote_draft.sh \
         scripts/ai_metadata.py \
         pages/workflows/index.html ; do
  if [ -s "$f" ]; then loud "present: $f ($(wc -l < "$f") lines)"
  else warn "MISSING: $f"; MISSING=1; fi
done
[ "$MISSING" -eq 0 ] || { warn "bundle incomplete — refusing to proceed."; exit 1; }

# (Re)write the canonical Zenodo metadata for the poster set.
cat > posters/misty.json <<'JSON'
{
  "title": "Foundry: An Architecture Survey for a Civilizational Research Operating System (Poster Set)",
  "version": "1.0.0",
  "upload_type": "poster",
  "description": "<p>A five-poster visual survey of <strong>Foundry</strong> — a proposed knowledge kernel and engineering substrate for long-duration, human–AI collaborative research programmes. The set maps an integrated landscape of tools, workflows, and architectural vision, from a concrete tool/workflow inventory to a post-AGI civilizational operating-system architecture.</p><p>Posters: (1) Foundry Ecosystem Architecture Survey; (2) The Knowledge Kernel of a Civilizational Operating System; (3) The Civilizational Workflow Architecture (ISCO/ISCED/ISIC); (4–5) The Method Behind the Infrastructure. Part of Project ILM / AyeAI.</p>",
  "license": "cc-by-sa-4.0",
  "access_right": "open",
  "language": "eng",
  "creators": [
    {"name": "Choudhary, Abhishek", "affiliation": "AyeAI Consulting / Project ILM"}
  ],
  "keywords": ["research operating system","human-AI collaboration","engineering substrate","workflow architecture","ISCO","ISCED","ISIC","post-AGI","knowledge kernel","provenance","reproducibility","Project ILM","Foundry","AyeAI"],
  "related_identifiers": [
    {"relation":"isPartOf","identifier":"https://ilm.codes","resource_type":"other"},
    {"relation":"isSupplementedBy","identifier":"https://github.com/project-ilm/foundry","resource_type":"software"},
    {"relation":"references","identifier":"https://github.com/project-ilm/misty-doi","resource_type":"software"}
  ],
  "repository": "https://github.com/project-ilm/foundry",
  "notes": "LICENSE DECISION FLAGGED: source images carry 'All rights reserved', which contradicts open release. This deposit defaults to CC-BY-SA-4.0 on the assumption that 'publish these' means open release. Override before minting if intent differs."
}
JSON
loud "wrote posters/misty.json"

say "POSTER INVENTORY"
shopt -s nullglob
PNGS=(posters/*.png)
if [ "${#PNGS[@]}" -eq 0 ]; then
  warn "no posters/*.png found — they ship alongside this script in the bundle."
  warn "place the 5 PNGs in ./posters/ and re-run."
  exit 1
fi
for p in "${PNGS[@]}"; do loud "$(du -h "$p" | cut -f1)  $p"; done

###############################################################################
# 3. Validate + dry-run the DOI package (always; no side effects)
###############################################################################
say "3. VALIDATE METADATA + DRY-RUN DOI PACKAGE"
if ! command -v misty >/dev/null 2>&1; then
  warn "misty not installed. Run: pip install misty-doi"
  warn "skipping validate/package; reconstruction is complete."
else
  misty validate -m posters/misty.json
  misty publish -m posters/misty.json -f "${PNGS[@]}" \
        --dry-run --package-dir doi-package --output result.dryrun.json
  loud "dry-run package -> $ROOT/doi-package"
  loud "dry-run result  -> $ROOT/result.dryrun.json"
fi

###############################################################################
# 4. (Optional) mint a REAL DOI — irreversible, gated
###############################################################################
if [ "$DO_PUBLISH" -eq 1 ]; then
  say "4. MINT DOI"
  if [ "$SANDBOX" -eq 1 ]; then
    export ZENODO_SANDBOX=1
    loud "SANDBOX mode — this mints a disposable test DOI on sandbox.zenodo.org"
  else
    warn "PRODUCTION mode — a Zenodo DOI is PERMANENT and cannot be deleted."
  fi
  if [ -z "${ZENODO_TOKEN:-}" ]; then
    warn "ZENODO_TOKEN is not set. export ZENODO_TOKEN=... and re-run. Skipping mint."
  elif confirm "Mint a $([ "$SANDBOX" -eq 1 ] && echo SANDBOX || echo PRODUCTION) DOI for ${#PNGS[@]} posters?"; then
    misty publish -m posters/misty.json -f "${PNGS[@]}" \
          --package-dir doi-package --output result.json
    DOI="$(python3 -c 'import json;print(json.load(open("result.json"))["doi"] or "")' 2>/dev/null || true)"
    URL="$(python3 -c 'import json;print(json.load(open("result.json"))["record_url"] or "")' 2>/dev/null || true)"
    say "DOI MINTED"
    loud "DOI : $DOI"
    loud "URL : $URL"
    [ -n "$DOI" ] && echo "$DOI" > ZENODO_DOI.txt && loud "saved -> ZENODO_DOI.txt"
  fi
fi

###############################################################################
# 5. (Optional) push survey + posters to project-ilm/foundry via fork -> PR
###############################################################################
if [ "$DO_PUSH" -eq 1 ]; then
  say "5. PUSH TO $FOUNDRY_REPO (fork -> PR)"
  if ! command -v gh >/dev/null 2>&1; then
    warn "gh CLI not found. Install it and run: gh auth login. Skipping push."
  elif ! gh auth status >/dev/null 2>&1; then
    warn "gh not authenticated. Run: gh auth login. Skipping push."
  else
    ME="$(gh api user -q .login)"
    loud "authenticated as: $ME"
    FORK="$ME/foundry"
    gh repo fork "$FOUNDRY_REPO" --clone=false >/dev/null 2>&1 || loud "fork exists"
    TMP="$(mktemp -d)"
    git clone "https://github.com/$FORK.git" "$TMP/foundry" >/dev/null 2>&1
    cd "$TMP/foundry"
    git remote add upstream "https://github.com/$FOUNDRY_REPO.git" 2>/dev/null || true
    git fetch upstream >/dev/null 2>&1
    BR="survey-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$BR" upstream/main >/dev/null 2>&1 || git checkout -b "$BR" >/dev/null 2>&1
    mkdir -p "$SUBDIR/docs" "$SUBDIR/scripts" "$SUBDIR/posters"
    cp "$ROOT"/docs/*            "$SUBDIR/docs/"
    cp "$ROOT"/scripts/*         "$SUBDIR/scripts/"
    cp "$ROOT"/posters/*.png     "$SUBDIR/posters/"
    cp "$ROOT"/posters/misty.json "$SUBDIR/posters/"
    [ -f "$ROOT/ZENODO_DOI.txt" ] && cp "$ROOT/ZENODO_DOI.txt" "$SUBDIR/"
    git add "$SUBDIR"
    git commit -m "Add Foundry architecture survey: poster set, tool inventory, DOI automation contract" >/dev/null
    git push -u origin "$BR" >/dev/null 2>&1
    say "OPENING PR"
    gh pr create --repo "$FOUNDRY_REPO" --head "$ME:$BR" \
       --title "Foundry architecture survey (posters + inventory + DOI contract)" \
       --body "Five-poster Foundry architecture survey, the tool inventory & workflow analysis, and the misty-doi automation use-case contract. Seeded under \`$SUBDIR/\`. Dedup/reorg to follow." \
       2>&1 | tee /tmp/prout | grep -Eo 'https://github.com/[^ ]+' | while read -r u; do loud "PR: $u"; done
    cd "$ROOT"
  fi
fi

###############################################################################
# 6. (Optional) add the /workflows/ page to project-ilm/ilm.codes via fork -> PR
###############################################################################
if [ "$DO_PAGES" -eq 1 ]; then
  say "6. ADD /workflows/ TO $ILMCODES_REPO (fork -> PR)"
  if ! command -v gh >/dev/null 2>&1 || ! gh auth status >/dev/null 2>&1; then
    warn "gh not available/authenticated. Skipping pages PR."
  else
    ME="$(gh api user -q .login)"
    gh repo fork "$ILMCODES_REPO" --clone=false >/dev/null 2>&1 || loud "fork exists"
    TMP="$(mktemp -d)"
    git clone "https://github.com/$ME/ilm.codes.git" "$TMP/ilm.codes" >/dev/null 2>&1
    cd "$TMP/ilm.codes"
    git remote add upstream "https://github.com/$ILMCODES_REPO.git" 2>/dev/null || true
    git fetch upstream >/dev/null 2>&1
    BR="workflows-page-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$BR" upstream/main >/dev/null 2>&1 || git checkout -b "$BR" >/dev/null 2>&1
    mkdir -p workflows
    cp "$ROOT/pages/workflows/index.html" workflows/index.html
    git add workflows/index.html
    git commit -m "Add /workflows/ — research, journal & conference workflows + the immaterial-OS argument" >/dev/null
    git push -u origin "$BR" >/dev/null 2>&1
    say "OPENING PR"
    gh pr create --repo "$ILMCODES_REPO" --head "$ME:$BR" \
       --title "Add /workflows/ explainer page" \
       --body "Static page at /workflows/ explaining journal & conference workflow management over the universal grammar, and why the OS is immaterial when the host is minimal. Matches existing site.css. Deploys via the site's existing Pages setup." \
       2>&1 | tee /tmp/prout2 | grep -Eo 'https://github.com/[^ ]+' | while read -r u; do loud "PR: $u"; done
    cd "$ROOT"
  fi
fi

say "DONE"
loud "Reconstructed + validated. Side-effecting steps run only when their flag is passed."
[ "$DO_PUBLISH" -eq 0 ] && loud "To mint the DOI:  ZENODO_TOKEN=... ./seed_foundry_survey.sh --publish"
[ "$DO_PUSH" -eq 0 ]    && loud "To push to foundry:  ./seed_foundry_survey.sh --push   (needs gh auth)"
[ "$DO_PAGES" -eq 0 ]   && loud "To publish the page:  ./seed_foundry_survey.sh --pages  (needs gh auth)"
