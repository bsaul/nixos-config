---
name: new-project
description: Create a new project from a template
disable-model-invocation: true
user-invocable: true
---

Create a new project from a nix flake template:

1. Ask the user for:
   - Project name (used as the directory name under `~/projects/`)
   - Template to use (one of: lagda, haskell, monadnock, research, funding, presentation)

2. Run the following commands in sequence:
   ```sh
   mkdir -p ~/projects/<project-name>
   cd ~/projects/<project-name>
   nix flake init -t ~/projects/templates#<template>
   direnv allow
   git init
   ```

3. Report success and show the project path.
