Review the current changes (staged + unstaged) and check each of the following:

## General
- Prefer concise and brief code, no unused code
- Proactively suggest code shortening opportunities (inline variables, remove redundant logic, use built-ins)
- Flag verbose code patterns and suggest more concise alternatives
- Prefer idiomatic programming: look for things that novices miss but experts don't
- No useless comments, debug/print statements
- Use early returns: avoid else blocks and deep nesting by returning or continuing as soon as a condition is met
- No new LSP errors or warnings
- Treat your users like experienced programmers

## Python
- Type hints always. Avoid using `any` type
- Use classes when beneficial: write classes if they lead to better code reuse, but prefer simple functions or primitives when they suffice
- Avoid local variables used once: inline variables directly into the function call or return statement if they aren't needed for clarity elsewhere
- Use PYDANTIC classes to validate data interacting with outside code. Use DATACLASSES in other cases, never default python classes
- No blank exception blocks. No meaningless raises if the code is already raising a specific exception
- Prefer specific exception types and custom domain exceptions; avoid bare `except:` or `except Exception:`
- Use list comprehensions, `any()`/`all()`, and tuple unpacking if short and readable
- Prefer ternary operators: replace simple if/else blocks with a single ternary line if short and readable
- Leverage built-ins: prefer standard library or built-in functions (`sum()`, `map()`, `filter()`) instead of manual for loops if readable
- Use context managers (`with` statements) wherever applicable
- No nested functions

## Golang
- Refer to `https://github.com/cockroachdb` for good practices for error handling, code structuring, resource management, and concurrency patterns
- Descriptive errors: return detailed error information alongside normal values using multiple return values
- Avoid panic: do not use panic for normal error handling; reserve it for unrecoverable or "impossible" internal states
- Resource management: use `defer` immediately after acquiring a resource (like a mutex or file) to ensure it is released regardless of the return path
- Never discard errors: do not use the blank identifier (`_`) to ignore error returns. Always check errors
- Use `make` for references: use `make` for slices, maps, and channels to return an initialized value; use `new` only when a zeroed pointer is preferred
- Prefer composite literals: use `T{field: value}` syntax for initialization instead of manual field-by-field assignment
- Concurrency: follow the "share memory by communicating" principle -- use channels to pass values rather than mutexes to protect shared variables whenever possible
- Write conditional flows with early returns and prevent conditional nesting
- Structs should always have a `New` function to initialize them
- Data layer should follow the repository pattern
- Constants: convert strings or magic numbers used multiple times into constants; use `iota` for related sets of values
- Use range-based for loops instead of traditional for loops when iterating over collections
- Avoid global state: do not use package-level variables for mutable state; pass dependencies explicitly through function parameters or struct fields
- Use interfaces to abstract dependencies and enable easier testing; prefer small, focused interfaces over large ones
- Avoid using `any` type, use concrete types and if it is REALLY required use `any` instead of `interface{}` for better readability and type safety
