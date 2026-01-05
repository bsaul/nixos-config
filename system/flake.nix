{
  description = "My nixos setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, nur, ... }@inputs: 

  
  {

    # Please replace my-nixos with your hostname
    nixosConfigurations.bsaul = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix

        sops-nix.nixosModules.sops

        nur.nixosModules.nur

        home-manager.nixosModules.home-manager
         {
           home-manager.useGlobalPkgs = true;
           home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
               nur.nixosModules.nur
            ];
           home-manager.users.bsaul.imports = [ sops-nix.homeManagerModules.sops ./home.nix ] ;

          }
      ];
    };
  };
}