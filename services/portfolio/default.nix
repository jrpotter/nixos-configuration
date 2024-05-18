{ system, ... }:
let
  portfolio = (
    builtins.getFlake "github:jrpotter/portfolio/0e507765ed4652836af29747d9c384dd91157ec8"
  ).packages.${system}.app;
in
{
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."www.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "jrpotter.com" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.portfolio = {
    enable = true;
    description = "Portfolio Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network-online.target" ];
    environment = {
      PHX_HOST = "jrpotter.com";
    };
    serviceConfig = {
      Type = "exec";
      EnvironmentFile = "/run/secrets/PORTFOLIO_SECRET_KEY_BASE";
      ExecStart = "${portfolio}/bin/server start";
      ExecStop = "${portfolio}/bin/server stop";
      ExecReload = "${portfolio}/bin/server restart";
      Restart = "on-failure";
    };
  };

  sops = {
    secrets.PORTFOLIO_SECRET_KEY_BASE = {
      sopsFile = ./secrets.yaml;
    };
  };
}
