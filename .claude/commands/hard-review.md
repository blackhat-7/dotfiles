---
description: Deep multi-angle code review using parallel subagents. Every changed file, every changed line.
disable-model-invocation: true
allowed-tools: Bash(git *) Bash(gh *)
---

# Hard Review

This is a HARD review. Not a quick skim — a line-by-line, file-by-file audit of every change. This review matters because these changes ship to production and affect real users. A lazy review that misses bugs is worse than no review at all.

## Setup

Determine what to review:
- If `$ARGUMENTS` contains a PR number or URL, use `gh pr view` for description and `gh pr diff` for the diff
- Otherwise, diff the current branch against the base branch: `git diff origin/HEAD...`

Collect before spawning agents:
1. The full diff
2. List of changed files (`--name-only`)
3. Commit messages (`git log --no-decorate origin/HEAD...`)
4. PR description if applicable

## Parallel Review Agents

Spawn all three agents in parallel using the Agent tool. Each agent receives the full diff, changed file list, and commit messages in its prompt.

CRITICAL INSTRUCTIONS FOR ALL AGENTS:
- You MUST read every changed file in full using the Read tool — not just the diff hunks. You need surrounding context to understand what the code does.
- You MUST review EVERY file in the changed files list. Do not skip any file. Do not sample. Go through them one by one.
- For large changes, work through files systematically. Do not stop early because you found "enough" issues.
- A 2000-line change should produce dozens of findings, not 5. If you only found a few things, you haven't looked hard enough — go back and look again.
- After your first pass, do a SECOND pass specifically looking for things you missed. Ask yourself: "what would a senior engineer at a top company catch that I didn't?"
- Your output should be a COMPLETE list of every issue you found, no matter how many. Do not truncate, summarize, or "keep it brief". This is a hard review — completeness is the point.
- Think about what the code is supposed to do. Then think about how it could fail. Then check if it handles those failures.

ultrathink

### Agent 1: Logic & Correctness

You are a senior engineer doing a deep logic review. Your job is to find every bug, every missed edge case, every incorrect assumption. You are the last line of defense before this code ships to production.

**Process — follow this exactly:**

1. Read the PR description and commit messages to understand intent
2. For EACH changed file:
   a. Read the full file (not just the diff)
   b. Understand what the changed code is supposed to do
   c. Trace every code path through the changed lines — happy path, error paths, edge cases
   d. Check every conditional: is the logic correct? Are all branches handled?
   e. Check every loop: correct bounds? Can it infinite-loop? Off-by-one?
   f. Check every function call: correct arguments? Return value handled? Can it throw/panic?
   g. Check error handling: does it catch the right errors? Does it handle them correctly or just swallow them?
   h. List your findings for this file before moving to the next
3. After reviewing all files, do a cross-file pass: do the changes across files work together correctly? Are there ordering dependencies, shared state issues, or integration bugs?

**What to look for:**
- Off-by-one errors, incorrect boolean logic, missing early returns
- Swallowed errors, incorrect error types, missing error propagation
- Nil/null dereferences, uninitialized variables, use-before-check
- Race conditions: shared state without locks, concurrent map access, goroutine leaks
- Missing input validation at boundaries
- Implicit assumptions not enforced (expecting sorted input, assuming non-empty, assuming unique)
- Tests that don't actually test behavior — tests that would pass even if the code was broken
- Missing test cases for edge cases and error paths
- Resource leaks: unclosed files, connections, channels

**Output format — for EACH finding:**
```
**[file:line]** severity: HIGH|MEDIUM|LOW
description of the bug or risk
what could go wrong: concrete scenario
suggested fix (if obvious)
```

### Agent 2: Code Quality & Craft

You are a meticulous code quality reviewer. Your job is to ensure every line of new code is clean, idiomatic, and maintainable. Go through every changed file line by line.

**Process — follow this exactly:**

1. For EACH changed file:
   a. Read the full file to understand the existing style and patterns
   b. Read at least 2-3 neighboring files in the same directory to understand local conventions
   c. Go through every changed line and check against the criteria below
   d. List your findings for this file before moving to the next
2. After all files, check for cross-file consistency issues

**What to look for — check EVERY one of these for EVERY changed file:**

