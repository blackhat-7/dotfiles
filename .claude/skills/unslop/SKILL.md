---
name: unslop
description: Remove AI code slop and needless complexity from changed code in any language, without changing behavior. Use after an agent writes code, before merging, or when asked to "unslop", "deslop", "simplify", "clean up AI code", or make code look human-written. Targets pointless wrappers and tiny helpers, speculative abstractions, over-generic code, deep nesting, reimplemented helpers, defensive noise, swallowed errors, narrating comments, and fake tests.
---

# Unslop

Make the code look like a careful human on this team wrote it: fewer concepts, direct flow, nothing that exists "just in case". Behavior stays identical.

## Rules

1. **Scope is the diff.** Default target: `git diff $(git merge-base HEAD main)` plus uncommitted changes. Edit only changed code. Search the whole repo when checking for duplicates or usages.
2. **Behavior is fixed.** Same outputs, side effects, ordering, error types, and error timing. Tests pass unmodified.
3. **Tests are the oracle.** Run the relevant tests (plus build, lint, and typecheck) before and after. If there is no coverage, only make changes that are provably safe (deleting unused code, deleting comments, inlining pure wrappers). Report the rest.
4. **Behavior-risky fixes are reported, not applied.** Examples: narrowing a broad `except`/`catch`, or removing a fallback that some input could reach.
5. **Match the file, not your taste.** A pattern is slop when it is unusual for *this* codebase and has no reason to exist. Formatting is the linter's job.
6. **Understand first.** Before removing anything, know why it is there: callers, edge cases, `git blame`.

## What to remove

**Needless structure**
- **Pointless functions:** one- or two-line functions called once or twice that do not name a real concept, or that just forward to another call. Inline them.
- **Speculative abstraction:** an interface, base class, factory, registry, or strategy with a single implementation; generics or type parameters used with one type. Make it concrete.
- **Over-generic code:** options, flags, config fields, or parameters that no caller varies; "extensible" hooks with no user. Hard-code the one used case.
- **Deep nesting (3+ levels):** flatten with guard clauses and early returns or `continue`.
- **Tangled control flow:** nested ternaries, boolean-flag parameters, long `if`/`else` chains over the same value. Use plain `if`, `match`/`switch`, or a lookup table.
- **Needless indirection:** intermediate variables used once that add no meaning; data copied into a new struct just to pass it along; `async` wrappers that only `await` one call.
- **Dead code:** unused functions, parameters, imports, variables, branches, commented-out code, and "for future use" code. Grep the whole repo, including scripts and config, before deleting.

**Reinvention**
- **Reimplemented helpers:** new code that duplicates a helper the repo already has. Call the existing one.
- **Reinvented stdlib or deps:** hand-written grouping, parsing, retrying, deep-copying, or path/URL/date handling that the language or an installed dependency already provides.
- **`_v2`, `new_`, `enhanced_` clones:** two versions of one thing alive at once. Keep one.

**Defensive noise**
- **Checks for things that cannot happen:** null/type/range checks on values that were just constructed, already validated upstream, or guaranteed by the type system.
- **Probing chains:** `hasattr`/`getattr`/`isinstance`/`typeof` ladders that accept anything because nobody checked the real type. Find the type and write code for it.
- **Unjustified fallbacks:** try-import alternatives, silent default values, "just in case" retries, compatibility shims with no current user.
- **Swallowed errors:** broad `except`/`catch` that returns a default, logs and continues, or does nothing. Narrowing is behavior-risky, so report it (rule 4).
- **Type escapes:** `any`, `as unknown as`, `# type: ignore`, `unwrap()` spam, `interface{}`, or casts used to silence the type checker instead of fixing the type.

**Noise**
- **Narrating comments** that restate the code or talk to the reviewer ("This ensures…"). Keep comments that explain *why*: constraints, invariants, non-obvious choices.
- **Boilerplate docstrings** that repeat the function name; marketing words (robust, comprehensive, seamless).
- **Decorative leftovers:** section banners, emoji in logs or identifiers, leftover debug prints, over-verbose logging.

**Test slop** (report by default)
- Tests that only check that a mock was called; tests of trivial literals; the same case copied under several names.

## Leave alone

- Defensive code at real trust boundaries: user input, network, files, plugins.
- Abstractions with real multiple implementations, including ones loaded dynamically.
- Duplication or fallbacks with a stated reason (a benchmark, a platform difference, a documented migration).
- Helpers that give a real concept a clear name, even when short.
- Code that is already clean. Removing nothing is a valid result.

## Workflow

1. Get the diff and run the tests, build, and lint to record the starting state.
2. Read each changed hunk with enough context (callers, neighboring code, existing helpers).
3. Apply safe fixes. Rerun checks after each group of related edits. If a check fails, revert that group; do not fix forward.
4. Final pass: ask "what would still make a reviewer say an AI wrote this?" and handle it.
5. Report briefly:
   - what was removed (grouped, with rough line delta)
   - risky items left for the user, with `file:line` and a one-line reason
   - check results
