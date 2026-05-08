{ pkgs, pkgs-unstable, gitEmail, ... }:
{
  home.stateVersion = "22.05";

  home.shellAliases = {
    ".." = "cd ..";
    "ll" = "exa -l";
    "diff" = "colordiff";
    "cat" = "bat";
    "tmkeys" = "tmux display-popup -E 'tmux list-keys | fzf'";
  };

  home.sessionPath = [ "$HOME/.gemini/bin" ];

  home.sessionVariables = {
    COLORTERM = "truecolor";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.packages = with pkgs; [
    # research, writing
    pandoc

    # developer tools
    vim
    neovim
    wget
    nixpkgs-fmt
    ripgrep
    colordiff
    fzf
    jq
    pkgs-unstable.claude-code

    # secrets
    sops
    age

    # spellcheck
    hunspell
    hunspellDicts.en_US

    (writeShellScriptBin "agents" ''
      SESSION="agents"
      ROOT="$HOME/projects"
      HISTORY="$HOME/.agents-history"

      _add_window() {
        local proj="$1"
        tmux new-window -t "$SESSION" -n "$proj" -c "$ROOT/$proj"
        tmux send-keys -t "$SESSION:$proj" "nvim" C-m
        tmux split-window -t "$SESSION:$proj" -h -c "$ROOT/$proj"
        tmux send-keys -t "$SESSION:$proj" "claude" C-m
        tmux select-layout -t "$SESSION:$proj" main-vertical
      }

      # agents add <project> — add a window to the running session
      if [ "$1" = "add" ]; then
        shift
        if [ -n "$1" ]; then
          PROJ="$1"
        else
          PROJ=$(ls -1t "$ROOT" | fzf --prompt="add project > ")
        fi
        [ -z "$PROJ" ] && { echo "no project selected"; exit 1; }
        [ ! -d "$ROOT/$PROJ" ] && { echo "not found: $ROOT/$PROJ"; exit 1; }

        if ! tmux has-session -t "$SESSION" 2>/dev/null; then
          tmux new-session -d -s "$SESSION" -n "$PROJ" -c "$ROOT/$PROJ"
          tmux send-keys -t "$SESSION:$PROJ" "nvim" C-m
          tmux split-window -t "$SESSION:$PROJ" -h -c "$ROOT/$PROJ"
          tmux send-keys -t "$SESSION:$PROJ" "claude" C-m
          tmux select-layout -t "$SESSION:$PROJ" main-vertical
        else
          _add_window "$PROJ"
        fi

        # Append to history if not already listed
        touch "$HISTORY"
        grep -qxF "$PROJ" "$HISTORY" || echo "$PROJ" >> "$HISTORY"

        tmux select-window -t "$SESSION:$PROJ"
        exit 0
      fi

      if [ -f "$HISTORY" ] && [ "$1" != "new" ]; then
        echo "last session:"
        sed 's/^/  /' "$HISTORY"
        read -p "reuse? [Y/n/e=edit] " ans
        case "$ans" in
          n|N) PROJECTS=$(ls -1t "$ROOT" | fzf --multi --prompt="select projects > ") ;;
          e|E) ''${EDITOR:-vim} "$HISTORY"; PROJECTS=$(cat "$HISTORY") ;;
          *)   PROJECTS=$(cat "$HISTORY") ;;
        esac
      else
        PROJECTS=$(ls -1t "$ROOT" | fzf --multi --prompt="select projects > ")
      fi

      [ -z "$PROJECTS" ] && { echo "no projects selected"; exit 1; }
      echo "$PROJECTS" > "$HISTORY"

      tmux kill-session -t "$SESSION" 2>/dev/null

      FIRST_PROJ=$(echo "$PROJECTS" | head -n 1)
      tmux new-session -d -s "$SESSION" -n "$FIRST_PROJ" -c "$ROOT/$FIRST_PROJ"
      tmux send-keys -t "$SESSION:$FIRST_PROJ" "nvim" C-m
      tmux split-window -t "$SESSION:$FIRST_PROJ" -h -c "$ROOT/$FIRST_PROJ"
      tmux send-keys -t "$SESSION:$FIRST_PROJ" "claude" C-m
      tmux select-layout -t "$SESSION:$FIRST_PROJ" main-vertical

      echo "$PROJECTS" | tail -n +2 | while IFS= read -r proj; do
        _add_window "$proj"
      done

      tmux select-window -t "$SESSION:$FIRST_PROJ"
      if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
      else
        tmux attach-session -t "$SESSION"
      fi
    '')

    (writeShellScriptBin "tmux-git-info" ''
      cd "$1" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null
    '')

    (writeShellScriptBin "agents-attention" ''
      SESSION="agents"
      tmux has-session -t "$SESSION" 2>/dev/null || exit 0

      NEEDS=()
      while IFS= read -r pane_line; do
        win_idx="''${pane_line%%:*}"
        rest="''${pane_line#*:}"
        win_name="''${rest%%:*}"
        pane_id="''${rest#*:}"
        content=$(tmux capture-pane -t "$pane_id" -p -S -5 2>/dev/null)
        if echo "$content" | grep -qE '(Allow\?|\([Yy]\)es|\([Nn]\)o|\([Aa]\)lways)'; then
          NEEDS+=("$win_name")
          continue
        fi
      done < <(tmux list-panes -s -t "$SESSION" \
        -f '#{m:*claude*,#{pane_current_command}}' \
        -F '#{window_index}:#{window_name}:#{pane_id}')

      if [ ''${#NEEDS[@]} -gt 0 ]; then
        printf "''${NEEDS[*]}"
      fi
    '')

    (writeShellScriptBin "agents-worktree" ''
      SESSION="agents"
      ROOT="$HOME/projects"

      if [ -n "$1" ]; then
        PROJ="$1"
      else
        PROJ=$(ls -1t "$ROOT" | fzf --prompt="project > ")
      fi
      [ -z "$PROJ" ] && { echo "no project selected"; exit 1; }

      PROJ_DIR="$ROOT/$PROJ"
      cd "$PROJ_DIR" || { echo "project not found: $PROJ"; exit 1; }

      CHOICES=""

      while IFS= read -r line; do
        dir=$(echo "$line" | awk '{print $1}')
        [ "$dir" = "$PROJ_DIR" ] && continue
        branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
        name=$(basename "$dir")
        CHOICES+="existing:$name ($branch)"$'\n'
      done < <(git worktree list 2>/dev/null)

      if [ -d "plans" ]; then
        for plan in plans/*/; do
          [ -d "$plan" ] || continue
          plan_name=$(basename "$plan")
          if [ ! -d "wt-$plan_name" ]; then
            CHOICES+="plan:wt-$plan_name"$'\n'
          fi
        done
      fi

      CHOICES+="new:create new worktree"

      SELECTED=$(echo "$CHOICES" | fzf --prompt="worktree > " --delimiter=: --with-nth=2..)
      [ -z "$SELECTED" ] && exit 1

      TYPE="''${SELECTED%%:*}"
      REST="''${SELECTED#*:}"

      case "$TYPE" in
        existing)
          WT_NAME=$(echo "$REST" | awk '{print $1}')
          WT_DIR="$PROJ_DIR/$WT_NAME"
          ;;
        plan)
          WT_NAME=$(echo "$REST" | awk '{print $1}')
          git worktree add "$WT_NAME" -b "$WT_NAME" 2>/dev/null \
            || git worktree add "$WT_NAME" "$WT_NAME"
          WT_DIR="$PROJ_DIR/$WT_NAME"
          for f in libraries CLAUDE.md; do
            [ -f "$f" ] && [ -z "$(git ls-files "$f")" ] && cp "$f" "$WT_DIR/$f"
          done
          ;;
        new)
          read -p "branch name: " BRANCH
          [ -z "$BRANCH" ] && exit 1
          WT_NAME="wt-$BRANCH"
          git worktree add "$WT_NAME" -b "$WT_NAME"
          WT_DIR="$PROJ_DIR/$WT_NAME"
          for f in libraries CLAUDE.md; do
            [ -f "$f" ] && [ -z "$(git ls-files "$f")" ] && cp "$f" "$WT_DIR/$f"
          done
          ;;
      esac

      WIN_NAME="$PROJ/$WT_NAME"

      if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION" -n "$WIN_NAME" -c "$WT_DIR"
      else
        tmux new-window -t "$SESSION" -n "$WIN_NAME" -c "$WT_DIR"
      fi

      tmux send-keys -t "$SESSION:$WIN_NAME" "nvim" C-m
      tmux split-window -t "$SESSION:$WIN_NAME" -h -c "$WT_DIR"
      tmux send-keys -t "$SESSION:$WIN_NAME" "claude" C-m
      tmux select-layout -t "$SESSION:$WIN_NAME" main-vertical

      if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION:$WIN_NAME"
      else
        tmux attach-session -t "$SESSION:$WIN_NAME"
      fi
    '')
  ];

  programs = {
    home-manager.enable = true;
    htop.enable = true;

    tmux = {
      enable = true;
      prefix = "C-a";
      mouse = true;
      historyLimit = 50000;
      terminal = "xterm-256color";
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          extraConfig = "set -g @continuum-restore 'on'";
        }
      ];
      extraConfig = ''
        # True color support
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        setw -q -g utf8 on

        # Window numbering
        set -g base-index 1
        set -g pane-base-index 1
        set -g renumber-windows on

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

        # Pane splitting (keep current path)
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Vim-style pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Clear screen
        bind C-l send-keys 'clear' Enter

        # Claude export shortcut
        bind S send-keys 'claude export last' Enter

        # Agent window monitoring
        setw -g monitor-activity on
        setw -g monitor-silence 30
        set -g visual-activity off
        set -g status-interval 5
        set -g status-justify centre

        # Catppuccin Mocha color scheme
        set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
        set -g status-left "#[bg=#89b4fa,fg=#1e1e2e,bold] #S #[default] "
        set -g status-right "#[fg=#f38ba8,bold]#(agents-attention)#[default] #[fg=#cdd6f4]#(whoami) | %Y-%m-%d %H:%M #[bg=#89b4fa,fg=#1e1e2e,bold] #H "
        set -g status-left-length 50
        set -g status-right-length 100

        set -g window-status-current-style "bg=#89b4fa,fg=#1e1e2e,bold"
        set -g window-status-current-format " #I:#W #(tmux-git-info '#{pane_current_path}') "
        set -g window-status-format " #I:#W #[fg=#585b70]#(tmux-git-info '#{pane_current_path}')#[default] "
        setw -g window-status-activity-style "fg=#f9e2af,bold"
        setw -g window-status-bell-style "fg=#f38ba8,bold"

        set -g pane-border-style "fg=#313244"
        set -g pane-active-border-style "fg=#89b4fa"

        set -g message-style "bg=#313244,fg=#cdd6f4"
      '';
    };

    bat.enable = true;
    eza.enable = true;

    zsh = {
      enable = true;
      initContent = ''
        if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ]; then
          tmux new-session -A -s main
        fi
        PROMPT='%F{blue}%1~%f %# '
      '';
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      package = pkgs.gitFull;
      enable = true;
      settings = {
        user = {
          name = "Bradley Saul";
          email = gitEmail;
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOOzcpmBPWQ5qrPmxatXzc0WZ5BqLKv44UkQihnnYzV";
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        credential.helper = "store";
        sendemail = {
          smtpserver = "smtp.fastmail.com";
          smtpuser = "bradleysaul@fastmail.com";
          smtpencryption = "ssl";
          smtpserverport = 465;
        };
      };
      ignores = [
        ".DS_Store"
        ".direnv*"
        ".vscode/**"
        "/scratch/"
        "*.code-workspace"
      ];
    };

    vscode.enable = true;

    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Default";
        settings = {
          "browser.startup.homepage" = "https://functionalstatistics.com";
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "extensions.pocket.enabled" = false;
          "extensions.pocket.api" = "";
          "extensions.pocket.oAuthConsumerKey" = "";
          "extensions.pocket.showHome" = false;
          "extensions.pocket.site" = "";
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          darkreader
          onepassword-password-manager
          markdownload
        ];
      };
    };
  };
}
