{
  description = "Local machine - framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    bootstrap.url = "github:jrpotter/bootstrap/v0.1.2";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { bootstrap, home-manager, ... }: {
    nixosModules.default = { pkgs, system, jrpotter, ... }: {
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
          inherit system;
          bootstrap = bootstrap.packages.${system}.default;
          stateVersion = "23.05";
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

      system.stateVersion = "23.05";
    };
  };
}
