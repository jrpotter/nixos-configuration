{ system, pkgs, lib, ... }:
let
  reconn = (
    builtins.getFlake "git+ssh://forgejo@git.jrpotter.com/r/reconn?rev=4147b54f0f5da7ec7bc4f54ba888d3a97153ec1a"
  ).packages.${system}.app;
in
{
  services = {
    nginx = {
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."www.hideandseek.live" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "hideandseek.live" ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:4000";
          proxyWebsockets = true;
        };
      };
    };
    postgresql = {
      package = (pkgs.postgresql_15.withPackages (pkgs: [ pkgs.postgis ]));
      ensureDatabases = [ "reconn" ];
      authentication = lib.mkOverride 10 ''
        # TYPE     DATABASE     USER     ADDRESS         METHOD
          local    all          all                      trust
          host     all          all      127.0.0.1/32    trust
      '';
    };
  };

  systemd.services.reconn = {
    enable = true;
    description = "Reconn Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    requires = [ "network-online.target" "postgresql.service" ];
    environment = {
      PHX_HOST = "hideandseek.live";
      DATABASE_URL = "ecto://postgres:postgres@localhost/reconn";
    };
    serviceConfig = {
      Type = "exec";
      EnvironmentFile = "/run/secrets/RECONN_SECRET_KEY_BASE";
      ExecStartPre = "${reconn}/bin/migrate";
      ExecStart = "${reconn}/bin/server start";
      ExecStop = "${reconn}/bin/server stop";
      ExecReload = "${reconn}/bin/server restart";
      Restart = "on-failure";
    };
  };

  sops = {
    secrets.RECONN_SECRET_KEY_BASE = {
      sopsFile = ./secrets.yaml;
    };
  };
}
