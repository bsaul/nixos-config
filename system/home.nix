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