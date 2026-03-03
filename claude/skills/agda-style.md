---
name: agda-style
description: Detailed style guide and formatting conventions for Agda development
disable-model-invocation: true
user-invocable: true
---

# Agda Style & Preferences — Detailed Reference

This is the comprehensive style guide for Agda development.
The core rules are automatically applied when working with Agda files;
use this skill to reference detailed examples and conventions.

### Standard Library

Use agda-stdlib wherever possible.
Prefer existing lemmas and structures over rolling your own.

### Formatting

One declaration per line.
Never use semicolons to combine `import`, `open`, or definition statements on a single line:
```agda
open import Agda.Builtin.FromNat  -- not: open import Agda.Builtin.FromNat; import Data.Unit
import Data.Unit
```

**Record layout**:
Use multi-line `record` with one field per line,
aligned `=` signs,
and `{`/`}` on their own indentation level.
Exception: a single field can stay on one line (e.g. `record { cong = id }`).
```agda
foo-isMagma = record
  { isEquivalence = isEquivalence
  ; ∙-cong        = +-cong
  }
```

**Tuple layout**:
When a definition produces a tuple split across lines,
align `,` with `=` so all component expressions start at the same column:
```agda
(s₁ , r₁ , p₁) + (s₂ , r₂ , p₂) = s₁ S.+ s₂
                                   , r₁ R.+ r₂
                                   , proof r₁ r₂ p₁ p₂
```

### Qualified Imports

Prefer `import M as Alias` over `open import M using/renaming (...)`
when you'd need a long `using` or `renaming` clause to manage name clashes.
Plain `open import M` is fine.
Alias conventions:

- Type bundles: use the type symbol —
  `import Data.Integer as ℤ`, `import Data.Nat as ℕ`,
  `import Data.Sum as ⊎`, `import Data.Product as Σ`
- Property modules: `P` + superscript type —
  `import Data.Integer.Properties as Pᶻ`,
  `import Data.Nat.Properties as Pᴺ`

When you need both qualified access and the type name / constructors unqualified,
use the hybrid form:
```agda
open import Data.Nat as ℕ using (ℕ; zero; suc)
open import Data.Product as Σ using (_,_)
```
This is idiomatic for `Data.Nat`, `Data.Integer`, `Data.Fin`, etc.
Constructor names such as `zero`, `suc`, `_,_`
can safely be opened from several modules simultaneously —
Agda resolves them by type.

When no qualified `M.foo` access is needed at all,
collapse the two-step pattern `import M as Alias` / `open Alias args`
into a single `open import M args`.

### Import Placement

Each import belongs at the top of the narrowest module scope covering all its uses —
neither replicated across sibling scopes nor hoisted unnecessarily to the outermost level.
For example,
`open ≡-Reasoning` goes at the top of the module that uses it,
not inside each `where` clause.
During exploration,
scattering imports near the code is fine;
consolidate once the design stabilises.

### Equational Reasoning

Use `begin … ∎` chains rather than explicit `trans` calls.
Choose the reasoning module based on the relation:

- `≡-Reasoning` — propositional equality chains
  (`open import Relation.Binary.PropositionalEquality`)
- `≈-Reasoning` — setoid/`IsEquivalence` chains
  (open from the relevant setoid, e.g. `open IsEquivalence.≈-Reasoning isEq`)
- `≤-Reasoning` / `<-Reasoning` — preorder/order chains
- Mixed-relation chains (`≡-≈-Reasoning`, `≡-∣-Reasoning`, etc.)
  exist in stdlib for chains that cross propositional equality and another relation

For placement of `open ≡-Reasoning` and similar,
see Import Placement above.

### Infix Style

Write binary relations and operators infix whenever both arguments are named —
including qualified operators:
```agda
x ≈ y      -- not _≈_ x y
x R.≈ y    -- not R._≈_ x y
```
For partially-applied operators,
use sections rather than lambdas
(see agda-gotchas skill for the forced exception
when a section is ambiguous due to overloading):
```agda
x ∙_   _∙ y   -- not λ y → x ∙ y   λ x → x ∙ y
```
When neither argument is bound,
use prefix `_∙_` — do not eta-expand just to introduce infix.

### Point-Free / Categorical Style

