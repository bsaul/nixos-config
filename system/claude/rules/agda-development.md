---
paths:
  - "**/*.agda"
  - "**/*.lagda.md"
  - "**/*.lagda.tex"
  - "**/*.lagda.typ"
---

# Agda Development Rules

## Design Philosophy

Agda is a **proof assistant**, not "a better Haskell."
The entire point is leveraging the type system for correctness guarantees.

### Types Are Specifications

A type signature is a theorem statement.
An implementation is its proof.
Approach every function as:
"What property am I proving by writing this?"

### Prove, Don't Check

If a property can be established at compile time, prove it.
Don't defer to runtime what the type system can guarantee statically.

**Wrong approach:**

```agda
-- Runtime check, throws away information
lookup : List A → ℕ → Maybe A
```

**Proof-oriented approach:**

```agda
-- The type guarantees success
lookup : (xs : List A) → Fin (length xs) → A
```

### Carry Evidence

When a fact matters, carry its proof explicitly.
Don't rely on assumptions, comments, or "knowing" something is true.

**Wrong approach:**

```agda
-- Caller "promises" the list is sorted
merge : List ℕ → List ℕ → List ℕ
```

**Proof-oriented approach:**

```agda
-- Sortedness is witnessed, not assumed
merge : SortedList ℕ → SortedList ℕ → SortedList ℕ
```

### Make Invalid States Unrepresentable

Use indexed types to rule out illegal values by construction.
If the type permits it, someone will construct it.

- Use `Fin n` instead of `ℕ` when bounds matter
- Use `Vec n` instead of `List` when length is significant
- Define custom indexed types when existing ones don't capture your invariant

### Evidence Over Booleans

Prefer decidable predicates (`Dec P`) over boolean functions.
A `Dec P` gives you either a proof of `P` or a proof of `¬ P`.
A `Bool` gives you nothing to reason about.

**Wrong approach:**

```agda
isPrime : ℕ → Bool
```

**Proof-oriented approach:**

```agda
isPrime? : (n : ℕ) → Dec (Prime n)
```

### Totality Matters

Every function should be total.
Partiality hides proof obligations.
If a function can fail, its type should explain when and why.

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
