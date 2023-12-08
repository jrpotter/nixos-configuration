{
  description = "Local machine - framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    bootstrap = {
      url = "github:jrpotter/bootstrap/v0.1.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { bootstrap, home-manager, ... }: {
    nixosModules.default = { pkgs, system, ... }:
      let
        jrpotter-home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.jrpotter = import ./jrpotter;

          # Used to pass non-default parameters to submodules.
          extraSpecialArgs = {
            inherit system;
            bootstrap = bootstrap.packages.${system}.default;
          };
        };
      in
      {
        imports = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          { home-manager = jrpotter-home-manager; }
        ];
      };
  };
}
