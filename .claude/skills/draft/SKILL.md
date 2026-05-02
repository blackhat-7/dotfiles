---
name: draft
description: Draft a plan to ~/.flow/<slug>/PLAN.md for the named task. Arguments are either `<slug> <mode>` or just `<mode>`; when slug is omitted, use the current flow task for this terminal/session context. Mode is patch | clean | refactor. Run after /understand.
argument-hint: "[task-slug] <patch|clean|refactor>"
---

# /draft

Draft `~/.flow/<slug>/PLAN.md` for the problem just discussed in chat. Stop after writing — do not implement.

Runs from any cwd. The task directory was set up by `/understand`; this step requires it to exist.

## Step 0 — Validate args

`$ARGUMENTS` may be either `<slug> <mode>` or just `<mode>` (whitespace-separated). Slug must match `[a-z0-9][a-z0-9-]*`. Mode must be exactly one of `patch`, `clean`, `refactor`.

If only `<mode>` is provided, resolve slug from the current-flow file for this terminal/session context: `$HOME/.flow/current/<context-key>`. If it is missing, empty, or points to a missing task directory, ask for an explicit slug.

If anything is missing or invalid, reply:

> Usage: `/draft [task-slug] <patch|clean|refactor>` (e.g. `/draft patch` or `/draft fix-jpeg-corrupt patch`).

Then stop.

## Step 1 — Locate state

```bash
CURRENT_KEY="${PI_FLOW_SESSION_KEY:-${STARSHIP_SESSION_KEY:-${ATUIN_SESSION:-${KITTY_PID:-$(pwd | shasum | cut -c1-12)}}}}"
CURRENT_FILE="$HOME/.flow/current/$CURRENT_KEY"
FROM_CURRENT=0
set -- $ARGUMENTS
if [[ $# -eq 1 ]]; then
  FROM_CURRENT=1
  MODE="$1"
  SLUG=$(cat "$CURRENT_FILE" 2>/dev/null)
elif [[ $# -eq 2 ]]; then
  SLUG="$1"
  MODE="$2"
else
  echo "BAD_ARGS"; exit 0
fi
[[ "$MODE" =~ ^(patch|clean|refactor)$ ]] || { echo "BAD_ARGS"; exit 0; }
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "BAD_ARGS"; exit 0; }
DIR="$HOME/.flow/$SLUG"
[[ -d "$DIR" ]] || { echo "NO_TASK from_current=$FROM_CURRENT"; exit 0; }
mkdir -p "$(dirname "$CURRENT_FILE")"
printf '%s\n' "$SLUG" > "$CURRENT_FILE"
[[ -f "$DIR/PLAN.md" ]] && echo "EXISTS" || echo "NEW"
```

- `BAD_ARGS`: show the usage from Step 0. Stop.
- `NO_TASK from_current=1`: tell user no current flow task exists for this terminal/session context and ask for `/draft <slug> <mode>` or `/understand [slug]`. Stop.
- `NO_TASK from_current=0`: tell user to run `/understand <slug>` first. Stop.
- `EXISTS`: read the file, summarize its mode and approach in 3 bullets, ask whether to replace it. Stop unless the user says replace.

## Step 2 — Confirm problem context

