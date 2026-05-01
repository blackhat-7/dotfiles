---
name: understand
description: Read code in the Editing work folder, ask sharp questions, and output a short bulleted PROBLEM summary in chat. Do not propose solutions or write a plan. No file is written; output stays in chat.
---

# /understand

Deeply understand a problem before any code or plan exists. Output is bullets in chat — **no file is written**. You **do not** propose solutions, suggest approaches, or sketch fixes.

Only runs inside `~/Documents/Work/Editing/`. If cwd is elsewhere, say so and stop.

## Step 1 — One question first

If the user's invoking message already states clearly what's broken / what's needed, skip this. Otherwise ask, with no preamble:

> One-line description: what's broken or what needs to be added?

Wait for the answer. No tool calls yet.

## Step 2 — Read the code

Read aggressively. Do **not** guess.

- Bug: trace symptom to code, find where it actually originates.
- Feature: find the seams it would attach to; understand the surrounding contracts.
- Multi-repo: search across `editing-preprocesser`, `editing-trainer`, `editing-ml`, `aftershoot-cloud`, plus `-2`/`-3` clones.

One short sentence at the start ("reading X to find Y") and a brief signal when you find the relevant code. Don't narrate every file.

## Step 3 — Output PROBLEM in chat

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

## Step 4 — Hand back

After the bulleted output, end with one short line:

> Open questions: \<N\>. Answer them in chat, then run one of:
> `/draft patch` · `/draft clean` · `/draft refactor`

Stop. Do not start planning.

## Forbidden

- Proposing solutions, fixes, or approaches anywhere
- Writing any file (PROBLEM stays in chat)
- Editing application code
- Walls of text — bullets only
- Running `/draft` on the user's behalf
