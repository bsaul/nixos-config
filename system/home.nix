 { config, pkgs, ... }:
 {
  imports = [
    ./espanso.nix
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
    };

    home.file = {
      ".claude/skills/nixos-rebuild/SKILL.md".source = ./claude-skills/nixos-rebuild.md;
      ".claude/skills/nixos-check/SKILL.md".source = ./claude-skills/nixos-check.md;
      ".claude/skills/update-flake/SKILL.md".source = ./claude-skills/update-flake.md;
      ".claude/skills/add-todoist-task/SKILL.md".source = ./claude-skills/add-todoist-task.md;
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
      ".claude/statusline.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          data=$(cat)

          # Extract fields
          model=$(echo "$data" | jq -r '.model.display_name // "unknown"')
          thinking=$(echo "$data" | jq -r '.thinking // empty')
          context_pct=$(echo "$data" | jq -r '.context_percent // empty')
          transcript=$(echo "$data" | jq -r '.transcript_path // empty')
          agent=$(echo "$data" | jq -r '.agent_name // empty')

          # Colors
          reset="\033[0m"
          bold="\033[1m"
          dim="\033[2m"
          cyan="\033[36m"
          yellow="\033[33m"
          green="\033[32m"
          magenta="\033[35m"

          # Line 1: model, thinking, context
          line1="''${bold}''${cyan}$model''${reset}"
          [ -n "$thinking" ] && line1+=" ''${dim}thinking:''${reset} ''${green}$thinking''${reset}"
          [ -n "$context_pct" ] && line1+=" ''${dim}ctx:''${reset} ''${yellow}''${context_pct}%''${reset}"

          # Line 2: agent and transcript
          line2=""
          [ -n "$agent" ] && line2+="''${magenta}$agent''${reset}"
          if [ -n "$transcript" ]; then
            [ -n "$line2" ] && line2+=" "
            line2+="''${dim}$transcript''${reset}"
          fi

          echo -e "$line1"
          [ -n "$line2" ] && echo -e "$line2"
        '';
      };
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
      claude-code
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
      };
      bat.enable = true;
      bash.enable = true;
      eza.enable = true;
      zsh.enable = true;
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
        extensions.packages = with config.nur.repos.rycee.firefox-addons; [
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