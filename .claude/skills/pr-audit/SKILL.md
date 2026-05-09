---
name: pr-audit
description: >-
  Run an independent audit of a pull request or current branch. Use whenever the
  user asks to review, audit, sanity-check, or verify someone else's PR/current
  branch/branch diff. Defaults to using the PR
  description as the plan/contract unless the user provides another plan
  doc/text, and defaults to diffing the current branch against the PR base or
  first available master/main/prod branch unless the user provides a base ref or
  diff range. Preserves the strict audit analysis: drift, bugs, bloat, missing
  work, and SHIP / NEEDS-FIXES / RE-PLAN verdicts.
argument-hint: "[PR URL|number|plan path|base ref|diff range]"
---

# /pr-audit

Run an independent review of a PR/current branch against its stated intent. It works from normal checked-out repos and treats the PR description, or another user-provided plan, as the review contract.

Default contract: the PR title/body.
Default diff: current branch compared to the PR base, or to the first available `master`, `main`, then `prod` branch.

## Step 0 — Parse the request

Arguments are freeform. Detect, in priority order:

- **Plan override**: a path, pasted text, issue/spec doc, or phrase like `use docs/foo.md as the plan`.
- **Diff override**: an explicit range like `origin/main...HEAD`, `abc123..def456`, or a phrase like `diff against staging`.
- **PR selector**: a PR URL, `#123`, or PR number.
- **Output override**: a phrase like `write review to /tmp/review.md`.

If the user supplies both a PR selector and explicit plan/diff overrides, use the explicit overrides for the parts they mention and PR metadata for the rest.

## Step 1 — Locate the repo

Run from the repo/workspace containing the PR branch unless the user gives another path.

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || echo NO_REPO
```

If `NO_REPO`, ask the user to run this from a checked-out repo or provide the repo path. Do not clone or checkout unknown code unless the user explicitly asks.

Set:

```bash
cd "$ROOT"
REPO_NAME=$(basename "$ROOT")
BRANCH=$(git branch --show-current 2>/dev/null | tr '/ ' '--')
RUN_ID="$(date +%Y%m%d-%H%M%S)-${BRANCH:-detached}"
OUT_DIR="${PR_AUDIT_OUT_DIR:-$HOME/.pr-audit/$REPO_NAME/$RUN_ID}"
mkdir -p "$OUT_DIR"
PLAN="$OUT_DIR/PR_DESCRIPTION.md"
REVIEW="$OUT_DIR/REVIEW.md"
```

If the user gave an output path, set `REVIEW` to that path and create its parent directory.

## Step 2 — Resolve the plan/contract

Use the first available source:

1. **Explicit user-provided plan** — path/text/spec/issue mentioned by the user. Copy or save it to `$PLAN` and record the original source.
2. **PR description from an explicit PR selector** — use GitHub CLI if available:
   ```bash
   gh pr view <PR_URL_OR_NUMBER> --json title,body,baseRefName,headRefName,url,number
   ```
3. **PR description for the current branch** — if no PR selector was supplied:
   ```bash
   gh pr view --json title,body,baseRefName,headRefName,url,number
   ```

Save PR title/body as:

```markdown
# PR: <title>

URL: <url if known>
Number: <number if known>
Base: <baseRefName if known>
Head: <headRefName if known>

## Description
<body>
```

If `gh` is unavailable or no PR is associated with the branch, ask the user to paste the PR description or provide a plan path. Do not invent a plan from commit messages.

If the PR body is empty or template-only, continue using the title/body but note in the review that the contract is weak; do not treat unrelated hunks as acceptable just because the description is vague.

## Step 3 — Resolve the diff

Use the first available source:

1. **Explicit diff range from the user** — use it exactly, e.g. `git diff <range>`.
2. **Explicit base ref from the user** — compare with `HEAD` using triple-dot: `git diff <base>...HEAD`.
3. **PR base ref from Step 2** — prefer `origin/<baseRefName>` when it exists, otherwise `<baseRefName>`.
4. **Default base branch** — first ref that exists, in this order: `origin/master`, `master`, `origin/main`, `main`, `origin/prod`, `prod`.

Useful detection:

```bash
for b in master main prod; do
  if git rev-parse --verify --quiet "origin/$b" >/dev/null; then echo "origin/$b"; break; fi
  if git rev-parse --verify --quiet "$b" >/dev/null; then echo "$b"; break; fi
done
```

If no base/range can be resolved, ask the user for one.

Default diff commands:

```bash
git status --porcelain
git diff --stat <BASE_OR_RANGE>...HEAD   # omit ...HEAD if an explicit full range was supplied
git diff --name-status <BASE_OR_RANGE>...HEAD
git diff <BASE_OR_RANGE>...HEAD
```

Use triple-dot for branch/base comparisons because it matches normal PR semantics: changes introduced by this branch since the merge-base with the base branch.

If `git status --porcelain` shows uncommitted local changes, stop and ask unless the user explicitly said to include local WIP. A PR audit should not silently mix someone else's PR with local edits. If the user confirms inclusion, review committed PR diff plus `git diff` and `git diff --cached`, and clearly mark local WIP in `## Mode-specific`.

