---
name: update-flake
description: Update NixOS flake inputs to their latest versions
disable-model-invocation: true
user-invocable: true
---

Update the NixOS flake inputs:

1. Run `nix flake update /home/bsaul/nixos-config/system`
2. Show which inputs were updated and their new versions
3. Recommend running `/nixos-check` to verify the configuration is still valid
4. Suggest testing with `nixos-rebuild test` before switching
