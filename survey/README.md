# Foundry Architecture Survey — bundle

Single-download bundle: the five-poster Foundry architecture survey, the
companion documents from the last two work sessions, and a one-shot script
that reconstructs everything, mints the DOI, and pushes to GitHub.

## What's inside

```
seed_foundry_survey.sh   ← the one-shot script (start here)
posters/                 ← 5 unique posters (the 07:18/07:25 pair was byte-identical; deduped)
  misty.json             ← Zenodo metadata for the poster set
docs/
  USE_CASES.md           ← misty-doi automation use-case contract (session 1)
  tools_inventory_and_workflow_analysis.md   ← Foundry tool inventory + 14-leg workflow analysis (session 2)
scripts/
  batch_publish.sh       ← N-artifact / N-DOI batch publisher with audit ledger
  promote_draft.sh       ← promote a staged Zenodo draft to published
  ai_metadata.py         ← AI-drafted metadata, with `misty validate` as the authority
pages/workflows/
  index.html             ← the ilm.codes/workflows/ explainer (journal & conf workflows + immaterial-OS)
```

## Run it

Safe by default — no flags means reconstruct + validate + dry-run only, no
network, no token, no side effects:

```bash
./seed_foundry_survey.sh
```

Every irreversible action is opt-in and confirmed:

```bash
# rehearse a real mint against Zenodo's sandbox (disposable DOI)
ZENODO_TOKEN=... ./seed_foundry_survey.sh --sandbox --publish

# PRODUCTION DOI (permanent — the script prompts before minting)
ZENODO_TOKEN=... ./seed_foundry_survey.sh --publish

# push survey + posters to project-ilm/foundry via fork -> PR (needs `gh auth login`)
./seed_foundry_survey.sh --push

# open a PR adding /workflows/ to project-ilm/ilm.codes
./seed_foundry_survey.sh --pages

# all of the above (still prompts per irreversible step)
ZENODO_TOKEN=... ./seed_foundry_survey.sh --all
```

## Decisions flagged for you

- **License.** The posters carry "All rights reserved", which contradicts open
  release. `posters/misty.json` defaults to **CC-BY-SA-4.0** (open-content
  copyleft, matching the ecosystem's GPL stance) on the reading that "publish
  these" means open. Override the `license` field before minting if not.
- **Dedup.** Only the exact byte-duplicate poster was dropped (5 unique of 6).
  Broader dedup/reorg is deferred per your note.
- **Repos.** Posters + inventory → `project-ilm/foundry/survey/`. Workflows
  page → `project-ilm/ilm.codes/workflows/`. The misty-doi contract docs also
  belong in `project-ilm/misty-doi/docs|scripts` from the prior session.

© 1993-2026 Abhishek Choudhary. Code: GPL-3.0-or-later. Posters: see above.
