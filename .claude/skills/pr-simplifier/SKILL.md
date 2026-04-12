---
name: pr-simplifier
description: Simplify a code change so the diff is smaller, clearer, and easier to review. Use when cleaning up a patch, reducing review noise, removing overengineering, or making code easier to merge without changing behavior. Trigger on requests like "simplify this diff," "clean up this PR," "make this more minimal," or "reduce churn," especially for Python and Go changes.
---

# PR Simplifier

Make the smallest correct change. LLMs often overbuild, over-refactor, and apply generic best practices too aggressively. Optimize for reviewability, local consistency, and low-risk diffs.

## 1. Understand First

- Read the current code and the actual request before changing anything.
- If the goal is ambiguous, ask one short question or state the assumption.
- Prefer preserving behavior unless the task explicitly changes it.

## 2. Shrink the Diff

- Touch only code required for the task.
- Reuse existing helpers and patterns before adding new ones.
- Do not add abstractions, config, interfaces, helpers, or dependencies without immediate payoff.
- Do not split one clear function into several unless reuse or clarity clearly improves.
- Remove only code made unnecessary by your own edit.

## 3. Match the Repo

- Follow local naming, structure, and error-handling style.
- Prefer the codebase's existing patterns over textbook best practices.
- Do not opportunistically rename, reformat, or refactor adjacent code.

## 4. Review by Risk

- Prioritize correctness, regressions, edge cases, API changes, and missing verification.
- Treat style suggestions as optional unless they materially improve clarity.
- If code is already clear and correct, leave it alone.

## 5. Verify

- Run the smallest relevant checks available.
- Say exactly what changed, what was verified, and what remains unverified.

## Review Output

- Lead with must-fix issues.
- Put optional simplifications after that.
- If no material issues remain, say so plainly.
