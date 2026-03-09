---
name: launch-plan
description: Launch a plan in an isolated git worktree
user-invocable: true
---

# Launch Plan

Launch a plan from the `plans/` directory in an isolated git worktree,
with the `libraries` file and `CLAUDE.md` copied over if not git-tracked.

## Steps

### 1. Select a plan

List available plans:

```sh
ls plans/
```

Ask the user which plan to launch.
Use the directory name as `<plan-name>`.

### 2. Create the git worktree

```sh
git worktree add wt-<plan-name> -b wt-<plan-name>
```

If the branch already exists (worktree was created before), use:

```sh
git worktree add wt-<plan-name> wt-<plan-name>
```

### 3. Copy the `libraries` file if not git-tracked

Check if `libraries` is tracked by git:

```sh
git ls-files libraries
```

If the output is empty (not tracked), copy it to the worktree:

```sh
cp libraries wt-<plan-name>/libraries
```

If it is tracked, it is already in the worktree — no action needed.

### 4. Copy CLAUDE.md if not git-tracked

Check if `CLAUDE.md` is tracked by git:

```sh
git ls-files CLAUDE.md
```

If the output is empty (not tracked), copy it to the worktree:

```sh
cp CLAUDE.md wt-<plan-name>/CLAUDE.md
```

If it is tracked, it is already in the worktree — no action needed.

### 5. Update CLAUDE.md in the worktree

Prepend an **Active Plan** section to `wt-<plan-name>/CLAUDE.md`
(create the file if it does not exist):

```markdown
## Active Plan

This worktree is focused on plan: `plans/<plan-name>/`

- [PLAN.md](./plans/<plan-name>/PLAN.md) — tasks and phases
- [CONTEXT.md](./plans/<plan-name>/CONTEXT.md) — problem and constraints
- [LOG.md](./plans/<plan-name>/LOG.md) — progress history

Start by reading PLAN.md to understand the current phase and next tasks.

---

```

Place this section at the very top of the file,
before any existing content.

### 6. Report success

Show:

- The worktree path: `wt-<plan-name>/`
- The active plan: `plans/<plan-name>/`
- Whether `libraries` and `CLAUDE.md` were copied or already tracked
