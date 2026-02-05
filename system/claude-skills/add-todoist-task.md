---
name: add-todoist-task
description: Add a new task to Todoist
disable-model-invocation: true
user-invocable: true
---

Add a new task to Todoist:

1. Ask the user for task details:
   - Task content (title/description)
   - Priority (p1=urgent, p2=high, p3=medium, p4=low/default)
   - Due date (natural language like "tomorrow", "next Friday", or specific date)
   - Project (default to inbox if not specified)
   - Any labels

2. Use the `mcp__todoist__add-tasks` tool to create the task

3. Confirm the task was created successfully and provide the task ID
