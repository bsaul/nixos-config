---
name: ventilated-prose
description: Write markdown using ventilated prose (semantic line breaks)
disable-model-invocation: true
user-invocable: false
---

# Ventilated Prose

Also known as Semantic Line Breaks or Semantic Ventilated Prose.
A technique for writing markdown text
to improve diff readability and editing.

## Rules

- Break long sentences into multiple lines at natural pauses
  (e.g., after commas, before conjunctions like "and," "but," "since").
- **Goal**: One distinct idea or phrase per line.
  This ensures clearer diffs and easier editing.
- Blank lines separate paragraphs and sections.
- Lists follow standard markdown (each item on its own line).
- Code blocks and other block elements are unchanged.

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
