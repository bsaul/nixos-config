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
        tmux new-window -t "$SESSION" -n "$proj" -c "$ROOT/$proj"
        tmux send-keys -t "$SESSION:$proj" "nvim" C-m
        tmux split-window -t "$SESSION:$proj" -h -c "$ROOT/$proj"
        tmux send-keys -t "$SESSION:$proj" "claude" C-m
        tmux select-layout -t "$SESSION:$proj" main-vertical
      done

      tmux select-window -t "$SESSION:$FIRST_PROJ"
      if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
      else
        tmux attach-session -t "$SESSION"
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
        set -g status-right "#[fg=#cdd6f4] #(whoami) | %Y-%m-%d %H:%M #[bg=#89b4fa,fg=#1e1e2e,bold] #H "
        set -g status-left-length 50
        set -g status-right-length 100

        set -g window-status-current-style "bg=#89b4fa,fg=#1e1e2e,bold"
        set -g window-status-current-format " #I:#W "
        set -g window-status-format " #I:#W "
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
