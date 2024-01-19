{ system, pkgs, lib, ... }:
let
  boardwise = builtins.getFlake
    "github:boardwise-gg/website/0d5a66c604ba8c553d391c7461ff012d8b9c5393";
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

  # We use this to seed our database. Run as follows:
  # ```bash
  # $ coach-scraper \
  #     --host 127.0.0.1 \
  #     --user postgres \
  #     --dbname boardwise \
  #     --user-agent <email> \
  #     --site lichess \
  #     --site chesscom
  # ```
  environment.systemPackages = [
    coach-scraper.packages.${system}.app
  ];

  sops = {
    secrets.BOARDWISE_SECRET_KEY_BASE = {
      sopsFile = ./secrets.yaml;
    };
  };
}