If the diff is empty, tell the user the selected base/range produced no changes and ask for the intended base/range.

## Step 4 — Review dispatch

Use the strongest available review path:

1. **Reviewer subagent available**: dispatch a fresh-context reviewer/subagent in foreground with the prompt below.
2. **Generic subagent available**: dispatch a fresh-context code-review subagent with the same prompt.
3. **No usable subagent**: perform the review inline using the same procedure and output format below. Note in `## Mode-specific` that the review was inline, not fresh-context.

Do not paste full diffs into chat. The reviewer reads from disk and runs `git diff` itself.

Prompt for subagent paths:

```text
Audit a PR/current branch against its stated plan. You have NO prior context.

Plan/contract: <absolute path to $PLAN>
Plan source: <PR URL | explicit file | pasted text | other>
Repo root: <absolute path to repo>
Diff command to review: <exact git diff command/range>
Status command: git status --porcelain
Output file: <absolute path to $REVIEW>

The user values: minimal code, 100% correctness, no out-of-scope changes,
no defensive code, no "while I'm here" cleanup, no comments explaining
what code does. The PR description/plan to diff trace is the contract.

Be skeptical. Be specific. Cite file:line.

Write the review to the output file using the required format below. End your reply with one line:
"REVIEW.md written. Verdict: <SHIP | NEEDS-FIXES | RE-PLAN>."
```

## Reviewer procedure and output format

Whether subagent or inline:

1. Read the plan/contract fully.
2. Run `git status --porcelain` and the exact diff commands resolved in Step 3.
3. Read every diff hunk. Inspect surrounding code when needed to verify behavior.
4. Cross-check:
   - Every meaningful diff hunk maps to the PR description/plan; untraceable hunks are bloat.
   - Every concrete promise in the PR description/plan has a matching hunk; missing hunks are missing work.
   - Every claimed edge case, migration, test, metric, compatibility note, or rollout step is supported by real changed lines or explicitly documented non-code work.
   - Surrounding code has no logic errors, missed cases, type/contract mismatches, races, broken file formats, config mistakes, generated-file mistakes, or test gaps that would make the PR unsafe.
   - Diff size, new files, and abstraction choices are justified by the stated PR scope.

Write `$REVIEW` with exactly:

```markdown
# PR Audit: <repo or PR identifier>

Plan source: <PR URL | plan path | pasted text>
Diff: <exact base/range reviewed>
Repo: <repo path>

## Plan-build drift
Concrete deviations between the PR description/plan and the diff. For each: plan reference, diff reference, what differs, severity (blocker / minor).
Or: "None."

## Bugs
Logic errors, missed edge cases, off-by-one, races, type/contract mismatches, broken config/file formats, or test failures likely from the diff.
For each: file:line, what's wrong, what would happen at runtime.
Or: "None."

## Bloat
Diff hunks that do not trace to the PR description/plan, are unrelated cleanup, add unnecessary abstraction, or violate minimal-review discipline.
For each: file:line, why it shouldn't be there, suggested removal.
Or: "None."

## Missing
PR description/plan promises with no matching diff, claimed tests/edge cases not supported, or important coverage absent for the stated change.
For each: plan reference, what's missing, what should exist.
Or: "None."

## Mode-specific
If the plan declares patch/clean/refactor or other constraints, check them here. Otherwise state: "No explicit review mode declared; applied default PR discipline (minimal scope, justified files, no unrelated churn)."
Mention inline review here if no subagent was used.
Mention any included local WIP here.
Or: "None."

## Verdict
One of: SHIP / NEEDS-FIXES / RE-PLAN

One sentence why.
```

Verdicts:

- `SHIP` — no blockers. Minor findings can be left or fixed before merge.
- `NEEDS-FIXES` — bugs, drift, missing promised work, or bloat that must be fixed; the stated plan is basically right, the implementation is wrong.
- `RE-PLAN` — the implementation may be faithful, but the PR description/plan is too vague/wrong for the change, the architecture is wrong, or the chosen approach does not solve the real problem.

## Step 5 — Surface the verdict

Read `$REVIEW`. Output **only**:

> PR audit complete. Verdict: <SHIP | NEEDS-FIXES | RE-PLAN>.
> Findings: drift <N>, bugs <N>, bloat <N>, missing <N>.
> See `<path to REVIEW>` for details.

Do **not** start fixing issues yourself. Do not rewrite the PR. Do not paste the full diff into chat.

## Forbidden

- Fixing issues found by the audit unless the user starts a separate fix pass.
- Reviewing without a plan/contract; if the PR description cannot be found, ask for it.
- Silently using the wrong branch/base when the user gave a PR selector.
- Silently including uncommitted local WIP in someone else's PR review.
- Pasting full diffs into chat.
