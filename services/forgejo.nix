{ ... }:
{
  services = {
    forgejo.enable = true;
    nginx.virtualHosts."git.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
}
