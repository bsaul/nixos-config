{ config, pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./espanso-darwin.nix
    ./claude
  ];

  home.username = "bradley.saul";
  home.homeDirectory = "/Users/bradley.saul";
  home.stateVersion = "22.05";

  home.shellAliases = {
    ".." = "cd ..";
    "ll" = "exa -l";
    "diff" = "colordiff";
    "cat" = "bat";
  };

  home.sessionPath = [
    "$HOME/.gemini/bin"
  ];

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
    jq
    pkgs-unstable.claude-code

    # secrets
    sops
    age

    # spellcheck
    hunspell
    hunspellDicts.en_US
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

        # Catppuccin Mocha color scheme
        set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
        set -g status-left "#[bg=#89b4fa,fg=#1e1e2e,bold] #S #[default] "
        set -g status-right "#[fg=#cdd6f4] #(whoami) | %Y-%m-%d %H:%M #[bg=#89b4fa,fg=#1e1e2e,bold] #H "
        set -g status-left-length 50
        set -g status-right-length 100

        set -g window-status-current-style "bg=#89b4fa,fg=#1e1e2e,bold"
        set -g window-status-current-format " #I:#W "
        set -g window-status-format " #I:#W "

        set -g pane-border-style "fg=#313244"
        set -g pane-active-border-style "fg=#89b4fa"

        set -g message-style "bg=#313244,fg=#cdd6f4"
      '';
    };

    bat.enable = true;
    bash.enable = true;
    eza.enable = true;

    zsh = {
      enable = true;
      initContent = ''
        # Auto-launch tmux if not already inside a tmux session
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

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      # https://developer.1password.com/docs/ssh/
      matchBlocks = {
        "*" = {
          extraOptions = {
            IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
      };
    };

    git = {
      package = pkgs.gitFull;
      enable = true;
      settings = {
        user = {
          name = "Bradley Saul";
          email = "bradleysaul@fastmail.com";
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOOzcpmBPWQ5qrPmxatXzc0WZ5BqLKv44UkQihnnYzV";
        };
        gpg = {
          format = "ssh";
          ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
        commit = {
          gpgsign = true;
        };
        init = {
          defaultBranch = "main";
        };
        push = {
          autoSetupRemote = true;
        };
        credential = {
          helper = "store";
        };
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

    vscode = {
      enable = true;
    };

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
