{ config, pkgs, ... }:

{
  home.file = {
    # Rules
    ".claude/rules/writing-style.md".source = ./rules/writing-style.md;
    ".claude/rules/agda-style.md".source = ./rules/agda-style.md;
    ".claude/rules/agda-development.md".source = ./rules/agda-development.md;

    # Skills
    ".claude/skills/nixos-rebuild/SKILL.md".source = ./skills/nixos-rebuild.md;
    ".claude/skills/nixos-check/SKILL.md".source = ./skills/nixos-check.md;
    ".claude/skills/update-flake/SKILL.md".source = ./skills/update-flake.md;
    ".claude/skills/add-todoist-task/SKILL.md".source = ./skills/add-todoist-task.md;
    ".claude/skills/ventilated-prose/SKILL.md".source = ./skills/ventilated-prose.md;
    ".claude/skills/agda-gotchas/SKILL.md".source = ./skills/agda-gotchas.md;
    ".claude/skills/agda-style/SKILL.md".source = ./skills/agda-style.md;
    ".claude/skills/agda-typecheck/SKILL.md".source = ./skills/agda-typecheck.md;
    ".claude/skills/review-rules/SKILL.md".source = ./skills/review-rules.md;
    ".claude/skills/new-project/SKILL.md".source = ./skills/new-project.md;
    ".claude/skills/launch-plan/SKILL.md".source = ./skills/launch-plan.md;

    # Agents
    ".claude/agents/agda-developer.md".source = ./agents/agda-developer.md;
    ".claude/agents/agda-researcher.md".source = ./agents/agda-researcher.md;
    ".claude/agents/project-manager.md".source = ./agents/project-manager.md;
    ".claude/agents/math-reasoner.md".source = ./agents/math-reasoner.md;

    # Settings
    ".claude/settings.json" = {
      force = true;
      text = builtins.toJSON {
        preferences = {
          theme = "dark";
        };
        alwaysThinkingEnabled = true;
        statusLine = {
          type = "command";
          command = "~/.claude/statusline.sh";
        };
      };
    };

    # Statusline script
    ".claude/statusline.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        jq -r '.model.display_name // "unknown"'
      '';
    };
  };
}
