# Tool Inventory & Integrated Workflow Analysis
**For: multi-AI consolidation exercise (Claude pass)**
**Method note:** Section A is built from live GitHub API queries against `project-ilm` and `ayeai` (+ sub-orgs `ayepy`, `ayegames`, `ayerunner`, `ayevdi`) on 2026-06-28, not from memory or assumption. Each entry is marked **[confirmed repo]**, **[confirmed via memory, repo not located]**, or **[third-party, not ours]**. Section B is the workflow analysis you asked for, built on top of A — gaps are named as gaps, not silently filled with invented tools.

---

## A. Comprehensive Tool Inventory

### A1. ILM / HPS Linguistic Stack — `project-ilm` org

| Tool | Status | What it is |
| --- | --- | --- |
| `ilm.codes` | confirmed repo | Main ILM / Integrative Linguistic Multiscript project (BETA) |
| `legacy` | confirmed repo | Initial fork from Project Hindawi — historical root |
| `ilm-phonology` | confirmed repo | Layer 0: IPA core, phonotactics, prosody, dialect normalization, reversible sound mapping |
| `ilm-transliteration` | confirmed repo | Layer 1: reversible, compiler-friendly Romanized pivot (Romenagri's layer) |
| `ilm-orthography` | confirmed repo | Layer 2: script shaping, Unicode normalization, ZWJ/ZWNJ, grapheme clustering |
| `ilm-lexicon` | confirmed repo | Layer 3: morpho-lexical — lexicons, WordNets, morphology, clitics, affixation |
| `ilm-syntax-semantics` | confirmed repo | Layer 4: UD parsing, SRL, AMR/UCCA, discourse segmentation, code-switching |
| `ilm-interface` | confirmed repo | Layer 5: multiscript IMEs, NLU APIs (TTS/ASR/QA), mother-tongue IDEs, ed-tools |
| `ilm-data` | confirmed repo | Canonical corpora, dialect maps, phoneme-audio pairs, aligned scripts |
| `ilm-validation` | confirmed repo | Native-speaker QA, annotation tools, field instruments, crowdsourced schema |
| `ilm-lsp` | confirmed repo | Language Server Protocol implementation for ILM scripts |
| `ilm-devtools` | confirmed repo | Reversible compiler infra, script-aware IDEs, debug harnesses |
| `vscode-ilm` | confirmed repo | VS Code extension for ILM |
| `ilm-meta` | confirmed repo | Vision docs, architecture diagrams, manifestos, roadmap |
| `ilm-site` | confirmed repo | Public-facing project site |
| `language-specs` | confirmed repo | Formal language specifications |
| `linguistics-labs` | confirmed repo | Experimental linguistics workbenches |
| `romenagri` | confirmed repo | Reversible transliteration library, Perso-Arabic seed, GPL, 1993–2026 |
| `praat` | confirmed repo (fork) | **Third-party** phonetics tool, used not authored — keep separate from "created" list |

### A2. Publication, Provenance & Repo Hygiene — `project-ilm` org

| Tool | Status | What it is |
| --- | --- | --- |
| `misty-doi` | confirmed repo, verified to source | Automation-first DOI minting + Zenodo packaging (covered in depth last turn) |
| `spi-scan` | confirmed repo, README read | **Sensitive Personal Information scanner** — scans working tree, full git history, and GitHub metadata (issues/PRs/comments/releases) for leaked secrets/PII before a repo is opened up or transferred. `pip install spi-scan`. This is directly relevant to the GitHub-flow and community-management legs below. |
| `ops` | confirmed repo, README read | "The auditable home for every build/fix/handoff script, the architecture, and the process." This is the literal home of `AI_SYNC_PROTOCOL.md` and `queue.txt` from your memory — it's already the multi-AI coordination substrate. |
| `ai-scratch` | confirmed repo (thin README: "AI automations for Project ILM") | Likely the right home for any new AI-driven workflow scripts (e.g. the §5 AI-metadata pattern from the misty-doi work) |
| `foundry` | confirmed repo, README read | "Canonical engineering substrate." Stated pipeline: **Inventory → Audit → Bootstrap → Validate → Benchmark → Recover**. This is a generic engineering lifecycle scaffold — a natural anchor point for the integrated workflow in Part B. |

### A3. Cognitive / Embodiment Infrastructure — `project-ilm` org

| Tool | Status | What it is |
| --- | --- | --- |
| `cognitive-fabric` | confirmed repo, README read | "Profile-driven, container-first, reproducible cognitive infrastructure for conversational digital humans, embodied cognitive agents, robotic systems." Explicitly does **not** own models — it's an orchestration/deployment/benchmarking layer over upstream open-source AI. Scope stack: Infrastructure → Runtime → Perception → Cognition → Expression → Embodiment → Deployment. This is the most plausible existing substrate for the "AI-based video/training-video/poster" leg in Part B, if it's further along than the README suggests — worth you confirming current state, since the README reads as early-stage ("bootstrap completed, docs in progress, reference runtime under development"). |

### A4. AyeAI Ecosystem — `ayeai` + sub-orgs (`ayepy`, `ayegames`, `ayerunner`, `ayevdi`)

| Tool | Status | What it is |
| --- | --- | --- |
| `ayeam` | confirmed repo | "AyeAI's Autonomous Metaverse — a cyber-physical autonomous metaverse... a nervous system for the Singularity" (your AyeAM Triad layer) |
| `opssi` | confirmed repo | "Open public stack for synthetic intelligence" |
| `athena` (GSF VIKRAM) | confirmed repo | "An inclusive rural digitalization platform by GramSheel Foundation" — also mirrored as `ayevdi.github.io` |
| `ayeq` | confirmed repo, description not yet pulled | Name suggests a quantum-computing tie-in (the org also forks Qiskit/qiskit-terra/qiskit-aer) — **status needs your confirmation**, I haven't read its README |
| `chuha` | confirmed repo | "Chat Hosting Utility with Hyperlink Automation" — directly relevant to the **community-management (Discord etc.)** leg in Part B |
| `upload` | confirmed repo | "Staggered Upload™" — name suggests a controlled/phased release tool, possibly relevant to the **staging** pattern from the misty-doi contract; **status needs your confirmation**, README not yet read |
| `ayepy.github.io` | confirmed repo | "AyePy — the AyeAI distribution of Python" |
| `ayeracer` | confirmed repo | "AyeRacer — AyeAI port of ETR" (game/sim) |
| `ayevdi` | confirmed repo (+ several mirror/legacy repos) | "Virtualized Deployment IaaS for Scientific & Cognitive Computing" |
| `chintamani` (`ayerunner`) | confirmed repo | "HindawiAI in Telugu" — direct lineage from the Hindawi Programming System into a Telugu-language AI tool |
| `unani` (`ayerunner`) | confirmed repo, description not pulled | Name suggests Unani medicine — possibly an Interglial Healthcare-adjacent tool; **status needs your confirmation** |
| `nbrunner` (`ayerunner`) | confirmed repo | "NBRunner by AyeAI" — notebook runner, likely a dev/experiment-execution tool relevant to the **test/experiments** leg |
| `bash2python`, `anusaaraka`, `xmp`, `dockersh` | confirmed repos | Dev-tooling utilities (script conversion, a translation engine import, a CUDA precision library, container-shell isolation) |

### A5. Forked / vendored third-party tools (used, not created) — flagged for completeness, excluded from "tools we've built"

`ayeai` also forks and maintains modified copies of: `qiskit`/`qiskit-terra`/`qiskit-aer` (quantum computing), `sway` (Wayland compositor), `IBM FHIR server`, `AIX360`, `adversarial-robustness-toolbox`, `kui`, `runc`/`go-digest`/`image-tools`/`runtime-tools` (OCI container ecosystem), `x11docker`, `KodExplorer`, `shellinabox`, `util-linux`, `shadow`. These are infrastructure dependencies you maintain forks of, not original IP — listed here only so the inventory is honest about what's yours vs. what's borrowed.

### A6. Independent IP confirmed by your memory but **not GitHub-hosted** (pre-repo era, hardware, or not public)

PEDLER (1995/96, Indian Patent 3033/CHE/2011), HPS itself as the original 2004 systems-programming stack (its living successor is the `ilm-*` layer stack above), HMSEI wearable (2002), DrRho/RDK telemedicine device, ANGEL cognitive robot (2003), TARA autonomous vehicle. I did not find GitHub repos for these — likely correct, since several predate GitHub (founded 2008) or are hardware. Flagging rather than assuming absence means anything.

### A7. Not located despite searching — needs your input before I assert anything

- **AtlasViz** (the GPL visualization library your memory says was "seeded to `project-ilm` GitHub org") — not in the current `project-ilm` repo listing. Either private, renamed, or the listing I pulled is incomplete (org listings can hide private repos from unauthenticated API calls). **I'm not going to guess where it is — can you confirm the repo name or whether it's private?**
- A personal `abhishekchoudhary` GitHub account exists but belongs to a different person (unrelated profile, bio "coldpress AI", repos like `homebrew-cask`/`browserstack-local-python` with no connection to ILM/AyeAI) — I'm flagging this explicitly so it doesn't get mistaken for yours in the other AIs' answers.

---

## B. Integrated Workflow Analysis

For each stage: **existing tool (if any) → gap → integration point.** The spine I'm anchoring everything to is `foundry`'s own stated lifecycle — **Inventory → Audit → Bootstrap → Validate → Benchmark → Recover** — since that's already your canonical engineering substrate, not something I'm inventing.

### 1. Research
- **Existing:** `ilm-data`, `ilm-validation`, `linguistics-labs` for linguistic research; `cognitive-fabric`'s "map the complete design space" philosophy for cognitive/embodiment research.
- **Gap:** no found tool for general literature search/citation management/research-note capture across domains (legal, linguistic, cognitive).
- **Integration point:** `ops` is the natural home for a research-intake script that normalizes notes into the same canonical-record pattern misty-doi uses for metadata — one schema, many downstream consumers.

### 2. Development
- **Existing:** the full `ilm-devtools`, `vscode-ilm`, `ilm-lsp` stack; `bash2python`; `nbrunner` for notebook-based dev.
- **Gap:** none obvious — this is your most mature leg.
- **Integration point:** `foundry`'s Bootstrap/Validate stages are the right hook for CI.

### 3. Test / experiments
- **Existing:** `nbrunner` (notebook runner), `foundry`'s explicit "Benchmark" stage, `ilm-validation` (native-speaker QA loops).
- **Gap:** no unified experiment-tracking/results-versioning tool surfaced (e.g. an MLflow-equivalent). Possibly intentionally out of scope, or possibly missing.
- **Integration point:** experiment outputs should land as `misty-doi` canonical artifacts the moment they're publication-worthy — that's the only point where "experiment" and "publication" legs should touch.

### 4. Paper publishing (DOI, OTS, preprints, submissions)
- **Existing:** `misty-doi` does DOI minting + Zenodo + OTS stamping (`misty ots stamp/verify/upgrade`) end-to-end, verified working last turn.
- **Gap:** no preprint-server submission tool (arXiv, bioRxiv, etc.) and no journal-submission-portal tool found — these are typically manual web-form flows with no public API at most journals, so a "tool" here may not be buildable in the general case.
- **Integration point:** `misty package` already produces a self-contained, reviewer-shareable bundle (`manifest.json`, checksums, all metadata formats) — that bundle is the right hand-off artifact to a manual preprint/journal submission step, rather than trying to automate portals that don't expose APIs.

### 5. Journal workflow management
- **Existing:** none found.
- **Gap:** real gap. Most journals use OJS, ScholarOne, or Editorial Manager — none of which you've forked or wrapped.
- **Integration point:** lowest-effort real addition would be a thin tracking layer (status: submitted/under-review/revisions/accepted per paper) living in `ops`, fed manually until/unless a target journal's API is worth wrapping.

### 6. Conference workflow management
- **Existing:** none found.
- **Gap:** real gap, same shape as journal workflow (most conference systems are EasyChair/HotCRP, no general API).
- **Integration point:** same tracking-layer recommendation as #5 — likely the same tool, parameterized by venue type.

### 7. Patent submission workflow
- **Existing:** none found in repos; you have real patent history (PEDLER, 3033/CHE/2011) but that predates any tooling.
- **Gap:** real gap, and a sensitive one — patent prosecution has jurisdiction-specific legal requirements I'd be cautious about over-automating.
- **Integration point:** at most a status-tracker (same shape as #5/#6), explicitly **not** an automated filing tool — that step should stay human/counsel-reviewed given the stakes already evident in your litigation history.

### 8. Social media announcements
- **Existing:** none found as a dedicated tool; `chuha` ("Chat Hosting Utility with Hyperlink Automation") is the closest adjacent tool but is chat-hosting, not social posting.
- **Gap:** real gap.
- **Integration point:** natural trigger point is `misty publish`'s `result.json` — a `state: published` result with a DOI is exactly the event that should fire an announcement step. This is the cleanest "automation" leg to add since it's a pure consumer of an existing, stable JSON contract.

### 9. GitHub-based flow
- **Existing:** this is **fully covered** — your own standing rule (fork→PR→merge, LOUD output) plus `spi-scan` as the pre-release gate plus `ops` as the script-of-record home. This is the most mature leg after Development.
- **Gap:** none.
- **Integration point:** `spi-scan` should sit immediately before any "open-source this" or "transfer this repo" step — it already exists for exactly that purpose.

### 10. Community management (Discord etc.)
- **Existing:** `chuha` is the only plausible match, but its description ("Chat Hosting Utility with Hyperlink Automation") doesn't confirm Discord-specifically — **needs your confirmation** of what `chuha` actually targets before I either rely on it or flag it as a gap.
- **Gap:** likely real, pending the above confirmation.
- **Integration point:** if `chuha` doesn't cover it, the natural feed is the same `result.json`/announcement event from #8.

### 11. AI-based posters, papers, PPT, videos, training videos, quizzes
- **Existing:** `cognitive-fabric` is the closest infrastructure (expression/embodiment layers) but reads as early-stage per its own README. No dedicated poster/PPT/video generator surfaced.
- **Gap:** real gap for the document/slide/video generation itself — though this is exactly the kind of artifact Claude/ChatGPT/Gemini can generate directly per-request (as I do in chat) rather than needing a standing "tool."
- **Integration point:** if this needs to be repeatable/branded (not ad hoc), it belongs as a templated generator inside `ai-scratch` ("AI automations for Project ILM") rather than as one-off chat outputs — that repo's stated purpose is exactly this.

### 12. Quizzes
- **Existing:** none found.
- **Gap:** real gap.
- **Integration point:** same `ai-scratch` home as #11 if templated; otherwise ad hoc per request.

### 13. Learning workflow management
- **Existing:** `ilm-interface` mentions "educational tools" in its own description but scope vs. a full LMS is unconfirmed.
- **Gap:** likely real for anything beyond linguistic ed-tools specifically.
- **Integration point:** needs your confirmation of `ilm-interface`'s actual current scope before I'd recommend building something that already exists there.

### 14. Student enrollment management
- **Existing:** none found.
- **Gap:** real gap — this is a generic CRM/registration need, unrelated to the linguistic-tooling core, and the kind of thing a lightweight off-the-shelf form+database (not a bespoke build) usually serves better than new IP.
- **Integration point:** lowest priority to build custom; recommend evaluating existing free/cheap tools before adding to the inventory at all.

---

## C. What this means for the integrated pipeline

The honest shape of your stack right now: **stages 1–4 and 9 are genuinely strong and already interoperate** (research → dev → test → DOI/OTS publish → GitHub flow, gated by `spi-scan`, orchestrated through `ops`/`foundry`). **Stages 5–8 and 10–14 are either real gaps or unconfirmed** — I'd rather tell you that plainly than invent six fictitious repos to make the list look complete, especially since this output is going to be diffed against ChatGPT's and Gemini's.

Three items need your direct confirmation before the consolidation pass: **(1)** where AtlasViz actually lives, **(2)** what `chuha`, `upload`, `ayeq`, and `unani` actually do (descriptions weren't fetched), **(3)** `cognitive-fabric`'s and `ilm-interface`'s actual current implementation state vs. their aspirational READMEs.
