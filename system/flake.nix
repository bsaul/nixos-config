{
  description = "My nixos setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, nix-darwin, nur, ... }@inputs:
  
  {

    darwinConfigurations."TGTRWE-LT-0308" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./darwin.nix

        { nixpkgs.overlays = [ nur.overlays.default ]; }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
          };
          home-manager.backupFileExtension = "backup";
          home-manager.users."bradley.saul".imports = [ ./home-darwin.nix ];
        }
      ];
    };

    # Please replace my-nixos with your hostname
    nixosConfigurations.bsaul = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix

        sops-nix.nixosModules.sops

        # NUR overlay - access packages via pkgs.nur.repos.<username>.<package>
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        home-manager.nixosModules.home-manager
         {
           home-manager.useGlobalPkgs = true;
           home-manager.extraSpecialArgs = {
             pkgs-unstable = import nixpkgs-unstable {
               system = "x86_64-linux";
               config.allowUnfree = true;
             };
           };
           home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
           home-manager.users.bsaul.imports = [ ./home.nix ] ;

          }
      ];
    };
  };
}