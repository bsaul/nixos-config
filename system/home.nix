 { config, pkgs, ... }:
 {

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

    home.sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };

    home.packages = with pkgs; [

      # research, writing
      libsForQt5.okular
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
      maestral
      maestral-gui

      # developer tools
      vim
      wget
      nixpkgs-fmt
      ripgrep
      colordiff
      
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
        # enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      ssh = {
        enable = true;
        # https://developer.1password.com/docs/ssh/
        extraConfig = 
        ''
        Host *
               IdentityAgent ~/.1password/agent.sock
        '';
      };

      # Developer/Productivity tools

      git = {
        package = pkgs.gitFull;
        enable = true;
        userName  = "Bradley Saul";
        userEmail = "bradleysaul@fastmail.com";
        extraConfig = {
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
            # config.sops.secrets.fastmail_smtp.path;
          };
        };
        ignores = [
          ".DS_Store"
          ".direnv*"
          ".vscode/**"
        ];
      };
      vscode = {
        enable = true;
      };
    };

    # got most of these ideas from:
    # https://shen.hong.io/nixos-for-philosophy-installing-firefox-latex-vscodium/
    programs.firefox = {
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
        extensions = with config.nur.repos.rycee.firefox-addons; [
            # additional at http://nur.nix-community.org/repos/rycee/
            ublock-origin
            darkreader
            onepassword-password-manager
            markdownload
          ];
      };
    };
    services = {
      espanso = {
        enable = true;
        matches = {
            base = {
              matches = [
                {
                  trigger = ":zn";
                  replace = "{{timestamp}} ";
                }
                { 
                  trigger = ":nn";
                  replace = "---\ntags: []\n---\n";
                }
                {
                  trigger = ":eqsetoid";
                  replace = "begin\n ? \n≈⟨ ? ⟩\n ? ∎";
                }
                {
                  trigger = ":step";
                  replace = "\n≈⟨ ? ⟩\n ?";
                }
              ];
            };
            global_vars = {
              global_vars = [
                {
                  name = "currentdate";
                  type = "date";
                  params = {format = "%d/%m/%Y";};
                }
                {
                  name = "currenttime";
                  type = "date";
                  params = {format = "%R";};
                }
                { 
                  name = "timestamp";
                  type = "date";
                  params = {format = "%Y%m%d%H%M%S";};
                }
              ];
            };
          };
        };
      };
  }