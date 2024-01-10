{ system, pkgs, lib, ... }:
let
  boardwise = builtins.getFlake
    "github:boardwise-gg/website/db73e3b4f06659fd477be8e76594c01a185f1496";
  coach-scraper = builtins.getFlake
    "github:boardwise-gg/coach-scraper/58815d3ae5a69cac12436a01e77019a5ac5d16a7";
in
{
  services = {
    nginx.virtualHosts."www.boardwise.gg" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "boardwise.gg" ];
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:4000";
      };
    };
    postgresql = {
      package = pkgs.postgresql_15;
      ensureDatabases = [ "boardwise" ];
      authentication = lib.mkOverride 10 ''
        # TYPE     DATABASE     USER     ADDRESS         METHOD
          local    all          all                      trust
          host     all          all      127.0.0.1/32    trust
      '';
    };
  };

  systemd.services.boardwise = {
    enable = true;
    description = "BoardWise Server";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Environment = [
        "DATABASE_URL=ecto://postgres:postgres@localhost/boardwise"
      ];
      EnvironmentFile = "/run/secrets/BOARDWISE_SECRET_KEY_BASE";
      ExecStartPre = "${boardwise.packages.${system}.app}/bin/migrate";
      ExecStart = "${boardwise.packages.${system}.app}/bin/boardwise start";
      Restart = "on-failure";
    };
  };

  environment.systemPackages = [
    coach-scraper.packages.${system}.app
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.BOARDWISE_SECRET_KEY_BASE = {};
  };
}
