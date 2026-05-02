---
name: audit
description: Run an independent review of the named flow task. Reviews ~/.flow/<slug>/PLAN.md against actual git diffs from touched repos and writes ~/.flow/<slug>/REVIEW.md. Uses reviewer subagent when available in Claude Code/opencode; falls back to inline review in Pi or harnesses without subagents. Optional argument is the task slug; if omitted, use the current flow task for this terminal/session context. Run after /build.
argument-hint: "[task-slug]"
---

# /audit

Run an independent review for the named task. The review sees only the plan and the actual diff. Catches drift between PLAN and reality, bloat, missed edge cases, and bugs.

Run from the repo/workspace root used for `/draft` and `/build`.

## Step 0 — Validate slug

Slug: `$ARGUMENTS`. If empty, resolve slug from the current-flow file for this terminal/session context: `$HOME/.flow/current/<context-key>`. Must match `[a-z0-9][a-z0-9-]*`. If missing or invalid, reply:

> Usage: `/audit [task-slug]` (e.g. `/audit` or `/audit fix-jpeg-corrupt`).

Then stop.

## Step 1 — Locate the plan

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
PLAN="$DIR/PLAN.md"
ROOT="$(pwd)"
[[ -f "$PLAN" ]] && { mkdir -p "$(dirname "$CURRENT_FILE")"; printf '%s\n' "$SLUG" > "$CURRENT_FILE"; echo "OK root=$ROOT"; } || echo "MISSING from_current=$FROM_CURRENT"
```

If `BAD_ARGS`: show the usage from Step 0. Stop.
If `MISSING from_current=1`: tell user no current flow plan exists for this terminal/session context — run `/draft <slug> <mode>` and `/build <slug>` first or pass a slug. Stop.
If `MISSING from_current=0`: tell user no plan for slug `<slug>` — run `/draft <slug> <mode>` and `/build <slug>` first. Stop.

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

## Step 4 — Review dispatch

Use the strongest available review path:

1. **Claude Code**: spawn the `reviewer` subagent in foreground with the prompt below. Use `subagent_type: "reviewer"`.
2. **opencode with reviewer agent/subagent available**: dispatch the generated `reviewer` subagent with the same prompt.
3. **Pi or no usable subagent**: perform the review inline using the same procedure and output format below. Note in `REVIEW.md` under `## Mode-specific` that the review was inline, not fresh-context.

Do not paste diff contents into chat. The reviewer path reads from disk and from `git diff` itself.

Prompt for subagent paths:

```
Audit a flow task against its plan. You have NO prior context.

Task slug: <slug>
Plan: ~/.flow/<slug>/PLAN.md
Task root: <ROOT>   (current cwd; paths in PLAN's ## Changes are relative to this)
Touched repos (run `git diff HEAD` in each — absolute paths):
  - <abs path repo1>
  - <abs path repo2>
  ...

The user values: minimal code, 100% correctness, no out-of-scope changes,
no defensive code, no "while I'm here" cleanup, no comments explaining
what code does. Plan-build trace is the contract.

Be skeptical. Be specific. Cite file:line.

Output to ~/.flow/<slug>/REVIEW.md using the format below. End your reply with one line:
"REVIEW.md written. Verdict: <SHIP | NEEDS-FIXES | RE-PLAN>."
```

## Reviewer procedure and output format

Whether subagent or inline:

1. Read PLAN.md fully.
2. Run `git diff HEAD` in each touched repo and read every hunk.
3. Cross-check:
   - Every diff hunk maps to a PLAN line; untraceable hunks are bloat.
   - Every PLAN `## Changes` line has a matching hunk; missing hunks are missing work.
   - Every PLAN `## Edge cases verified` item is supported by real changed lines.
   - Surrounding code has no logic errors, missed cases, type/contract mismatches, races, broken file formats, or bad generated config.
   - Mode budget and new-file rules are satisfied.

Write `~/.flow/<slug>/REVIEW.md` with exactly:

```markdown
# Audit: <slug>

Mode: <patch | clean | refactor>
Repos: <repo1>, <repo2>, ...

## Plan-build drift
Concrete deviations between PLAN.md and the diff. For each: PLAN reference, diff reference, what differs, severity (blocker / minor).
Or: "None."

## Bugs
Logic errors, missed edge cases, off-by-one, races, type/contract mismatches.
For each: file:line, what's wrong, what would happen at runtime.
Or: "None."

## Bloat
Diff hunks that don't trace to a PLAN line, OR violate the rules.
For each: file:line, why it shouldn't be there, suggested removal.
Or: "None."

## Missing
PLAN.md `## Changes` lines with no corresponding diff. PLAN edge cases not handled in the diff.
For each: PLAN reference, what's missing, what should exist.
Or: "None."

## Mode-specific
patch: actual diff size vs ≤100; new files (must be 0).
clean: diff size vs ≤300; new files (≤1, net-negative); is the result actually simpler than before?
refactor: each new file justified (why exists / what considered / why won)? architecture matches diff? migration plan present?
Mention "inline review" here if no subagent was used.
Or: "None."

## Verdict
One of: SHIP / NEEDS-FIXES / RE-PLAN

One sentence why.
```

Verdicts:
- `SHIP` — no blockers. Minor findings can be left or fixed before merge.
- `NEEDS-FIXES` — bugs, drift, or bloat that must be fixed; the plan is right, the build is wrong.
- `RE-PLAN` — the build is faithful but the plan itself doesn't solve the problem, or the architecture is wrong.

## Step 5 — Surface the verdict

Read `.flow/<slug>/REVIEW.md`. Output **only**:

> Audit complete for `<slug>`. Verdict: \<SHIP | NEEDS-FIXES | RE-PLAN\>.
> Findings: drift \<N\>, bugs \<N\>, bloat \<N\>, missing \<N\>.
> See `~/.flow/<slug>/REVIEW.md` for details.
>
> Next:
> - SHIP → run `/explain` to write the 1-page summary.
> - NEEDS-FIXES → fix the listed items, re-run `/audit`.
> - RE-PLAN → revise via `/draft <mode>` (or `/draft <slug> <mode>`).

Do **not** start fixing things yourself. Do not run `/explain` or `/build`.

## Forbidden

- Fixing issues found by the audit — that's a separate pass after the user reviews.
- Running this without `~/.flow/<slug>/PLAN.md` — there's no contract to audit against.
- Pasting full diffs into chat.
- In subagent-capable harnesses, doing inline review when a `reviewer` subagent is available.