Express functions using combinators rather than pointwise lambdas.
Eta-reduce by default.
```agda
f ∘ g              -- not λ x → f (g x)
f ∘ inj₁           -- not λ x → f (inj₁ x)
f ∘ inj₁ , f ∘ inj₂  -- not (λ x → f (inj₁ x)) , (λ y → f (inj₂ y))
id                 -- not λ x → x
swap               -- not λ (p , q) → q , p
⟨ f , g ⟩         -- not λ x → f x , g x
[ f , g ]          -- for coproducts
```
Useful combinators:
`proj₁`, `proj₂`, `map`, `map₁`, `map₂`, `uncurry`, `curry`, `flip`,
`_∘₂_` (compose unary `f` with binary `g`: `(f ∘₂ g) x y = f (g x y)`).

Eta-expand only as much as elaboration requires
(see Minimal Bindings below and agda-gotchas skill
for the cases where explicit implicits are forced).

When point-free is compact but non-obvious,
annotate with a lambda comment showing the pointwise reading.
Prefer this over expanding to a lambda:
```agda
_≈_ = ¬_ ∘₂ _≉_  -- λ x y → ¬ (x ≉ y)
```

**Pattern matching on composites**:
When defining operations that must destructure a composite type (e.g. a dependent triple),
pattern-match the components rather than using projection chains:
```agda
(s₁ , r₁ , p₁) + (s₂ , r₂ , p₂) = s₁ S.+ s₂ , r₁ R.+ r₂ , proof r₁ r₂ p₁ p₂
-- not: t₁ + t₂ = s-of t₁ S.+ s-of t₂ , … , f (proj₂ (proj₂ t₁)) (proj₂ (proj₂ t₂))
```
Projections and point-free composition (`R.+-identityˡ ∘ r-of`)
remain preferred when only one component is needed.

### Pair Syntax

Parentheses around pairs are only needed when the pair is a function-argument pattern.
Omit them everywhere else:
- **RHS**: `= p , q` not `= (p , q)`
- **`let` patterns**: `let x , y = …` not `let (x , y) = …`
- **`in` expressions**: `in x , f y` not `in (x , f y)`
- **Function-argument patterns**: `f (p , q) = …` — parens required here

### Local Module Aliases

Two complementary patterns for opening record bundles:

**Function-scope** —
`where module M = SomeRecord x` opens one bundle for a single definition:
```agda
linear {M = M} {N = N} f =
  f M.0ᴹ N.≈ᴹ N.0ᴹ × …
 where module M = LeftSemimodule M
       module N = LeftSemimodule N
```
The implicit argument and the local module intentionally share the same name —
the module *is* the opened form of the value.
This is idiomatic, not a collision to avoid.

**Module-scope** —
anonymous `(open RecordType param …)` arguments in the module parameter list
open bundles for the entire module body.
Earlier opens' names are visible to later ones:
```agda
module LinearInversion {c ℓ₁ ℓ₂} (F : HeytingField c ℓ₁ ℓ₂)
  (open HeytingField F renaming (Carrier to A))
  (open Setoid setoid using (_≉_))        -- `setoid` came from HeytingField F
  where
```
Use this form when the opened names are needed throughout the module
rather than in one function.

Alias convention for both forms:
short uppercase letter matching the mathematical role
(M, N for semimodules; R for rings; G for groups, etc.).

### Parameter & Renaming Names

Name module parameters and `renaming` targets with the
**noun first, superscript qualifier suffix**:
`setoidᴿ` not `R-setoid`,
`ringˢ` not `S-ring`,
`_≈ᴿ_` not `_≈R_`,
`rawRingᴿ` not `R-rawRing`.
This is lighter weight visually
and consistent with the `Pᶻ` convention for property-module aliases.

### Variable Names

Use plain one-letter names (`x y z w`) for variables ranging over a module's carrier type.
Reserve subscripted names (`x₁ x₂`, `s₁ s₂`)
for relating two or more things of the same kind —
e.g. the two operands in a binary operation's pattern match:
```agda
-- subscripts justified: relating two operands of the same kind
(s₁ , r₁ , p₁) + (s₂ , r₂ , p₂) = …

-- plain names: each variable is independent
+-assoc : ∀ x y z → (x + y) + z ≈ x + (y + z)
+-cong : ∀ {x y z w} → x ≈ y → z ≈ w → x + z ≈ y + w
```