There must be a clear problem in the recent chat (from `/understand <slug>` or the user's message). If there isn't — no concrete problem statement, no file:line refs, no edge cases — say so and ask the user to run `/understand <slug>` first or paste the context. Stop.

If `/understand` listed open questions and they aren't yet answered, surface the unanswered ones (numbered) and stop until answered.

## Step 3 — Plan, mode-specific

Read **only the code needed** to find the right change. Do not survey unrelated code.

You may, and should, ask 1–2 short numbered questions if there's real ambiguity. Don't dump options.

### Mode: `patch` — minimum diff, hacky-OK if correct

For each candidate change ask:
- Is there a smaller change that's still correct?
- Does this require a new file, function, class, or abstraction? → drop it.
- Does this touch code outside the symptom path? → drop it.

### Mode: `clean` — local cleanup, ≤300 lines

Read the affected function/module fully and its callers' call sites (not their internals). For each candidate:
- Is the result clearly simpler than before? Less branching/indirection/state? If you can't articulate one specific way it's simpler, downgrade to `patch`.
- Does it stay inside the affected function/module? If it spreads further → that's `refactor`.
- Stays under 300 lines of diff?
- Can you do it without a new file? One helper file is allowed only if it removes meaningfully more than it adds. State the math.

### Mode: `refactor` — structural, justify each new file

Use this only when:
- The change is structural (not a fix one place could handle), AND
- `clean` would clearly fail (must spread further than one module), OR
- The current architecture is the actual obstacle.

If the user is reaching for refactor for a one-line fix, push back: ask if `patch` or `clean` is right. Don't accept "let's clean it up since we're here."

For each new file/abstraction/boundary you must answer:
- Why this exists (one sentence).
- What was considered instead (one sentence).
- Why this beat the alternative (one sentence).

If you can't answer all three for a piece, drop it.

## Step 4 — Write `.flow/<slug>/PLAN.md`

Write `$HOME/.flow/<slug>/PLAN.md`. Header line:

```
# Plan: <slug> — mode: <patch|clean|refactor>
```

Then the sections below for the chosen mode. ≤1 page rendered (≤2 for refactor). Bullets > prose. File:line precision in `## Changes` is required for all modes — vague targets ("the auth module") are forbidden. Use paths relative to the cwd where `/draft` is invoked (e.g. `editing-trainer/src/foo.py:42` for a multi-repo parent, or `src/foo.py:42` for a single repo).

### Sections — `patch`

```
## Approach
1–3 sentences. The actual change in plain language.

## Why this works
≤5 bullets. The minimal logical reasons it's correct.

## When it WON'T work
Bullets. Inputs/states this patch does not cover. "Nothing — fully covers" only
if you've actually convinced yourself.

## Hack disclosure   [include only if hacky]
What's hacky. Why hacky-but-correct beats cleaner alternatives here.

## Changes
file:line — what changes, in 1 line. One bullet per hunk. Paths relative to the
task root.

## Edge cases verified
For each edge case from PROBLEM, how this plan addresses it.

## Diff budget
Aim: <X> lines. Cap: 100. No new files.

## Halt-on-deviation contract
If during /build I cannot stay within this plan — a coupling I missed, a case
the plan doesn't cover, the diff is going past the cap — I will STOP, append
"## Build notes" to this file, and ask. I will not hack forward.
```

### Sections — `clean`

```
## Approach
1–4 sentences.

## Why this works
≤5 bullets.

## Why it's simpler than before
Required. Concrete: "removes the branch at L42–L70 by ...", "collapses three
near-duplicate handlers into one", etc. If you can't fill this honestly,
downgrade to patch.

## When it WON'T work
Bullets.

## Changes
file:line — one line per hunk. Group by file. Paths relative to the task root.

## New helper   [include only if adding one file]
Path. One-line purpose. Math: removes ~N lines from <file>, adds ~M lines in
this helper, net <0.

## Edge cases verified
For each edge case from PROBLEM.

## Diff budget
Aim: <X> lines. Cap: 300. Files touched: <N>. New files: 0 or 1.

## Halt-on-deviation contract
[same as patch]
```

### Sections — `refactor`

```
## Approach
3–6 sentences. What moves where.

## Architecture (after)
ASCII diagram. Modules/services/interfaces and data flow. One screenful.
Mark new boxes [NEW] and removed boxes [REMOVED].

## Why this works
≤6 bullets.

## Why this shape (vs alternatives)
1–2 sentences per realistic alternative. Why the chosen shape wins. If there
are no realistic alternatives, say so.

## When it WON'T work / known limits
Bullets. Future surface this shape is not designed for.

## Changes
Group by repo, then by file. file:line — what changes, in 1 line.

## New files
For each: path | one-line purpose | one-line "considered alternative".
If you can't fill all three, the file shouldn't exist.

## Removed files / dead-code deletions
Path | what it was | why it's gone.

## Migration / rollout
- Backwards compat: what's preserved, what breaks, why that's OK.
- Order of changes if it must land in steps: 1, 2, 3.
- Rollback plan.

## Edge cases verified
For each edge case from PROBLEM.

## Diff size estimate
~<X> added, ~<Y> removed. Net: <X-Y>. Files: <N>. New: <M>. Removed: <K>.

## Halt-on-deviation contract
[same as patch]
```

## Step 5 — Hand back

Output **only**:

> PLAN.md drafted at `.flow/<slug>/PLAN.md` (mode: \<mode\>). Budget: \<X\> lines. New files: \<count\>.
> Review and run `/build` when ready, or push back in chat.

Stop. Do not implement.

## Forbidden across all modes

- Proposing solutions for problems not raised in chat
- "While I'm here" cleanup
- Adding error handling, validation, fallbacks not asked for
- Adding tests unless the user asked — that's a separate decision
- "We could also..." sections — pick one approach
- Editing any file other than `.flow/<slug>/PLAN.md`
- Walls of text in chat
