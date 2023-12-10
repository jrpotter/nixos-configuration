{ system, stateVersion, sops-nix, modulesPath, pkgs, lib, ... }:
let
  boardwise = builtins.getFlake
    "github:boardwise-gg/website/c605a09c56234b2c2c0e4593da8f3b798723a5d7";
  coach-scraper = builtins.getFlake
    "github:boardwise-gg/coach-scraper/58815d3ae5a69cac12436a01e77019a5ac5d16a7";
in
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    sops-nix.nixosModules.sops
  ];

  deployment.targetHost = null;

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

  system.stateVersion = stateVersion;
}
