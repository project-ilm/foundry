# Foundry Contract v0.1

Status: Draft

This document is the canonical operational contract for the Foundry ecosystem.

Every human, AI, automation, CI workflow and repository SHALL conform to this contract.

-------------------------------------------------------------------------------
0. PURPOSE
-------------------------------------------------------------------------------

Foundry exists to eliminate engineering drift.

Goals:

- Alignment before implementation.
- Inventory before modification.
- Retrieval before reconstruction.
- Systems before software.
- Capability before embodiment.
- Reproducibility before convenience.

-------------------------------------------------------------------------------
1. HIERARCHY
-------------------------------------------------------------------------------

Mission

↓

Architecture

↓

Operational Model

↓

Capabilities

↓

Implementations

Never invert this hierarchy.

-------------------------------------------------------------------------------
2. GOLDEN RULES
-------------------------------------------------------------------------------

1. Never assume.

2. Inventory first.

3. Audit second.

4. Plan.

5. Modify.

6. Validate.

7. Benchmark.

8. Publish.

9. Record.

10. Recover.

-------------------------------------------------------------------------------
3. OBSERVATION RULE
-------------------------------------------------------------------------------

Observation SHALL NOT modify the system.

Inventory scripts

Audit scripts

Doctor scripts

Status scripts

must be read-only.

-------------------------------------------------------------------------------
4. REPOSITORY RULE
-------------------------------------------------------------------------------

Repositories contain

Source

Documentation

Contracts

Bootstrap

Validation

Architecture

Generated inventories SHALL NOT be committed.

Generated reports SHALL live outside repositories unless explicitly archived.

-------------------------------------------------------------------------------
5. AI RULE
-------------------------------------------------------------------------------

Every AI SHALL begin by reading

CONTRACT.md

then

ARCHITECTURE.md

then

STATE/

then

inventory.

Only afterwards may modifications begin.

-------------------------------------------------------------------------------
6. SCRIPT CONTRACT
-------------------------------------------------------------------------------

Every script SHALL

- be idempotent

- be restartable

- be resumable

- produce deterministic output

- provide exit summary

- never destroy existing work

- never assume branch names

- never assume remotes

- never assume package managers

-------------------------------------------------------------------------------
7. GITHUB CONTRACT
-------------------------------------------------------------------------------

GitHub CLI is the control plane.

Repository URLs SHALL be discovered.

Branches SHALL be discovered.

Authentication SHALL be discovered.

Never hardcode.

-------------------------------------------------------------------------------
8. WORKSPACE CONTRACT
-------------------------------------------------------------------------------

Canonical workspace

~/work

Everything engineering belongs beneath this tree.

-------------------------------------------------------------------------------
9. INVENTORY CONTRACT
-------------------------------------------------------------------------------

Generated inventories belong under

~/work/inventory/YYYY-MM-DD/

Never inside repositories.

-------------------------------------------------------------------------------
10. PUBLISH CONTRACT
-------------------------------------------------------------------------------

Humans

GitHub Pages

Machines

JSON

YAML

Markdown

-------------------------------------------------------------------------------
11. ENGINEERING PRINCIPLE
-------------------------------------------------------------------------------

Alignment

↓

Architecture

↓

Automation

↓

Implementation

Automation without alignment creates drift.

-------------------------------------------------------------------------------
12. CHANGE CONTROL
-------------------------------------------------------------------------------

This contract has precedence over

README

AGENTS

CLAUDE

CODEX

GEMINI

Repository-specific conventions.

