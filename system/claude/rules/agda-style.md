---
paths:
  - "**/*.agda"
  - "**/*.lagda.md"
---

# Agda Style & Preferences

### Standard Library

Use agda-stdlib wherever possible.
Prefer existing lemmas and structures over rolling your own.

### Formatting

One declaration per line.
Never use semicolons to combine `import`, `open`, or definition statements on a single line.

**Record layout**:
Use multi-line `record` with one field per line,
aligned `=` signs,
and `{`/`}` on their own indentation level.
Exception: a single field can stay on one line (e.g. `record { cong = id }`).

**Tuple layout**:
When a definition produces a tuple split across lines,
align `,` with `=` so all component expressions start at the same column.

### Import Grouping

Group imports by origin,
separated by blank lines:
stdlib first,
then lycopodium (`Maps.*`),
then carya (`Language.*`, `Compiler.*`, etc.).
Within each group, keep alphabetical order.

### Import Consolidation

Each module must appear at most once in the import block.
If additional names are needed from an already-imported module,
add them to the existing `using` clause.
Do not repeat the import.

Local `open import` inside a `where` block is only acceptable
for modules not imported at file scope.

### Qualified Imports

Prefer `import M as Alias` over `open import M using/renaming (...)`
when you'd need a long `using` or `renaming` clause to manage name clashes.
Plain `open import M` is fine.

When a qualified import is used heavily at call sites,
`open` it with `using` to avoid repetitive prefixing.
Verify there are no name clashes before opening.

Alias conventions:
- Type bundles: use the type symbol (e.g., `import Data.Integer as ℤ`)
- Property modules: `P` + superscript type (e.g., `import Data.Integer.Properties as Pᶻ`)

### Equational Reasoning

Use `begin … ∎` chains rather than explicit `trans` calls.
Choose the reasoning module based on the relation
(`≡-Reasoning`, `≈-Reasoning`, `≤-Reasoning`, etc.).

When a proof is a chain of two or more equivalences or equalities,
use equational reasoning rather than naming intermediate steps in a `where` block
and composing them with `∘` or `trans`.
For `_⇔_` chains, use `Function.Reasoning`.

### Point-Free / Categorical Style

Express functions using combinators rather than pointwise lambdas.
Eta-reduce by default.
Eta-expand only as much as elaboration requires
(see agda-gotchas skill for cases where explicit implicits are forced).

### Minimal Bindings

Never introduce a binding that elaboration doesn't force.
This includes unused bindings,
avoidable lambda variables,
and inferrable implicits at call sites.

### Algebraic Structure Style

Define `Is*` structures bottom-up in dependency order;
every level is a named top-level definition,
never an inline anonymous record.

### Module Parametrisation

If an anonymous `module _ (p₁ : T₁) … where` introduces parameters
that every definition in the file depends on,
promote it to a named top-level module parameter.
For example, replace:

```agda
module _ {Σ : Set} (_≟_ : DecidableEquality Σ) where
  ...  -- all definitions
```

with:

```agda
module Language.Foo {Σ : Set} (_≟_ : DecidableEquality Σ) where
  ...
```

### Comment Style

Use plain `-- comment` throughout.
Do not use Haddock-style `-- | name: description` prefixes;
they add no value in Agda files.

### No Trivial Wrappers

Do not create named wrappers around single stdlib functions.
Use the stdlib name directly at call sites.

**Wrong approach:**

```agda
fromℕℤ : ℕ → ℤ
fromℕℤ n = + n
```

**Correct:** use `+_` directly.

### Properties Module Organization

In a `Properties` module,
group all standalone lemmas (property-level bridges) first,
then all structure/bundle conversion functions.
Keep the building blocks separate from the things built from them.

For detailed conventions and examples,
consult the `/agda-style` skill.
For common elaboration gotchas,
consult the `/agda-gotchas` skill.
