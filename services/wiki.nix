{ system, ... }:
let
  wiki = builtins.getFlake
    "github:jrpotter/wiki/ea2b31616bb8fbe633db224d6d663adbebf2f972";
in
{
  services.nginx.virtualHosts."wiki.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = wiki.packages.${system}.app;
    };
  };
}
