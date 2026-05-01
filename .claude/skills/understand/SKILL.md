---
name: understand
description: Start a flow task by reading code, asking sharp questions, and outputting a bulleted PROBLEM summary in chat. Argument is a kebab-case task slug (e.g. fix-jpeg-corrupt). Creates .flow/<slug>/ as the task directory. PROBLEM stays in chat — no file is written.
argument-hint: <task-slug>
---

# /understand

Start a flow task. Deeply understand the problem before any code or plan exists. Output is bullets in chat — **no PROBLEM.md file is written**. You **do not** propose solutions, suggest approaches, or sketch fixes.

Only runs inside `~/Documents/Work/Editing/`. If cwd is elsewhere, say so and stop.

## Step 0 — Validate slug

Slug: `$ARGUMENTS`

Must match `[a-z0-9][a-z0-9-]*` (kebab-case, no spaces, no slashes, no uppercase). If empty or invalid, reply:

> Task slug required. Usage: `/understand <kebab-case-slug>` (e.g. `/understand fix-jpeg-corrupt`).

Then stop.

## Step 1 — Set up task directory

```bash
SLUG="$ARGUMENTS"
DIR="$HOME/Documents/Work/Editing/.flow/$SLUG"
mkdir -p "$DIR"
[[ -f "$DIR/PLAN.md" ]] && echo "EXISTS_WITH_PLAN" || echo "OK"
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
- Multi-repo: search across `editing-preprocesser`, `editing-trainer`, `editing-ml`, `aftershoot-cloud`, plus `-2`/`-3` clones.

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
Files (across all repos) the change will likely touch. Full paths from the work
folder (e.g. editing-trainer/src/foo.py). Bullets.

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
> `/draft <slug> patch` · `/draft <slug> clean` · `/draft <slug> refactor`

Stop. Do not start planning.

## Forbidden

- Proposing solutions, fixes, or approaches anywhere
- Writing any file (PROBLEM stays in chat; only the empty `.flow/<slug>/` dir is created)
- Editing application code
- Walls of text — bullets only
- Running `/draft` on the user's behalf
