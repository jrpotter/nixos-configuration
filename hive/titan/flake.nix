{
  description = "Remote machine - titan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    bootstrap.url = "github:jrpotter/bootstrap/v0.1.2";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
  };

  outputs = { bootstrap, home-manager, ... }: {
    nixosModules.default = { modulesPath, pkgs, lib, system, jrpotter, ... }: {
      imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
        home-manager.nixosModules.home-manager
      ];

      deployment.targetHost = "143.198.97.253";

      networking.hostName = "titan";

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

      system.stateVersion = "23.11";
    };
  };
}
