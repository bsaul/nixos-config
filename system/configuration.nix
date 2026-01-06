{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

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



  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

 
  # Enable fingerprint support
  services.fprintd.enable = true;


  # Enable touchpad support.
  services.libinput.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
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

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  




  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;  # provides the JACK server shim
  };

  # Add docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bsaul = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" "audio" ]; # Enable ‘sudo’ for the user.
     shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ 
     _1password-cli
     _1password-gui
  ];
  environment.sessionVariables.TERMINAL = ["kitty"];




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




  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

