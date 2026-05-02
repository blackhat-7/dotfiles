---
name: understand
description: Start a flow task by reading code, asking sharp questions, and outputting a bulleted PROBLEM summary in chat. Optional argument is a kebab-case task slug (e.g. fix-jpeg-corrupt); if omitted, derive one from the user's request. Creates ~/.flow/<slug>/ as the task directory and marks it as the current flow task for this terminal/session context. PROBLEM stays in chat — no file is written.
argument-hint: "[task-slug]"
---

# /understand

Start a flow task. Deeply understand the problem before any code or plan exists. Output is bullets in chat — **no PROBLEM.md file is written**. You **do not** propose solutions, suggest approaches, or sketch fixes.

The task directory lives at `~/.flow/<slug>/`.

## Step 0 — Validate slug

Slug: `$ARGUMENTS`

Must match `[a-z0-9][a-z0-9-]*` (kebab-case, no spaces, no slashes, no uppercase). If empty and the invoking message has enough detail, derive a short kebab-case slug from the user's request (3–6 words; e.g. "fix JPEG corrupt" → `fix-jpeg-corrupt`) and use it. If empty and the invoking message does not have enough detail, ask the Step 2 one-line-description question first, then derive the slug from the answer and continue setup. If invalid, reply:

> Usage: `/understand [kebab-case-slug]` (e.g. `/understand fix-jpeg-corrupt`).

Then stop.

## Step 1 — Set up task directory

```bash
SLUG="$ARGUMENTS"  # if empty, use the derived slug from Step 0
DIR="$HOME/.flow/$SLUG"
CURRENT_KEY="${PI_FLOW_SESSION_KEY:-${STARSHIP_SESSION_KEY:-${ATUIN_SESSION:-${KITTY_PID:-$(pwd | shasum | cut -c1-12)}}}}"
CURRENT_FILE="$HOME/.flow/current/$CURRENT_KEY"
if [[ -f "$DIR/PLAN.md" ]]; then
  echo "EXISTS_WITH_PLAN"
else
  mkdir -p "$DIR" "$(dirname "$CURRENT_FILE")"
  printf '%s\n' "$SLUG" > "$CURRENT_FILE"
  echo "OK"
fi
```

If `EXISTS_WITH_PLAN`: a previous plan exists for this slug. Tell the user and ask whether they want to extend the existing task (re-run `/draft <slug> <mode>` to overwrite) or pick a different slug. Stop.

## Step 2 — One question first

If the user's invoking message already states clearly what's broken / what's needed, skip this. Otherwise ask, with no preamble:

> One-line description: what's broken or what needs to be added?

Wait for the answer. No further tool calls yet.

## Step 3 — Read the code

Read aggressively. Do **not** guess.

- Bug: trace symptom to code, find where it actually originates.
- Feature: find the seams it would attach to; understand the surrounding contracts.
- Multi-repo: if cwd is a parent of repos, search across each relevant repo.

One short sentence at the start ("reading X to find Y") and a brief signal when you find the relevant code. Don't narrate every file.

## Step 4 — Output PROBLEM in chat

Reply with **exactly** this structure (omit a section only if explicitly noted):

```
## What
1–2 sentences. The problem (bug) or the change needed (feature).

## Why it happens   [bug only — remove for features]
Root cause traced to code. Cite file:line. The actual mechanism, not a guess.

## Constraints
What must not change. APIs, data shapes, perf budgets, callers, on-disk formats. Bullets.

## Affected surface
Files (across all repos) the change will likely touch. Paths relative to the
current workspace (e.g. `editing-trainer/src/foo.py` in a multi-repo parent, or `src/foo.py` in a single repo). Bullets.

## Edge cases
Cases the solution must not break. Concrete inputs/states, not "handles errors".

## Open questions
Numbered, short, answerable in 1–2 sentences. Anything you need before planning.
If none: "None — ready to plan."
```

Rules:
- ≤1 page rendered. Bullets > prose.
- File:line over English descriptions of code.
- Stay **descriptive**. No "we should", "the fix is", "let's add". No solution language.
- Tiny ASCII diagram only if structure is non-trivial.

## Step 5 — Hand back

After the bulleted output, end with one short line:

> Task `<slug>` started. Open questions: \<N\>. Answer them in chat, then run one of:
> `/draft patch` · `/draft clean` · `/draft refactor`
> (`<slug>` is now the current flow task for this terminal/session context; explicit `/draft <slug> patch` still works.)

Stop. Do not start planning.

## Forbidden

- Proposing solutions, fixes, or approaches anywhere
- Writing any file (PROBLEM stays in chat; only `~/.flow/<slug>/` and `~/.flow/current/<context-key>` are created)
- Editing application code
- Walls of text — bullets only
- Running `/draft` on the user's behalf
