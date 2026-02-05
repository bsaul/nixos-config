---
name: nixos-check
description: Check NixOS flake configuration for syntax errors
disable-model-invocation: true
user-invocable: true
---

Check the NixOS flake configuration:

1. Run `nix flake check /home/bsaul/nixos-config/system`
2. Report any syntax errors, warnings, or issues
3. If successful, confirm the configuration is valid
