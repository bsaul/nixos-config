 { config, pkgs, pkgs-unstable, ... }:
 {
  imports = [
    ./espanso.nix
    ./claude
  ];

    sops = {
      age.keyFile = "/home/bsaul/.config/sops/age/keys.txt"; # must have no password!

      defaultSopsFile = ./secrets.yaml;
      defaultSymlinkPath = "/run/user/1000/secrets";
      defaultSecretsMountPoint = "/run/user/1000/secrets.d";

      secrets.fastmail_smtp = {
        # sopsFile = ./secrets.yml.enc; # optionally define per-secret files
        path = "${config.sops.defaultSymlinkPath}/fastmail_smtp";
      };
    };

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
      BROWSER = "firefox";
      TERMINAL = "kitty";
      COLORTERM = "truecolor";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };

    home.packages = with pkgs; [

      # research, writing
      kdePackages.okular
      libsForQt5.poppler
      pandoc

      # messsaging/conference
      discord
      zulip
      zulip-term
      zoom-us

      # networking
      openconnect

      # "productivity"
      dropbox-cli
      libreoffice-qt
      slack

      planify
      obsidian
      tuba

      # developer tools
      vim
      wget
      nixpkgs-fmt
      ripgrep
      colordiff
      antigravity
      pkgs-unstable.claude-code
      jq
      
      # fonts
      julia-mono

      # machine tools
      acpi
      sops
      age

      # spellcheck
      # To get spellright VSCode extension working:
      # ln -s ~/.nix-profile/share/hunspell/* ~/.config/Code/Dictionaries
      hunspell
      hunspellDicts.en_US
    ];

    programs = {
      # Machine management
      home-manager.enable = true;
      htop.enable = true;

      # Displays
      autorandr.enable = true;

      # application launcher
      rofi.enable = true;

      # Shells/Shell tools
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
              IdentityAgent = "~/.1password/agent.sock";
            };
          };
        };
      };

      # Developer/Productivity tools

      git = {
        package = pkgs.gitFull;
        enable = true;
        settings = {
          user = {
            name  = "Bradley Saul";
            email = "bradleysaul@fastmail.com";
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
          # See directions here: https://git-send-email.io/#step-1  
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

    # got most of these ideas from:
    # https://shen.hong.io/nixos-for-philosophy-installing-firefox-latex-vscodium/
    firefox = {
      enable = true;
      profiles.default = {
          id = 0;
          name = "Default";
          settings = {
              "browser.startup.homepage" = "https://functionalstatistics.com";
              # Disable Pocket Integration
              "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
              "extensions.pocket.enabled" = false;
              "extensions.pocket.api" = "";
              "extensions.pocket.oAuthConsumerKey" = "";
              "extensions.pocket.showHome" = false;
              "extensions.pocket.site" = "";
          };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            # additional at http://nur.nix-community.org/repos/rycee/
            ublock-origin
            darkreader
            onepassword-password-manager
            markdownload
          ];
      };
     };

     chromium = {enable = true;};

    };

    services = {

      };
  }