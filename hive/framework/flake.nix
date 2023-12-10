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
    nixosModules.default = { pkgs, system, jrpotter, ... }:
      let
        # This value determines the NixOS and home-manager release from which
        # the default settings for stateful data, like file locations and
        # database versions on your system were taken. This should probably
        # never change.
        stateVersion = "23.05";
      in
      {
        imports = [
          ./hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.jrpotter = jrpotter;

          # Used to pass non-default parameters to submodules.
          extraSpecialArgs = {
            inherit system stateVersion;
            bootstrap = bootstrap.packages.${system}.default;
          };
        };

        users.users.jrpotter = {
          isNormalUser = true;
          extraGroups = [
            "docker"
            "networkmanager"
            "wheel"
          ];
        };

        system.stateVersion = stateVersion;
      };
  };
}
