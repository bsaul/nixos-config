---
name: agda-typecheck
description: >
  Typecheck an Agda file and report the results.
  Use for quick verification after edits.
invocation: user
mcpServers:
  - agda-mcp
---

# Agda Typecheck

Typecheck an Agda file and report results.

## Usage

```
/agda-typecheck <file-path>
```

## Workflow

1. Load the file with `agda_load`
2. Report the outcome:
   - **Success**: Confirm zero goals, zero errors
   - **Goals**: List each goal with its type and location
   - **Errors**: Show error messages with locations

## Output Format

```
## Typecheck: <filename>

**Status**: ✓ Clean / ⚠ N goals / ✗ Errors

### Goals (if any)
- Goal 0 at line N: <type>
- Goal 1 at line M: <type>

### Errors (if any)
- Line N: <error message>
```

## Notes

- For fixing goals or errors, use agda-developer
- This skill diagnoses only—it does not modify code
