---
name: agda-gotchas
description: Reference guide for common Agda elaboration and constraint-solving issues
disable-model-invocation: true
user-invocable: false
---

# Agda Elaboration Gotchas

Elaboration surprises encountered in practice — keyed by symptom.

### Unsolvable constraints when record field types unfold to a record constructor

**Root cause**:
When a record field type mentions a relation that unfolds to a record constructor
(e.g. `_≈_ = _∣_`),
Agda must elaborate field types before it can check field values.
Any non-bare expression in those field values (copattern, application, etc.)
blocks the constraint solver.
The fix — independently typechecked top-level names referenced as bare names —
applies to **any record** in this situation.
When you see unsolvable constraints inside a `record { … }`,
ask whether any field type unfolds to a record constructor,
and if so,
extract field values into separate top-level definitions.
See Equivalence Structure in agda-style.md for the canonical pattern.

The following two entries are specific failure modes arising from this root cause.

### Bare names in record when a field type unfolds to a record constructor

**Symptom**:
`record { refl = ≈-refl ; … }` fails when a field type unfolds to a record constructor
(e.g. `_≈_ = _∣_`).
The bare name leaves implicit arguments as metas,
and Agda cannot solve constraints like `_x + - _x = x + - x` (non-linear, blocked).

**Fix**:
Pin the implicit(s) that create the non-linear constraint
using an explicit-implicit lambda:
```agda
isEquivalence = record
  { refl  = λ {x} → ≈-refl  {x}
  ; sym   = λ {x} → ≈-sym   {x}
  ; trans = λ {x} → ≈-trans {x}
  }
```
The lambda head pins the implicit before constraint solving begins.
Which implicits to pin depends on which ones create the non-linearity —
it is not always just the first.
When `_≈_` unfolds to a *non-problematic* record (e.g. `_×_`),
plain `record { refl = ≈-refl ; … }` works fine.

### Applications in record fields when a field type unfolds to a record constructor

**Symptom**:
Writing `record { field = f arg ; … }` (any *application*)
when a field type unfolds to a record constructor (e.g. `_∣_`)
causes unsolvable constraints.
Agda must elaborate the field type before it can check the value,
and the application blocks constraint solving.

**Fix**:
Use explicit-implicit lambdas instead of bare applications.
The lambda head gives Agda the implicit before constraint solving begins:
```agda
record { field = λ {x} → f {x} }   -- not: record { field = f }
```
Remaining implicits after the pinned one can be left for Agda to infer.

---

The following two entries concern a different root cause:
non-injective `_≈_` preventing Agda from solving unification constraints.

### Eta-contracted field assignment in records with non-injective `_≈_`

**Symptom**:
Assigning `∙-cong = +-cong` directly in a record causes blocked metas
when `_≈_` involves a non-injective function (e.g. subtraction `x - y`).

**Fix**:
Expose just the implicit(s) that create the non-linear constraint;
eta-reduce everything else:
`∙-cong = λ {x} → +-cong {x}`.
Once `{x}` is pinned,
the remaining implicits are universally quantified in the expected type
and require no explicit guidance.
Which implicits need to be exposed depends on which ones create the non-injectivity —
it is not always the first.

### Explicit implicits for `refl`-based goals

**Symptom**:
`N.refl` (no explicit implicit) in a goal involving a non-injective function
(e.g. subtraction)
creates a non-linear constraint `_x - _x = rhs` that Agda cannot solve.

**Fix**:
Always provide the implicit explicitly:
`N.refl {0ℤ}`, `N.refl {x + y}`, etc.

### Direct construction over `subst` for complex goal types

**Symptom**:
Using `subst` to rewrite a proof goal forces Agda to unify complex expressions,
causing blocked metas.
This applies to any witness type (divisibility, ordering, membership, etc.)
where the goal type contains complex expressions.

**Fix**:
Build the proof directly using an equational-reasoning chain,
which gives Agda explicit steps rather than a unification problem.
Example for divisibility:
`divides q (begin … ∎)` instead of `subst (q ∣_) eq proof`.

### Unsolved metas from partial-projection equivalences

**Symptom**:
`∙-cong = +-cong` or `refl = ≈-refl` in a record leaves invisible unsolved metas
when `_≈_` on a composite type (e.g. `T = Σ S (λ s → Σ R (λ r → q r ≈ s))`)
only inspects one component (e.g. the R-component).
The uninspected components (S-value, proof) are genuinely unconstrained,
not blocked by non-linearity.

**Fix**:
Pin *every* implicit of the composite type, not just the first:
```agda
∙-cong = λ {t₁} {t₂} {t₃} {t₄} → +-cong {t₁} {t₂} {t₃} {t₄}
⁻¹-cong = λ {t₁} {t₂} → -‿cong {t₁} {t₂}
```
This differs from the non-injective-`_≈_` pattern
where pinning just the first implicit suffices.
Here every implicit T argument has free components,
so all must be pinned.

### Invisible goals from `agda_load` Concise format

**Symptom**:
`agda_load` with default (Concise) format reports "0 goals"
but the file has unsolved metas (yellow highlighting in Emacs).
These appear as `invisibleGoals` in the Full format output.

**Fix**:
Always use `format: "Full"` when loading files
and verify that both `visibleGoals` and `invisibleGoals` arrays are empty.

### Column alignment verification with multi-byte Unicode

**Symptom**:
Byte-offset tools (awk `substr`, sed, shell column counting)
report alignment as correct,
but Emacs shows misalignment.
Or vice versa.

**Root cause**:
Multi-byte Unicode characters (e.g. subscript digits `₁₂₃` are 3 UTF-8 bytes but 1 Emacs column)
make byte offsets diverge from display columns.
Lines with more Unicode characters on the LHS accumulate larger byte-vs-column drift.

**Fix**:
Use Python to find column positions —
`len()` on a Python `str` counts codepoints, not bytes:
```bash
python3 -c "s=open('file').readlines()[41]; print(s.index('='))"
```
Never use awk `substr`, sed, or shell byte-counting
for alignment verification on lines containing multi-byte Unicode.

### Operator section ambiguity with overloaded names

**Symptom**:
An operator section can be ambiguous
when the operator name appears both as a binary operator
and as a prefix or postfix constructor or coercion elsewhere in scope.
Agda cannot determine which usage is intended.
Example: `+_` is both the binary addition section and the postfix `ℕ → ℤ` coercion,
so `cong (a +_)` is ambiguous.

**Fix**:
Use a lambda instead of a section:
`cong (λ k → a + k)`.
This is a forced exception to the section preference.
