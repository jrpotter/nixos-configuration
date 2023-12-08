{
  description = "Remote machine - phobos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    boardwise = {
      url = "github:boardwise-gg/website/v0.1.0";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { boardwise, sops-nix, ... }: {
    nixosModules.default = { modulesPath, pkgs, lib, system, ... }: {
      imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
        sops-nix.nixosModules.sops
      ];

      deployment.targetHost = "146.190.127.180";

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

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets.example-key = {};
      sops.secrets."myservice/my_subdir/my_secret" = {};

      system.stateVersion = "23.11";
    };
  };
}
