{
  description = "Phobos machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    boardwise = {
      url = "github:boardwise-gg/website/v0.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { boardwise, ... }: {
    nixosModules.default = { modulesPath, pkgs, lib, system, ... }: {
      imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
      ];

      deployment = {
        targetHost = "146.190.127.180";
      };

      networking = {
        hostName = "phobos";
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 443 ];
        };
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
        ensureDatabases = [ "boardwise" ];
        authentication = lib.mkOverride 10 ''
          # TYPE     DATABASE     USER     ADDRESS     METHOD
            local    all          all                  trust
        '';
      };

      environment = {
        systemPackages = [
          boardwise.packages.${system}.app
        ];
        variables = {
          DATABASE_URL="ecto://postgres:postgres@localhost/boardwise";
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