When two values of the **same** record type must be accessed simultaneously,
use one alias per instance and qualify all field references.
Prefer this over `open RecordType p renaming (…)`:
```agda
module P = _≤_ p
module Q = _≤_ q
-- then write P.f, P.f-cong, Q.f, Q.f-cong, etc.
```

### Algebraic Structure Style

Define `Is*` structures bottom-up in dependency order;
every level is a named top-level definition,
never an inline anonymous record:
```agda
foo-isMagma : IsMagma _≈_ _∙_
foo-isMagma = record
  { isEquivalence = isEquivalence
  ; ∙-cong        = ∙-cong
  }

foo-isSemigroup : IsSemigroup _≈_ _∙_
foo-isSemigroup = record
  { isMagma = foo-isMagma
  ; assoc   = ∙-assoc
  }
```
This makes every intermediate structure accessible for reuse.

**Naming**:
The module's canonical equivalence uses the bare name `isEquivalence` (no prefix).
Intermediate *properties* use a `name-` prefix (e.g. `ring-+-assoc`)
to avoid collisions when multiple structures are defined in the same module.
`Is*` structures and assembled bundles
(`isRing`, `isOrderHomomorphism`, `posetHomo`, etc.)
use bare names — they are unique by type and don't clash.
This applies to algebraic, order-theoretic, and morphism structures alike.
Prefix only to resolve actual name collisions.

### Equivalence Structure

Define component properties as top-level non-private definitions,
then assemble by name:
```agda
≈-refl  : Reflexive _≈_
≈-sym   : Symmetric _≈_
≈-trans : Transitive _≈_

isEquivalence : IsEquivalence _≈_
isEquivalence = record
  { refl  = ≈-refl
  ; sym   = ≈-sym
  ; trans = ≈-trans
  }
```
When `_≈_` unfolds to a record constructor (e.g. `_∣_`),
bare names in record fields create unsolvable metas (see agda-gotchas skill).
Use explicit-implicit lambdas to pin the implicit before constraint solving:
```agda
isEquivalence = record
  { refl  = λ {x} → ≈-refl  {x}
  ; sym   = λ {x} → ≈-sym   {x}
  ; trans = λ {x} → ≈-trans {x}
  }
```
- Name the structure `isEquivalence`
  (no prefix — it is the module's canonical equivalence)
- Lift from propositional equality as `reflexive : _≡_ ⇒ _≈_`,
  proved by pattern matching.
  When `_≈_` is injective: `reflexive refl = ≈-refl`.
  When `_≈_` is non-injective (e.g. `x ≈ y = n ∣ (x - y)`),
  pass the implicit explicitly on both sides
  to avoid a non-linear unification constraint:
  `reflexive {a} refl = ≈-refl {a}`
- All of these are public (standard functionality)
- Do not use copatterns for this pattern (see agda-gotchas skill)

### Minimal Bindings

Never introduce a binding —
implicit `{x}`, explicit `λ x →`, or pattern variable —
that elaboration doesn't force.
This covers:

- Unused bindings: `{x}` or `λ x →` where the name doesn't appear in the body
- Avoidable lambda variables: `λ x → f (g x)` → `f ∘ g`; `λ x → x` → `id`
- Inferrable implicits at call sites: `f {x} y` → `f y` when Agda can infer `{x}`
- Unnamed wildcards for unused explicit args:
  `λ x y → e` → `λ _ _ → e` when neither appears

See agda-gotchas skill for cases where elaboration forces explicit implicits
(non-injective `_≈_`, refl-based goals with subtraction, etc.).

### Variables

Always declare type and level variables as `private variable`.
Non-`private` variable blocks are never intentional
and may accidentally export names:
```agda
private variable
  A B : Set
  a b ℓ ℓ′ : Level
```

### Visibility

Standard algebraic properties
(`+-cong`, `*-cong`, `neg-cong`, `+-assoc`, `+-comm`, identity, inverse, distributivity, etc.)
are always public.
Reserve `private` for genuine internal helpers with no standalone mathematical value.
