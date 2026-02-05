---
name: nixos-rebuild
description: Rebuild and switch the NixOS system configuration
disable-model-invocation: true
user-invocable: true
---

Rebuild the NixOS system configuration:

1. Run `sudo nixos-rebuild switch --flake /home/bsaul/nixos-config/system`
2. Report any errors or warnings encountered
3. If successful, confirm the new configuration is active
4. Show a summary of what changed
