# Bash coding and scripting style

To ensure our Bash scripts read like properly structured programs rather than untidy, blobby shell scripts, we establish clear coding conventions for Bash script templates.

## Context

Bash scripts are often written as sequential scripts with global variables, minimal function usage, and variable scopes that are difficult to trace. This can lead to bugs, poor maintainability, and code that is hard to read.

## Decision

We establish the following style rules for Bash scripts:
1. **Structural Separation**: Use functions to partition logic, keeping code modular and structured.
2. **Local Variables**: Declare variables within functions using the `local` keyword. Always declare variables as read-only (`local readonly` or `local -r`) unless their values must be reassigned.
3. **Return Statement Formatting**: Separate a `return` statement from any preceding statement in the same block by a blank line. If the `return` statement is the first or only statement inside a conditional block (e.g., `if [[ ... ]]; then return 0; fi`), do not insert a blank line before it.
4. **General Best Practices**: Adhere to robust scripting guidelines, including:
   - Use `set -euo pipefail` (or similar error-trapping) to catch early failures, uninitialized variables, and pipeline errors.
   - Quote all variable expansions (e.g., `"$var"`) to prevent word splitting and globbing.
   - Prefer double brackets `[[ ... ]]` for test conditions and patterns.
   - Use `$()` for command substitution instead of backticks.
   - Declare constants as `readonly`.

## Consequences

* Improves readability and maintainability by structuring shell scripts like robust programs.
* Minimizes variable namespace pollution and makes logic easier to reason about.
* Ensures visually clean, consistent return statement separation in function logic.
