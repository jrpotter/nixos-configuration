{ ... }:
{
  services = {
    forgejo.enable = true;
    nginx.virtualHosts."forgejo.jrpotter.com" = {
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
}
