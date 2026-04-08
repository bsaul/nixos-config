{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "TGTRWE-LT-0308";

  system.primaryUser = "bradley.saul";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "none";
    };
    casks = [
      "1password"
      "zoom"
    ];
  };

  # Determinate Systems manages the Nix installation; disable nix-darwin's management
  nix.enable = false;

  users.users."bradley.saul" = {
    name = "bradley.saul";
    home = "/Users/bradley.saul";
  };

  system.stateVersion = 5;
}