- **Types**: Missing type annotations on any function signature. Use of `Any`/`any`/`interface{}`. Missing return types. Overly broad generics. Missing type narrowing after checks.
- **Naming**: Variables/functions that don't describe what they do. Abbreviations that aren't obvious. Inconsistent naming within the PR. Names that conflict with the codebase's conventions.
- **Dead code**: Unused imports, unreachable branches, variables assigned but never read, commented-out code, leftover debug prints/logs.
- **Complexity**: Functions over 40 lines. Nesting deeper than 3 levels. Complex conditionals that should be extracted into named booleans. Long parameter lists (>4 params).
- **Duplication**: Copy-pasted logic within the PR. Logic that duplicates existing utilities in the codebase (search for them).
- **Idioms**: Non-idiomatic patterns for the language. Verbose code where a built-in or standard library function exists. Manual loops where map/filter/comprehension would be clearer.
- **Error messages**: Errors without context. Generic error strings. Missing error wrapping.
- **Constants**: Magic numbers or repeated string literals that should be named constants.
- **Comments**: Comments that describe what the code does (unnecessary) vs why (useful). Outdated comments that don't match the code.
- **Consistency**: Does new code follow the same patterns as the rest of the codebase? Different error handling style? Different import ordering? Different module structure?

**Output format — for EACH finding:**
```
**[file:line]** category: TYPES|NAMING|DEAD_CODE|COMPLEXITY|DUPLICATION|IDIOMS|ERRORS|CONSTANTS|COMMENTS|CONSISTENCY
what's wrong
suggested fix (with code snippet if helpful)
```

### Agent 3: Architecture & Design

You are a staff engineer reviewing this change for long-term health of the system. Read every changed file AND the modules they touch to understand the architectural impact.

**Process — follow this exactly:**

1. Read all changed files in full
2. For each changed file, read the other files in the same package/module to understand the existing architecture
3. Trace the dependency graph: what does this change import? What imports it? Are new dependencies appropriate?
4. Understand the data flow: where does data come from, how does it transform, where does it go?
5. Evaluate the design decisions against the existing system architecture

**What to look for — check EVERY one of these:**

- **Placement**: Does code live in the right module/layer? Is business logic leaking into handlers/controllers? Is data access logic outside the data layer? Would this confuse a new team member about where things belong?
- **Coupling**: New imports across module boundaries. Shared mutable state. Tight coupling between components that should be independent. God objects that know too much.
- **Abstraction level**: Are new abstractions justified by real reuse? Are there missing abstractions where copy-paste is happening? Is there over-abstraction making simple things complex?
- **API design**: Are new functions/methods/endpoints well-named and minimal? Are they consistent with existing APIs? Are they easy to use correctly and hard to use incorrectly?
- **Data modeling**: Are data structures appropriate? Missing validation at boundaries? Stringly-typed data that should be structured? Mutable data that should be immutable?
- **Performance**: N+1 queries. Unbounded loops or collections. Missing pagination. Large in-memory aggregations. Blocking calls in async contexts. Missing caching where appropriate. Unnecessary allocations in hot paths.
- **Security**: SQL/command/template injection. Auth bypasses. Data exposure in logs/errors/responses. Secrets in code. Unsafe deserialization. SSRF. Path traversal. Only flag concrete exploitable issues.
- **Error architecture**: Is the error strategy consistent? Are errors recoverable where they should be? Is there appropriate retry/fallback logic? Are failures observable (logged, metriced)?
- **Tech debt**: Does this change make future changes harder? Does it paint the codebase into a corner? Does it make existing debt worse? Is it taking a shortcut that will need to be undone?
- **Observability**: For significant changes — is there logging, metrics, or tracing to understand behavior in production?

**Output format — for EACH finding:**
```
**[affected components]** severity: HIGH|MEDIUM|LOW
category: PLACEMENT|COUPLING|ABSTRACTION|API|DATA|PERFORMANCE|SECURITY|ERRORS|DEBT|OBSERVABILITY
what's wrong and why it matters long-term
suggested alternative approach
```

## Synthesis

After all three agents return, combine their findings into a single structured review.

IMPORTANT: Do NOT summarize or condense the agents' findings. Include EVERY finding from every agent. The whole point of a hard review is completeness. A long review with 30+ comments on a 2000-line change is expected and correct.

```
## Hard Review Summary

**Verdict**: [APPROVE | REQUEST CHANGES | NEEDS DISCUSSION]
**Risk**: [LOW | MEDIUM | HIGH]
**Stats**: X files reviewed, Y total findings (Z critical, W warnings, V suggestions)

### Critical (must fix before merge)
- [file:line] description ...

### Warnings (should fix)
- [file:line] description ...

### Suggestions (optional improvements)
- [file:line] description ...

### What's Good
- brief notes only if genuinely noteworthy
```

Synthesis rules:
- Include ALL findings from all agents. Do not drop findings to "keep it short"
- Deduplicate only exact duplicates — same file, same line, same issue. Similar findings in different files are NOT duplicates
- Rank by severity: correctness bugs > security > design flaws > quality > style
- Any correctness bug or concrete security issue = REQUEST CHANGES
- Design-only concerns with no correctness risk = NEEDS DISCUSSION
- Be specific: always include file path and line number
- If an agent returned suspiciously few findings for the size of the change, note this in the summary
