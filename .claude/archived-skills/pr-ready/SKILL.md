---
name: pr-ready
description: Code review checklist for ensuring PRs meet quality standards. Use when reviewing code, preparing a PR, or checking that changes are clean, idiomatic, and production-ready across Python and Golang.
---

# PR Ready

Ensure code changes are clean, idiomatic, and production-ready before merging. This skill covers general code quality principles and language-specific best practices for Python and Golang.

## When to Use This Skill

- Reviewing a pull request for quality and correctness
- Preparing code for PR submission
- Checking that new code follows project conventions
- Refactoring existing code to meet quality standards

## General Principles

**Conciseness**: Prefer brief, focused code. No unused variables, functions, or imports. Proactively suggest opportunities to shorten code: inline single-use variables, remove redundant logic, use built-ins.

**Idiomatic code**: Look for patterns novices miss but experts don't. Flag verbose patterns and suggest concise alternatives.

**No noise**: Remove useless comments, debug statements, and print/log noise left from development.

**Early returns**: Avoid else blocks and deep nesting. Return or continue as soon as a condition is met.

**No new LSP errors or warnings**: Changes must not introduce new type errors, lint warnings, or diagnostics.

**Treat users as experienced programmers**: Don't over-explain or add defensive comments they don't need.

## Python

**Type hints always**: All function signatures must have type hints. Never use `Any` as a type.

**Classes vs functions**: Write classes only when they improve reuse or model a clear domain concept. Prefer plain functions or primitives when they suffice.

**Inline single-use variables**: If a variable is only used once and doesn't improve readability, inline it into the return or call site.

**Data modeling**:
- Use **Pydantic** classes to validate data at boundaries with external systems
- Use **dataclasses** for internal data structures
- Never use plain Python classes where dataclasses or Pydantic would serve better

**Exception handling**:
- No blank `except` blocks
- No meaningless re-raises of already-specific exceptions
- Prefer specific exception types and custom domain exceptions
- Avoid bare `except:` or `except Exception:`

**Pythonic patterns**: Use list comprehensions, `any()`/`all()`, and tuple unpacking when short and readable. Replace simple `if/else` with ternary expressions. Prefer `sum()`, `map()`, `filter()`, and other built-ins over manual loops.

**Context managers**: Use `with` statements wherever applicable (files, locks, connections).

**No nested functions**: Functions should not be defined inside other functions.

## Golang

Reference: [CockroachDB](https://github.com/cockroachdb) for good practices on error handling, code structuring, resource management, and concurrency patterns.

**Error handling**:
- Return detailed error information alongside normal values using multiple return values
- Never discard errors with `_`; always check and handle them
- No blank error handling blocks
- No meaningless error re-wraps

**Panic**: Do not use `panic` for normal error handling. Reserve it for unrecoverable or logically impossible internal states.

**Resource management**: Use `defer` immediately after acquiring a resource (mutex, file, connection) to ensure it is released on all return paths.

**Initialization**:
- Use `make` for slices, maps, and channels
- Use `new` only when a zeroed pointer is preferred
- Use composite literal syntax `T{field: value}` instead of field-by-field assignment
- Structs must always have a constructor `New*` function

**Concurrency**: Follow "share memory by communicating" — use channels to pass values rather than mutexes to protect shared variables whenever possible.

**Control flow**: Use early returns to prevent conditional nesting. Avoid deeply nested `if` blocks.

**Architecture**:
- Data layer must follow the repository pattern
- Avoid global mutable state; pass dependencies through function parameters or struct fields
- Use interfaces to abstract dependencies and enable testing; prefer small, focused interfaces

**Constants**: Convert strings or magic numbers used multiple times into named constants. Use `iota` for related sets of values.

**Loops**: Use range-based `for` loops when iterating over collections instead of index-based loops.

**Types**: Avoid `any`; use concrete types. If `any` is truly required, use `any` (not `interface{}`) for readability.
