# Markdown Writing Style

Always write markdown using ventilated prose (semantic line breaks).

## Ventilated Prose Rules

Break long sentences into multiple lines at natural pauses
(e.g., after commas, before conjunctions like "and," "but," "since").
Keep one distinct idea or phrase per line.
This ensures clearer diffs and easier editing.

Blank lines separate paragraphs and sections.
Lists follow standard markdown (each item on its own line).
Code blocks and other block elements are unchanged.

## Example

**Wrong:**
```markdown
This is a long sentence that contains multiple ideas, and it also has some additional context that could be separated, but instead it's all on one line.
```

**Correct:**
```markdown
This is a long sentence that contains multiple ideas,
and it also has some additional context that could be separated,
so we break it at natural pauses.
```

## Benefits

- Git diffs show exactly which phrase changed
- Easy to reorder ideas within a sentence
- Clearer structure at a glance
- Line-based tools work better (grep, wc -l, etc.)

For reformatting existing markdown to this style,
use the `/ventilated-prose` skill.

## Literate Agda Prose (`.lagda.md`)

### When to write prose

Use a heading for every definition or section.
Add prose only when the type signature alone is non-obvious
(e.g., unusual result type like `Tri`,
a subtle relationship between definitions,
or a genuinely surprising proof structure).
If the signature is self-explanatory,
the heading is enough.

### What not to write

- **Do not restate the type signature in English.**
  "If `z` is apart from `x ∙ y`, then …"
  adds nothing over the Agda.
- **Do not write boilerplate record summaries.**
  "A co-X is a co-Y whose operation is co-Z"
  just restates what the record fields say.
- **Do not explain simple contrapositive proofs.**
  Proof-strategy prose is warranted only when
  the proof structure is genuinely hard to read from the Agda
  (e.g., a `Tri`-based contradiction argument).

### `<details>` blocks in parameterized modules

For parameterized modules,
use separate `<details>` blocks:
one for OPTIONS (labeled "Options"),
one for pre-module imports needed by the module signature,
and one for bulk imports inside the module body (labeled "Imports").
Non-parameterized modules may combine OPTIONS and imports
if only one block is needed.
