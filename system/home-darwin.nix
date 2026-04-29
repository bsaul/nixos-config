{ pkgs, ... }:
{
  imports = [
    ./espanso-darwin.nix
    ./claude
    ./home-common.nix
  ];

  home.username = "bradley.saul";
  home.homeDirectory = "/Users/bradley.saul";

  home.packages = with pkgs; [
    uv
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".extraOptions.IdentityAgent =
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  programs.git.settings.gpg.ssh.program =
    "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
}
