# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository using flakes.
It manages system configuration,
home-manager settings,
and secrets via sops-nix.

## Key Commands

### Building and Applying Configuration

```sh
# Check configuration for errors (always do this first)
nix flake check /home/bsaul/nixos-config/system

# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake /home/bsaul/nixos-config/system

# Update flake inputs
nix flake update /home/bsaul/nixos-config/system
```

### Available Claude Skills

The repository includes custom Claude skills (installed via home-manager):
- `/nixos-rebuild` - Rebuild and switch NixOS configuration
- `/nixos-check` - Check flake for syntax errors
- `/update-flake` - Update flake inputs

## Architecture

### Flake Structure (`system/flake.nix`)

- **nixpkgs**: NixOS 25.11 channel
- **home-manager**: User environment management (release-25.11)
- **sops-nix**: Secret management with age encryption
- **NUR**: Nix User Repository overlay (used for Firefox extensions)

### Configuration Files

| File | Purpose |
|------|---------|
| `system/configuration.nix` | System-level NixOS settings (boot, networking, services, system packages) |
| `system/home.nix` | User packages, programs, and dotfiles via home-manager |
| `system/hardware-configuration.nix` | Auto-generated hardware config |
| `system/espanso.nix` | Text expansion configuration |
| `system/secrets.yaml` | Encrypted secrets (sops) |
| `system/claude/default.nix` | Claude Code configuration (rules, skills, agents, settings) |

### Secrets Management

Secrets use sops-nix with age encryption:

- Age key location: `/home/bsaul/.config/sops/age/keys.txt`
- Secrets mount: `/run/user/1000/secrets`

### Claude Code Integration

Home-manager deploys Claude Code configuration via `system/claude/default.nix`:

- Rules: `~/.claude/rules/*.md` (source: `system/claude/rules/`)
- Skills: `~/.claude/skills/*/SKILL.md` (source: `system/claude/skills/`)
- Agents: `~/.claude/agents/*.md` (source: `system/claude/agents/`)
- Settings and statusline configured in `system/claude/default.nix`

## Writing Style

Use ventilated prose (semantic line breaks) for all markdown files.
Break lines at natural pauses,
keeping one idea per line.
This improves git diffs and editing.
