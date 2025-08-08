# `nixos` configuration

My `nixos` configuration.

## Updating `nixpkgs`

```sh
sudo nix-channel --list
```

```sh
sudo nix-channel --add https://nixos.org/channels/SETTHIS nixos
sudo nix-channel --update
sudo nixos-rebuild --upgrade boot
```
