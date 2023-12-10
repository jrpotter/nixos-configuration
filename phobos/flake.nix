{
  description = "Remote machine - phobos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    boardwise.url = "github:boardwise-gg/website/v0.1.0";
    coach-scraper.url = "github:boardwise-gg/coach-scraper/58815d3ae5a69cac12436a01e77019a5ac5d16a7";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { boardwise, coach-scraper, sops-nix, ... }: {
    nixosModules.default = { modulesPath, pkgs, lib, system, ... }: {
      imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
        sops-nix.nixosModules.sops
      ];

      deployment.targetHost = "164.92.107.155";

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
          # TYPE     DATABASE     USER     ADDRESS         METHOD
            local    all          all                      trust
            host     all          all      127.0.0.1/32    trust
        '';
      };

      systemd.services.boardwise = {
        enable = true;
        description = "BoardWise Server";
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
        serviceConfig = {
          Environment = [
            "PORT=80"
            "DATABASE_URL=ecto://postgres:postgres@localhost/boardwise"
          ];
          EnvironmentFile = "/run/secrets/SECRET_KEY_BASE";
          ExecStartPre = "${boardwise.packages.${system}.app}/bin/migrate";
          ExecStart = "${boardwise.packages.${system}.app}/bin/boardwise start";
          Restart = "on-failure";
        };
      };

      environment.systemPackages = [
        coach-scraper.packages.${system}.app
      ];

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets.SECRET_KEY_BASE = {};

      system.stateVersion = "23.11";
    };
  };
}
