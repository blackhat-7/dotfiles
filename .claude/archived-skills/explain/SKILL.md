---
name: explain
description: Write a 1-page ~/.flow/<slug>/EXPLAIN.md summarizing the named task — problem, solution, why-it-works, when-it-won't, files changed, decisions worth remembering. Optional argument is the task slug; if omitted, use the current flow task for this terminal/session context. Run after /audit returns SHIP.
argument-hint: "[task-slug]"
---

# /explain

Produce a 1-page `~/.flow/<slug>/EXPLAIN.md` that captures, in one place, what to tell anyone who later asks **"why did we do this?"** or **"why so much code for that?"**.

Run from the repo/workspace root used for `/draft` and `/build`.

## Step 0 — Validate slug

Slug: `$ARGUMENTS`. If empty, resolve slug from the current-flow file for this terminal/session context: `$HOME/.flow/current/<context-key>`. Must match `[a-z0-9][a-z0-9-]*`. If missing or invalid, reply:

> Usage: `/explain [task-slug]` (e.g. `/explain` or `/explain fix-jpeg-corrupt`).

Then stop.

## Step 1 — Locate state

```bash
CURRENT_KEY="${PI_FLOW_SESSION_KEY:-${STARSHIP_SESSION_KEY:-${ATUIN_SESSION:-${KITTY_PID:-$(pwd | shasum | cut -c1-12)}}}}"
CURRENT_FILE="$HOME/.flow/current/$CURRENT_KEY"
FROM_CURRENT=0
if [[ -z "$ARGUMENTS" ]]; then
  FROM_CURRENT=1
  SLUG=$(cat "$CURRENT_FILE" 2>/dev/null)
else
  SLUG="$ARGUMENTS"
fi
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "BAD_ARGS"; exit 0; }
DIR="$HOME/.flow/$SLUG"
ROOT="$(pwd)"
[[ -f "$DIR/PLAN.md"   ]] && { mkdir -p "$(dirname "$CURRENT_FILE")"; printf '%s\n' "$SLUG" > "$CURRENT_FILE"; echo "PLAN=yes"; } || echo "PLAN=no from_current=$FROM_CURRENT"
[[ -f "$DIR/REVIEW.md" ]] && echo "REVIEW=yes" || echo "REVIEW=no"
echo "ROOT=$ROOT"
```

- `BAD_ARGS`: show the usage from Step 0. Stop.
- `PLAN=no from_current=1` → tell user no current flow plan exists for this terminal/session context — run `/draft <slug> <mode>` and `/build <slug>` first or pass a slug. Stop.
- `PLAN=no from_current=0` → tell user no plan for slug `<slug>` — run `/draft <slug> <mode>` and `/build <slug>` first. Stop.
- `REVIEW=no` → ask user to confirm an audit isn't needed before continuing. If they decline, tell them to run `/audit`.

If REVIEW.md exists, read its `## Verdict`:
- `SHIP` → continue.
- `NEEDS-FIXES` / `RE-PLAN` → tell user to address the audit before explaining. Stop.
- Missing → ask user to confirm before continuing.

## Step 2 — Read PLAN.md (and REVIEW.md if present) and capture diff stats

Read PLAN.md fully. If REVIEW.md exists, read it too — its findings inform "When it WON'T work" and "Decisions".

Capture diff stats by running, for each touched repo (per PLAN's `## Changes`). To find each repo: take each unique first path component; if `$ROOT/<component>/.git` exists, that's a repo. If no components are git repos, use `$ROOT` itself.

```bash
cd "$REPO_DIR"
git diff --stat HEAD
```

Sum across repos.

If you find yourself wanting to re-read application code to write the explanation, the PLAN/REVIEW are not specific enough — ask the user before continuing.

## Step 3 — Write `.flow/<slug>/EXPLAIN.md`

≤1 page rendered. Bullets > prose. Cite file:line where relevant.

```
# <slug> — <one-line task title>

## Problem
1 sentence. What was broken or what was needed.

## Solution
3–5 sentences. The actual change in plain language. Mention the mode used
(patch / clean / refactor) and the diff size.

## Why it works
≤5 bullets. The minimal logical reasons. Cite file:line where it pins
correctness.

## When it WON'T work
Bullets. Edges this change does not cover. Future surface this lifts later
work on. If the patch is hacky, what the hack does not address.

## Diagram   [include only if structure is non-trivial]
Tiny ASCII. Before/after if useful. Skip if a one-line description does the job.

## Files changed
By repo. Full paths. Bullets.

## Diff
+<X> / -<Y> across <N> files. New: <M>. Removed: <K>.

## Decisions worth remembering
≤3 bullets. The non-obvious choices and why we made them. ("We didn't add X
because..." / "We picked Y over Z because..."). This is what answers the
"why this way?" question in three months.
```

Rules:
- Stay 1 page. If it doesn't fit, cut, don't expand.
- The "Decisions worth remembering" section is the **most important** part for future-you. Spend the words there, not on restating the diff.
- No "we should also..." sections. The work is done.

## Step 4 — Hand back

Output **only**:

> EXPLAIN.md written at `~/.flow/<slug>/EXPLAIN.md`.
> Diff: \<+X / -Y\> across \<N\> files.
>
> Paste into the PR description. The task directory `~/.flow/<slug>/` keeps the full
> record (PLAN, REVIEW, EXPLAIN) until you delete it.

Stop.

## Forbidden

- Walls of text in chat — EXPLAIN.md is the artifact
- Restating the full diff or full plan in EXPLAIN.md
- "Future improvements" or "next steps" sections — those are separate tasks
- Editing application code
- Creating EXPLAIN.md when REVIEW.md verdict is not SHIP (and the user hasn't confirmed)
