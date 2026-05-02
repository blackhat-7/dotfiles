---
name: audit
description: Run an independent fresh-context review of the named task. Spawns the reviewer subagent with ~/.flow/<slug>/PLAN.md and the actual git diffs from touched repos. Reviewer writes ~/.flow/<slug>/REVIEW.md. Argument is the task slug. Run after /build.
argument-hint: <task-slug>
---

# /audit

Run an **independent** review for the named task. The review runs in a fresh-context subagent with no memory of the build — it sees only the plan and the actual diff. Catches drift between PLAN and reality, bloat, missed edge cases, and bugs.

Runs from any cwd. Resolves repo paths relative to the task root saved in `~/.flow/<slug>/ROOT`.

## Step 0 — Validate slug

Slug: `$ARGUMENTS`. Must match `[a-z0-9][a-z0-9-]*`. If empty or invalid, reply:

> Usage: `/audit <task-slug>` (e.g. `/audit fix-jpeg-corrupt`).

Then stop.

## Step 1 — Locate the plan

```bash
SLUG="$ARGUMENTS"
DIR="$HOME/.flow/$SLUG"
PLAN="$DIR/PLAN.md"
ROOT=$(cat "$DIR/ROOT" 2>/dev/null) || ROOT="$(pwd)"
[[ -f "$PLAN" ]] && echo "OK root=$ROOT" || echo "MISSING"
```

If `MISSING`: tell user no plan for slug `<slug>` — run `/draft <slug> <mode>` and `/build <slug>` first. Stop.

## Step 2 — Identify touched repos

Read `~/.flow/<slug>/PLAN.md`'s `## Changes` section. Extract unique first path components. For each component, if `$ROOT/<component>/.git` exists, it's a repo to diff. If no components are git repos (single-repo task), the repo to diff is `$ROOT` itself.

If you can't determine paths from the plan (no file:line refs in `## Changes`), tell the user the plan is too vague and stop.

## Step 3 — Capture diffs

For each repo dir resolved above, in chat output one line then run:

```bash
cd "$REPO_DIR"
git status --porcelain
git diff --stat HEAD
```

If a repo has uncommitted changes that aren't in PLAN.md (e.g., unrelated WIP), flag it and ask the user to confirm those are part of this task before proceeding.

If `git diff HEAD` is empty everywhere — likely the build was already committed. Tell the user to either run `/audit` before committing next time, or to specify the base ref.

## Step 4 — Dispatch the reviewer subagent

Spawn the `reviewer` subagent (foreground) with this prompt. Do not paste diff contents — the subagent will read fresh from disk and from `git diff` itself.

```
Audit a flow task against its plan. You have NO prior context.

Task slug: <slug>
Plan: ~/.flow/<slug>/PLAN.md
Task root: <ROOT>   (paths in PLAN's ## Changes are relative to this)
Touched repos (run `git diff HEAD` in each — absolute paths):
  - <abs path repo1>
  - <abs path repo2>
  ...

The user values: minimal code, 100% correctness, no out-of-scope changes,
no defensive code, no "while I'm here" cleanup, no comments explaining
what code does. Plan-build trace is the contract.

Be skeptical. Be specific. Cite file:line.

Output to ~/.flow/<slug>/REVIEW.md using the format in your agent
definition. End your reply with one line:
"REVIEW.md written. Verdict: <SHIP | NEEDS-FIXES | RE-PLAN>."
```

Use `subagent_type: "reviewer"`.

## Step 5 — Surface the verdict

Read `.flow/<slug>/REVIEW.md`. Output **only**:

> Audit complete for `<slug>`. Verdict: \<SHIP | NEEDS-FIXES | RE-PLAN\>.
> Findings: drift \<N\>, bugs \<N\>, bloat \<N\>, missing \<N\>.
> See `~/.flow/<slug>/REVIEW.md` for details.
>
> Next:
> - SHIP → run `/explain <slug>` to write the 1-page summary.
> - NEEDS-FIXES → fix the listed items, re-run `/audit <slug>`.
> - RE-PLAN → revise via `/draft <slug> <mode>`.

Do **not** start fixing things yourself. Do not run `/explain` or `/build`.

## Forbidden

- Doing the review yourself instead of dispatching the subagent — fresh context is the point.
- Pasting diff or plan contents into chat — they're on disk.
- Fixing issues found by the audit — that's a separate pass after the user reviews.
- Running this without `~/.flow/<slug>/PLAN.md` — there's no contract to audit against.
