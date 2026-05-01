---
name: audit
description: Run an independent fresh-context review. Spawns the reviewer subagent with .flow/PLAN.md and the actual git diffs from touched repos. Reports verdict in chat. Run after /build.
---

# /audit

Run an **independent** review. The review runs in a fresh-context subagent with no memory of the build — it sees only the plan and the actual diff. Catches drift between PLAN and reality, bloat, missed edge cases, and bugs.

Only runs inside `~/Documents/Work/Editing/`. If cwd is elsewhere, say so and stop.

## Step 1 — Locate the plan

```bash
PLAN="$HOME/Documents/Work/Editing/.flow/PLAN.md"
[[ -f "$PLAN" ]] && echo "OK" || echo "MISSING"
```

If `MISSING`: tell user to run `/draft` and `/build` first. Stop.

## Step 2 — Identify touched repos

Read `.flow/PLAN.md`'s `## Changes` section. Extract the repo (first path component) for each file path. Dedupe. The result is the list of repos to diff.

If you can't determine repos from the plan (no file:line refs in `## Changes`), tell the user the plan is too vague and stop.

## Step 3 — Capture diffs

For each repo, in chat output one line then run:

```bash
cd "$HOME/Documents/Work/Editing/<repo>"
git status --porcelain
git diff --stat HEAD
```

If a repo has uncommitted changes that aren't in PLAN.md (e.g., unrelated WIP), flag it and ask the user to confirm those are part of this task before proceeding.

If `git diff HEAD` is empty everywhere — likely the build was already committed. Tell the user to either run `/audit` before committing next time, or to specify the base ref.

## Step 4 — Dispatch the reviewer subagent

Spawn the `reviewer` subagent (foreground) with this prompt. Do not paste diff contents — the subagent will read fresh from disk and from `git diff` itself.

```
Audit a flow task against its plan. You have NO prior context.

Plan: ~/Documents/Work/Editing/.flow/PLAN.md
Touched repos (run `git diff HEAD` in each):
  - <repo1>
  - <repo2>
  ...

The user values: minimal code, 100% correctness, no out-of-scope changes,
no defensive code, no "while I'm here" cleanup, no comments explaining
what code does. Plan-build trace is the contract.

Be skeptical. Be specific. Cite file:line.

Output to ~/Documents/Work/Editing/.flow/REVIEW.md using the format in
your agent definition. End your reply with one line:
"REVIEW.md written. Verdict: <SHIP | NEEDS-FIXES | RE-PLAN>."
```

Use `subagent_type: "reviewer"`.

## Step 5 — Surface the verdict

Read `.flow/REVIEW.md`. Output **only**:

> Audit complete. Verdict: \<SHIP | NEEDS-FIXES | RE-PLAN\>.
> Findings: drift \<N\>, bugs \<N\>, bloat \<N\>, missing \<N\>.
> See `.flow/REVIEW.md` for details.
>
> Next:
> - SHIP → run `/explain` to write the 1-page summary.
> - NEEDS-FIXES → fix the listed items, re-run `/audit`.
> - RE-PLAN → revise via `/draft <mode>`.

Do **not** start fixing things yourself. Do not run `/explain` or `/build`.

## Forbidden

- Doing the review yourself instead of dispatching the subagent — fresh context is the point.
- Pasting diff or plan contents into chat — they're on disk.
- Fixing issues found by the audit — that's a separate pass after the user reviews.
- Running this without `.flow/PLAN.md` — there's no contract to audit against.
