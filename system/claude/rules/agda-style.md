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

### Import Consolidation

If a module is already imported at the top of the file,
add any additional names to that existing import
rather than opening it again in a local `where` clause.
Local `open import` is only for modules not used elsewhere in the file.

### Qualified Imports

Prefer `import M as Alias` over `open import M using/renaming (...)`
when you'd need a long `using` or `renaming` clause to manage name clashes.
Plain `open import M` is fine.

Alias conventions:
- Type bundles: use the type symbol (e.g., `import Data.Integer as ℤ`)
- Property modules: `P` + superscript type (e.g., `import Data.Integer.Properties as Pᶻ`)

### Equational Reasoning

Use `begin … ∎` chains rather than explicit `trans` calls.
Choose the reasoning module based on the relation
(`≡-Reasoning`, `≈-Reasoning`, `≤-Reasoning`, etc.).

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

### Properties Module Organization

In a `Properties` module,
group all standalone lemmas (property-level bridges) first,
then all structure/bundle conversion functions.
Keep the building blocks separate from the things built from them.

For detailed conventions and examples,
consult the `/agda-style` skill.
For common elaboration gotchas,
consult the `/agda-gotchas` skill.
