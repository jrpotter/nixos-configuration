{ system, pkgs, lib, ... }:
let
  reconn-url = "git+https://git.jrpotter.com/r/reconn?rev=fa031b2507c625c54abca36fd3f86fc8338e8777";
  reconn = (builtins.getFlake reconn-url).packages.${system}.app;
in
{
  services = {
    nginx.virtualHosts."www.hideandseek.live" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "hideandseek.live" ];
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:4000";
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
      DATABASE_URL = "ecto://postgres:postgres@localhost/reconn";
    };
    serviceConfig = {
      Type = "exec";
      EnvironmentFile = "/run/secrets/RECONN_SECRET_KEY_BASE";
      ExecStartPre = "${reconn}/bin/migrate";
      ExecStart = "${reconn}/bin/reconn start";
      ExecStop = "${reconn}/bin/reconn stop";
      ExecReload = "${reconn}/bin/reconn restart";
      Restart = "on-failure";
    };
  };

  sops = {
    secrets.RECONN_SECRET_KEY_BASE = {
      sopsFile = ./secrets.yaml;
    };
  };
}
