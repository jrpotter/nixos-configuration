{
  description = "NixOS Flake";

  inputs = {
    bootstrap.url = "github:jrpotter/bootstrap/v0.1.2";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { nixpkgs, home-manager, bootstrap, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        # Modules can be attribute sets or a function that returns an attribute set.
        # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.jrpotter = import ./jrpotter;
              # Used to pass non-default parameters to submodules.
              extraSpecialArgs = {
                inherit system;
                bootstrap = bootstrap.packages.${system}.default;
              };
            };
          }
        ];
      };
    };
}
