---
name: review-rules
description: >
  Systematically review code to extract style principles
  and improve global rules files.
  Use after completing a project or milestone.
invocation: user
---

# Review Rules Skill

## Code Review Process for Rules Improvement

Use this at the start of a new project
(or after completing a milestone)
to improve global style rules based on real code produced.

### Setup

- User opens source files in their editor alongside the Claude terminal session
- The goal is to extract *principles* for the global rules files,
  not just fix the code
- Pre-annotation (Step 1) is optional — the process can start conversationally,
  in which case skip to Step 3
- A principle is worth recording if it could affect future code
  in a different file or session.
  A fix that only applies once is not a principle.

### Step 1 — User annotates (optional)

User adds review comments directly in the source files.
Syntax by language:

- Agda: `-- REVIEW: ...`
- Markdown/text: `<!-- REVIEW: ... -->` or a plain `REVIEW:` marker on its own line
- Adapt to other languages as needed
  (e.g., `// REVIEW:` for C-style, `# REVIEW:` for Python/shell)

Comments can be brief — just enough to flag the issue.
Save the files when done.

### Step 2 — Claude reads and discusses user annotations

"Project files under review" means the files explicitly provided by the user
at the start of the session,
or — if no files were specified — all files under the current working directory.
When reviewing the rules files themselves,
this includes `~/.claude/rules/` and `~/.claude/skills/`.

Claude greps for `REVIEW` comments in the project files under review,
and presents them **one at a time** using `AskUserQuestion`
(see Interaction Style below).
Do not update rules files yet — wait until all issues are collected,
so later insights can inform earlier ones
and the final rewrite is coherent.

User can add more comments at any point if the process is working well.

### Step 3 — Claude self-reviews

After processing user comments (or immediately, if there were none),
Claude re-reads the code with fresh eyes,
as if auditing it for the first time,
and flags any issues Claude independently notices —
things not yet captured by annotations.
Present findings **one at a time** using `AskUserQuestion`
(see Interaction Style below).
Do not update rules files yet — collect all findings first,
same as Step 2.
When citing a code observation,
always include the full file path
(e.g., `~/Agda/FuzzyLogic.agda`, not just `FuzzyLogic.agda`).

### Step 4 — Update rules files

Once all issues are identified and principles agreed upon,
update the global rules files in one coherent pass.
Prefer editing existing sections over adding disconnected entries.
Separate style preferences from elaboration gotchas.

### Step 5 — Update coverage log

Record each reviewed file in `/home/bsaul/nixos-config/system/claude/rules/review-log.md`
(or a language-specific log like `/home/bsaul/nixos-config/system/claude/rules/agda-review-log.md`):

- File path (relative to project root or home directory)
- Date reviewed (ISO 8601: YYYY-MM-DD)
- File mtime at time of review:
  - Linux: `stat -c "%y" <file>`
  - macOS: `stat -f "%Sm" -t "%Y-%m-%d %H:%M" <file>`
- Brief note on what was found / what rules were updated

Before re-reviewing a file,
compare the current mtime against the recorded one.
Re-review if the file has changed.

### Step 6 — Confirm

Show the user a summary of all changes made
and ask for explicit sign-off before treating the review as complete.
This closes the loop and catches any misunderstandings
before they become permanent.

### Interaction Style

Present each issue one at a time using `AskUserQuestion`.
Show the code context in the question text,
then offer 2–4 concrete options.
Common patterns:

- **User annotation (Step 2)**: Claude proposes a principle or interpretation;
  options are candidate principles, "keep as is", or variations.
  Include "why" context in the question.
- **Self-review finding (Step 3)**: Claude flags something;
  options include a proposed fix, "not an issue — skip", and variations.

Group closely related annotations
(e.g. the same rename pattern in two files)
into a single question rather than asking twice.
Always leave room for "Other"
(provided automatically by AskUserQuestion)
so the user can redirect.

After each answer,
briefly acknowledge the decision and move to the next issue.
Save discussion for cases where the user chooses "Other"
or asks to elaborate.

### Discussion Guidelines

- Ask "why does this bother you?" not just "what should it be?" —
  the root matters
- Distinguish aesthetic preferences from forced/technical constraints
- Look for the most general principle that covers the specific case
- Be honest about uncertainty; "I don't know why" is a valid answer
