---
name: build
description: Implement strictly according to ~/.flow/<slug>/PLAN.md for the named task. Halt on any deviation — append "## Build notes" to PLAN.md, stop, and ask. Argument is the task slug. Run after /draft.
argument-hint: <task-slug>
---

# /build

Implement **strictly** according to `~/.flow/<slug>/PLAN.md`. Every diff hunk must trace to a PLAN.md line. **Halt on any deviation**: stop, write what you found, ask. Do not paper over snags. Do not expand scope.

Runs from any cwd. Resolves repo paths relative to the task root saved in `~/.flow/<slug>/ROOT` (set by `/understand`).

## Step 0 — Validate slug

Slug: `$ARGUMENTS`. Must match `[a-z0-9][a-z0-9-]*`. If empty or invalid, reply:

> Usage: `/build <task-slug>` (e.g. `/build fix-jpeg-corrupt`).

Then stop.

## Step 1 — Locate the plan

```bash
SLUG="$ARGUMENTS"
DIR="$HOME/.flow/$SLUG"
PLAN="$DIR/PLAN.md"
ROOT=$(cat "$DIR/ROOT" 2>/dev/null) || ROOT="$(pwd)"
[[ -f "$PLAN" ]] && echo "OK root=$ROOT" || echo "MISSING"
```

If `MISSING`: tell user no plan exists for slug `<slug>` — run `/draft <slug> <mode>` first. Stop.

`ROOT` is the directory the user was in at `/understand` time. All `## Changes` paths in PLAN.md are relative to it.

## Step 2 — Read the plan once, fully

Read PLAN.md fully before any edits. Do not implement from skim.

Output one sentence in chat: "Plan loaded — \<slug\>, \<mode\>, \<N\> file changes, budget \<X\>. Starting build."

## Step 3 — Implement, plan-line by plan-line

Work through the `## Changes` section in order. For each:

1. Open the file. Read the surrounding context (the function/struct, not just the line).
2. Make the change exactly as specified.
3. Mental check: does this match the plan line? Does it require any work the plan didn't list?
4. If yes to (3) — see "Halt-on-deviation" below.
5. Move on. One brief signal per file is enough.

**Do not** make any change that doesn't trace to a PLAN.md line. If you find yourself thinking "I should also..." — stop. That's deviation.

### Halt-on-deviation

A deviation is **anything**:
- A coupling or caller you didn't see at plan time and now must touch.
- An edge case the planned change doesn't cover.
- A type / contract / signature mismatch the plan didn't anticipate.
- The diff is heading past the budget.
- Existing code is wrong in a way that affects this change.
- A test or build step fails in a way that suggests the plan is incomplete.

When you hit one:
1. **Stop editing.** Do not press on. Do not "make it work."
2. Append a `## Build notes` section to `.flow/<slug>/PLAN.md` describing exactly what you found (1–3 bullets).
3. Tell the user, one short message: "Hit a deviation: \<one line\>. Notes appended to PLAN.md. Update the plan and re-run `/build <slug>`, or tell me how to proceed."
4. Stop.

## Step 4 — Self-check before declaring done

After the last planned change:

1. Run `git diff HEAD` in each touched repo. To find the repos, take each unique first path component from PLAN's `## Changes`; if `$ROOT/<component>/.git` exists, treat it as a repo and `cd "$ROOT/<component>"`. If no components are git repos (single-repo task), `cd "$ROOT"` and diff there. Read the actual diff, all of it.
2. Cross-check yourself:
   - Every hunk traces to a PLAN.md line?
   - Every PLAN.md `## Changes` line has a corresponding hunk?
   - Every PROBLEM edge case (per PLAN's `## Edge cases verified`) is covered by a real line in the diff?
   - Diff size within budget?
3. If anything fails, treat it as a deviation: stop, append `## Build notes`, ask.

## Step 5 — Hand back

If self-check passed, output **only**:

> Build done for `<slug>`. Diff: \<+X / -Y\> across \<N\> files in \<repos\>.
> Run `/audit <slug>` for an independent review.

Stop. Do not run `/audit` yourself.

## Forbidden during build

- Adding code that doesn't trace to PLAN.md
- "While I'm here" cleanup, renaming, formatting
- Adding error handling, validation, or fallbacks not in PLAN
- Adding tests not in PLAN
- Importing libraries not already in the affected file unless PLAN says to
- Hacking forward when something doesn't work — that's halt-on-deviation
- Walls of text in chat — file:line + one short signal per change
- Editing PLAN.md other than appending `## Build notes` on a deviation
