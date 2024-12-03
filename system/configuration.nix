{ config, pkgs, ... }:

let
  # home-manager = 
  #   builtins.fetchTarball 
  #   "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  # sops-nix = 
  #   builtins.fetchTarball
  #   "https://github.com/Mic92/sops-nix/archive/master.tar.gz";

in
{
  # Add NUR (https://nur.nix-community.org/)
  # for firefox addons
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = 
  #     import 
  #     (builtins.fetchTarball 
  #     "https://github.com/nix-community/NUR/archive/master.tar.gz")
  #     {
  #     inherit pkgs;
  #   };
  # };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include home-manager module
      # (import "${home-manager}/nixos")
      # <home-manager/modules/sops>
      
      # Include sops module
      # <sops-nix/modules/sops>

      # Use cachix
      ./cachix.nix
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


  # sops = {
  #   # age.keyFile = "/home/<your username>/.config/sops/age/keys.txt"; # must have no password!

  #   defaultSopsFile = ./secrets.yaml;
  #   defaultSymlinkPath = "/run/user/1000/secrets";
  #   defaultSecretsMountPoint = "/run/user/1000/secrets.d";

  #   # secrets.fastmail_smtp_key_key = {
  #   #   # sopsFile = ./secrets.yml.enc; # optionally define per-secret files
  #   #   path = "${config.sops.defaultSymlinkPath}/fastmail_smtp_key";
  #   # };
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "bsaul"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
 
  # Enable fingerprint support
  services.fprintd.enable = true;

  # services.picom.enable = true;
  # dbus = {
  #   enable = true;
  #   socketActivated = true;
  # };
  # Enable touchpad support.
  services.libinput.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    desktopManager.xterm.enable = false;
    # startDbusSession = true;
    # displayManager = {  
    #   defaultSession = "none+xmonad";
    # };

    # Enable xmonad.
    # firefox/vscode are REALLY laggy using xmonad
    # and I can't figure out why
    # windowManager.xmonad = {
    #   enable = true;
    #   enableContribAndExtras = true;
    #   extraPackages = haskellPackages: [
    #     haskellPackages.xmonad-contrib
    #     haskellPackages.xmobar
    #     # haskellPackages.dbus
    #   ];
    #   config = ./xmonad.hs;
    # };
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
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Add docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bsaul = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
     shell = pkgs.zsh;
  };

  # sops = {
  #   age.keyFile = "/home/bsaul/.config/sops/age/keys.txt";

  #   defaultSopsFile = ./secrets.yaml;
  #   defaultSymlinkPath = "/run/user/1000/secrets";
  #   # defaultSecretsMountPoint = "/run/user/1000/secrets.d";

  #   # secrets.fastmail_smtp_key = {
  #   #   path = "${config.sops.defaultSymlinkPath}/fastmail_smtp_key";
  #   # };
  # };

  # Home manager settings
  home-manager.useGlobalPkgs = true;
  # home-manager.sharedModules = [
  #    (import "${sops-nix}/modules/home-manager").sops
  #   # (sops-nix.homeManagerModules.sops
  # ];

  # home-manager.users.bsaul = {
  #   home.stateVersion = "22.05";
  #   home.shellAliases = {
  #     ".." = "cd ..";
  #     "ll" = "exa -l";
  #     "diff" = "colordiff";
  #     "cat" = "bat";
  #   };

  #   home.sessionVariables = {
  #     BROWSER = "firefox";
  #     TERMINAL = "kitty";
  #   };

  #   home.packages = with pkgs; [

  #     # research, writing
  #     libsForQt5.okular
  #     libsForQt5.poppler
  #     pandoc

  #     # messsaging/conference
  #     discord
  #     zulip
  #     zulip-term
  #     zoom-us

  #     # networking
  #     openconnect

  #     # "productivity"
  #     dropbox-cli
  #     libreoffice-qt
  #     slack
  #     maestral
  #     maestral-gui

  #     # developer tools
  #     vim
  #     wget
  #     nixpkgs-fmt
  #     ripgrep
  #     colordiff
      
  #     # fonts
  #     julia-mono

  #     # machine tools
  #     acpi
  #     sops
  #     age

  #     # spellcheck
  #     # To get spellright VSCode extension working:
  #     # ln -s ~/.nix-profile/share/hunspell/* ~/.config/Code/Dictionaries
  #     hunspell
  #     hunspellDicts.en_US
  #   ];

  #   programs = {
  #     # Machine management
  #     home-manager.enable = true;
  #     htop.enable = true;

  #     # Displays
  #     autorandr.enable = true;

  #     # application launcher
  #     rofi.enable = true;
      
  #     # terminal emulator
  #     kitty.enable = true;

  #     # Shells/Shell tools
  #     bat.enable = true;
  #     bash.enable = true;
  #     eza.enable = true;
  #     zsh.enable = true;
  #     direnv = {
  #       enable = true;
  #       # enableBashIntegration = true;
  #       enableZshIntegration = true;
  #       nix-direnv.enable = true;
  #     };

  #     ssh = {
  #       enable = true;
  #       # https://developer.1password.com/docs/ssh/
  #       extraConfig = 
  #       ''
  #       Host *
  #              IdentityAgent ~/.1password/agent.sock
  #       '';
  #     };

  #     # Developer/Productivity tools

  #     git = {
  #       package = pkgs.gitFull;
  #       enable = true;
  #       userName  = "Bradley Saul";
  #       userEmail = "bradleysaul@fastmail.com";
  #       extraConfig = {
  #         init = {
  #           defaultBranch = "main";
  #         };
  #         push = {
  #           autoSetupRemote = true;
  #         };
  #         # See directions here: https://git-send-email.io/#step-1  
  #         sendemail = {
  #           smtpserver = "smtp.fastmail.com";
  #           smtpuser = "bradleysaul@fastmail.com";
  #           smtpencryption = "ssl";
  #           smtpserverport = 465;
  #           # smtppass = config.sops.secrets.fastmail_smtp_key.path;
  #         };
  #       };
  #       ignores = [
  #         ".DS_Store"
  #         ".direnv*"
  #         ".vscode/**"
  #       ];
  #     };
  #     vscode = {
  #       enable = true;
  #     };
  #   };

  #   # got most of these ideas from:
  #   # https://shen.hong.io/nixos-for-philosophy-installing-firefox-latex-vscodium/
  #   programs.firefox = {
  #     enable = true;
  #     profiles.default = {
  #         id = 0;
  #         name = "Default";
  #         settings = {
  #             "browser.startup.homepage" = "https://functionalstatistics.com";
  #             # Disable Pocket Integration
  #             "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
  #             "extensions.pocket.enabled" = false;
  #             "extensions.pocket.api" = "";
  #             "extensions.pocket.oAuthConsumerKey" = "";
  #             "extensions.pocket.showHome" = false;
  #             "extensions.pocket.site" = "";
  #         };
  #       extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #           # additional at http://nur.nix-community.org/repos/rycee/
  #           ublock-origin
  #           darkreader
  #           onepassword-password-manager
  #           markdownload
  #         ];
  #     };
  #   };
  #   services = {
  #     espanso = {
  #       enable = true;
  #       matches = {
  #           base = {
  #             matches = [
  #               {
  #                 trigger = ":zn";
  #                 replace = "{{timestamp}} ";
  #               }
  #               { 
  #                 trigger = ":nn";
  #                 replace = "---\ntags: []\n---\n";
  #               }
  #               {
  #                 trigger = ":eqsetoid";
  #                 replace = "begin\n ? \n≈⟨ ? ⟩\n ? ∎";
  #               }
  #               {
  #                 trigger = ":step";
  #                 replace = "\n≈⟨ ? ⟩\n ?";
  #               }
  #             ];
  #           };
  #           global_vars = {
  #             global_vars = [
  #               {
  #                 name = "currentdate";
  #                 type = "date";
  #                 params = {format = "%d/%m/%Y";};
  #               }
  #               {
  #                 name = "currenttime";
  #                 type = "date";
  #                 params = {format = "%R";};
  #               }
  #               { 
  #                 name = "timestamp";
  #                 type = "date";
  #                 params = {format = "%Y%m%d%H%M%S";};
  #               }
  #             ];
  #           };
  #         };
  #       };
  #     };
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ 
     _1password-cli
     _1password-gui
    #  coreutils-full
    # (python3.withPackages(ps: with ps; [ dbus-python ]))
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
    };
    _1password-gui = {
      enable = true;
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

