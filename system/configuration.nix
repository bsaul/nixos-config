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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree/proprietary software
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bsaul = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
    home.packages = with pkgs; [

      # Programming
      haskellPackages.Agda

      # Research/Writing
      jabref
      libsForQt5.okular
      texlive.combined.scheme-full # Full LaTeX installation with all packages


      # "Productivity"
      dropbox-cli
      # maestral currently fails to start
      # maybe due to https://github.com/samschott/maestral/issues/734 (?)
      # maestral
      # maestral-gui

      # Developer tools
      vim
      wget
      nixpkgs-fmt
      ripgrep
      colordiff

      # Spellchecking
      # To get spellright VSCode extension working:
      # ln -s ~/.nix-profile/share/hunspell/* ~/.config/Code/Dictionaries
      hunspell
      hunspellDicts.en_US
    ];

    programs = {
      # Machine management
      home-manager.enable = true;
      htop.enable = true;
      
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #    enable = true;
  #    enableSSHSupport = true;
  # };

  programs = {
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

  # services.gnome.gnome-keyring.enable = true;
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

