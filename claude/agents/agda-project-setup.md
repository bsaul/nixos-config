# Agda Project Setup for agda-developer Agent

This document explains how to structure Agda projects
so the agda-developer agent can correctly access
the Nix-provided standard library.

## Problem

The agda-mcp server needs to run in your project's Nix environment
to access the correct Agda version and standard library.
Without proper setup,
it falls back to searching ~/.agda/ or the web,
which is unreliable.

## Solution

Each Agda project should:

1. Use a Nix flake that provides Agda + stdlib
2. Use direnv to automatically load the environment
3. Start Claude Code from within the project directory

## Example Project Structure

```
my-agda-project/
├── flake.nix          # Provides Agda + standard-library
├── .envrc             # Loads the Nix environment
├── libraries          # Points to the stdlib (optional)
└── src/
    └── MyModule.agda
```

## Example flake.nix

```nix
{
  description = "My Agda Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            (agda.withPackages (p: [ p.standard-library ]))
          ];
        };
      });
}
```

## Example .envrc

```bash
use flake
```

## Workflow

1. Create project with flake.nix and .envrc
2. Run `direnv allow` in the project directory
3. Start `claude-code` from within the project
4. The agda-mcp server will inherit the Nix environment

## Verification

To verify the setup works:

```bash
cd my-agda-project
agda --version  # Should show Nix-provided Agda
agda -l standard-library --show-library-dir  # Should show Nix store path
```

## Key Points

- The stdlib is at a Nix store path like `/nix/store/xxx-agda-standard-library-2.0/`
- You don't need a global ~/.agda/ configuration
- Each project is isolated with its own Agda + stdlib versions
- The agent will never search the web for stdlib code
