#!/usr/bin/env python3
"""Draft a canonical misty.json from a free-text description, then hand off
to the *real* `misty validate` for the actual ground truth — this script
never decides validity itself.

Usage:
    export ANTHROPIC_API_KEY=...
    python3 ai_metadata.py --description notes.md -o misty.json
    misty validate -m misty.json     # ground truth, not this script
"""
import argparse
import json
import subprocess
import sys

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
        print(
            "[ai_metadata] draft failed validation — review by hand before publishing.",
            file=sys.stderr,
        )
        sys.exit(result.returncode)

    print(
        "[ai_metadata] draft is schema-valid. Still read it before `misty publish`.",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
