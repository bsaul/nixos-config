---
paths:
  - "**/*.agda"
  - "**/*.lagda.md"
---

# Agda Development Rules

## Code Integrity

**Never remove flags** (e.g., `{-# OPTIONS #-}` pragmas) from files you are working on.
These flags are intentional and control important type-checking behaviors.

**Never use postulates** unless the user explicitly allows it.
All code must be proven or implemented,
not assumed.

## Standard Library Access

**CRITICAL:** The Agda standard library is provided by the project's Nix environment.

- **NEVER search the web** for standard library code or documentation
- **NEVER look in ~/.agda/** or other global directories
- The stdlib is automatically available via the project's Nix flake
- Use `agda_search_about` and `agda_show_module` to explore stdlib functions

## Libraries File

Before loading any Agda file,
check for a `libraries` file in the project root.

- If found, pass it to `agda_load` via the `libraryFile` parameter
- If not found, prompt the user to provide the path to their libraries file
- The libraries file should reference the Nix-provided standard library
