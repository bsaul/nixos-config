{ config, pkgs, ... }:

let
  home-manager = 
    builtins.fetchTarball 
    "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in
{
  # Add NUR (https://nur.nix-community.org/)
  # for firefox addons
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include home-manager module
      (import "${home-manager}/nixos")

    ];


  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Binary Cache for Haskell.nix
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    substituters = [
      "https://cache.nixos.org/"
      "https://cache.iog.io"
    ];
  };


  # Allow unfree/proprietary software
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
 
  # Enable fingerprint support
  services.fprintd.enable = true;

  # dbus = {
  #   enable = true;
  #   socketActivated = true;
  # };
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # displayManager.gdm.enable = true;
    # desktopManager.gnome.enable = true;
    desktopManager.xterm.enable = false;
    # startDbusSession = true;
    displayManager = {  
      defaultSession = "none+xmonad";
    };
  
    # Enable touchpad support.
    libinput.enable = true;

    # Enable xmonad.
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmobar
        # haskellPackages.dbus
      ];
    };
  };
  
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bsaul = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     shell = pkgs.zsh;
  };

  # Home manager settings
  home-manager.useGlobalPkgs = true;

  home-manager.users.bsaul = {
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

      # programming
      ## Agda
      haskellPackages.Agda
      ## Unison: https://github.com/ceedubs/unison-nix
      (builtins.getFlake (github:ceedubs/unison-nix)).packages.${builtins.currentSystem}.ucm

      # research, writing
      jabref
      libsForQt5.okular
      pandoc
      texlive.combined.scheme-full # Full LaTeX installation with all packages

      # conference
      zoom-us

      # "productivity"
      dropbox-cli
      # maestral currently fails to start
      # maybe due to https://github.com/samschott/maestral/issues/734 (?)
      # maestral
      # maestral-gui

      # developer tools
      vim
      wget
      nixpkgs-fmt
      ripgrep
      colordiff

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
      
      # terminal emulator
      kitty.enable = true;

      # Shells/Shell tools
      bat.enable = true;
      bash.enable = true;
      exa.enable = true;
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
        enable = true;
        userName  = "bsaul";
        userEmail = "bradleysaul@fastmail.com";
        extraConfig = {
          init = {
            defaultBranch = "main";
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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # additional at http://nur.nix-community.org/repos/rycee/
        ublock-origin
        darkreader
        onepassword-password-manager
        markdownload
      ];
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
      };
    };
    services = {
      espanso = {
        enable = true;
        settings = { matches = [
          { trigger = ":zn";
            replace = "{{timestamp}} ";
            vars = [
              { name = "timestamp";
                type = "date";
                params = {format = "%Y%m%d%H%M%S";};
              }
            ];
          }
          { trigger = ":nn";
            replace = "---\ntags: []\n---\n";
          }
        ];
        };
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ 
     _1password
     _1password-gui
  ];
  environment.sessionVariables.TERMINAL = ["kitty"];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #    enable = true;
  #    enableSSHSupport = true;
  # };

  programs = {
    zsh.enable = true;
    _1password = {
      enable = true;
      gid = 1000;
    };
    _1password-gui = {
      enable = true;
      gid = 1001;
      polkitPolicyOwners = [ "bsaul" ];
    };
  };

  # List services that you want to enable:

  services.gnome.gnome-keyring.enable = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

