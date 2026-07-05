---
name: plan-review
description: Review/audit an implementation plan against a provided problem or requirements source. Use whenever the user gives or points to a problem statement, requirements doc, issue, PRD, bug report, design brief, pasted text, or Markdown file plus a plan/proposal/design and asks whether the plan is good, complete, minimal, solves all problems, meets all requirements, considers pros/cons/risks, or needs changes. Works with arbitrary file paths, URLs, or pasted text; ask for missing or ambiguous sources.
argument-hint: "<problem-source> <plan-source> [review-output-path]"
---

# /plan-review

Review a plan as a skeptical independent reviewer. A good plan solves the stated problem with the least necessary complexity and makes tradeoffs explicit.

## Step 0 — Inputs

Need two sources: **problem source** and **plan source**. If either is missing or ambiguous, ask for it and stop.

Sources may be file paths, URLs, or pasted text. Read both fully. If a source cannot be opened/read, stop and ask. If a review output path is provided, write the review there; otherwise answer in chat.

## Step 1 — Extract the contract

From the problem source, capture:
- requirements, non-goals, constraints, success criteria
- named problems/root causes to solve
- affected users/systems, edge cases, and compatibility needs

From the plan source, capture:
- proposed approach and concrete changes
- assumptions, dependencies, rollout/migration, validation
- alternatives considered and rejected

If the plan cites code/docs needed to verify feasibility, read only those. Do not drift into implementation.

## Step 2 — Review checklist

Check:
- **Coverage:** every explicit and implied requirement is addressed.
- **Correctness/feasibility:** the plan respects contracts, data shapes, sequencing, migrations, compatibility, and relevant perf/security/privacy constraints.
- **Simplicity/scope:** no unrelated cleanup, speculative abstraction, extra infrastructure, or defensive bloat.
- **Edge cases/failure modes:** partial states, bad inputs, concurrency, rollback/observability, and backwards compatibility where relevant.
- **Verification:** tests/manual checks map to requirements; no test theater.
- **Tradeoffs:** pros/cons are honest; alternatives are credible; rejected options have reasons.
- **Open questions:** missing info that blocks a safe build is surfaced clearly.

## Step 3 — Output

Keep it ≤1 page when possible. Cite problem/plan refs by file:line when available, otherwise by section/heading. Put blockers first. Do not rewrite the plan unless asked.

```markdown
# Plan Review

## Verdict
APPROVE | NEEDS-CHANGES | REWRITE — one sentence.

## Coverage
- Met: ...
- Missing/unclear: ...

## Correctness and feasibility
- ...

## Complexity and scope
- ...

## Pros / cons
- Pros: ...
- Cons: ...

## Risks and edge cases
- ...

## Required changes before build
1. [blocker] Problem ref → Plan ref → what must change.
If none: None.

## Open questions
Numbered. If none: None.
```

Verdicts:
- **APPROVE** — no blockers; only minor optional notes.
- **NEEDS-CHANGES** — plan shape is likely right, but missing/unclear/overbroad parts must be fixed before build.
- **REWRITE** — plan does not solve the problem, chooses the wrong shape, or adds unacceptable complexity/risk.

## Forbidden

- Approving with unresolved requirements or blockers.
- Inventing requirements not supported by the problem source; label such ideas optional.
- Expanding scope into implementation, code edits, or full design rewrite unless asked.
- Burying blockers in prose.
