---
name: ventilated-prose
description: Reformat markdown to use ventilated prose (semantic line breaks)
disable-model-invocation: true
user-invocable: true
---

# Reformat to Ventilated Prose

Apply ventilated prose formatting to existing markdown text.

## Process

1. Read the markdown file or text provided by the user
2. Identify long sentences with multiple ideas
3. Break lines at natural pauses:
   - After commas
   - Before conjunctions (and, but, since, because, while, etc.)
   - After introductory phrases
   - At logical breaks in compound sentences
4. Keep one distinct idea or phrase per line
5. Preserve:
   - Paragraph breaks (blank lines)
   - List formatting
   - Code blocks
   - Other block elements

## Rules Reference

**Goal**: One distinct idea or phrase per line.
This ensures clearer diffs and easier editing.

**Where to break**:
- After commas separating clauses
- Before coordinating conjunctions (and, but, or, nor, for, so, yet)
- Before subordinating conjunctions (because, since, while, although, if, when)
- After introductory phrases
- At natural pauses where you'd breathe when reading aloud

**What NOT to break**:
- Short sentences (< 80 chars) with single ideas
- List items (each item is already one line)
- Code blocks
- Headings
- Links or inline code spans (keep them intact when possible)

## Example Transformation

**Before:**
```markdown
This is a long sentence that contains multiple ideas, and it also has some additional context that could be separated, but instead it's all on one line which makes git diffs harder to read.
```

**After:**
```markdown
This is a long sentence that contains multiple ideas,
and it also has some additional context that could be separated,
but instead it's all on one line
which makes git diffs harder to read.
```

## Tips

- Break after commas when they separate independent clauses
- Don't break within short phrases (e.g., "such as X" stays together)
- Aim for balanced line lengths when possible (but clarity > length)
- Re-read the result to ensure it flows naturally
