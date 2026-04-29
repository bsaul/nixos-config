{ config, pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./espanso.nix
    ./claude
    ./home-common.nix
  ];

  sops = {
    age.keyFile = "/home/bsaul/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    secrets.fastmail_smtp = {
      path = "${config.sops.defaultSymlinkPath}/fastmail_smtp";
    };
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  home.packages = with pkgs; [
    # research, writing
    kdePackages.okular
    libsForQt5.poppler

    # messaging/conference
    discord
    zulip
    zulip-term
    zoom-us

    # networking
    openconnect

    # productivity
    dropbox-cli
    libreoffice-qt
    slack
    planify
    obsidian
    tuba

    # developer tools
    antigravity

    # fonts
    julia-mono

    # machine tools
    acpi
  ];

  programs = {
    autorandr.enable = true;
    rofi.enable = true;
    chromium.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*".extraOptions.IdentityAgent = "~/.1password/agent.sock";
    };
  };

  programs.git.settings.gpg.ssh.program =
    "/run/current-system/sw/bin/op-ssh-sign";
}
