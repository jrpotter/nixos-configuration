{ system, ... }:
let
  wiki = builtins.getFlake
    "github:jrpotter/wiki/ea476410252407a861c1205366675e87137525f6";
in
{
  services.nginx.virtualHosts."wiki.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = wiki.packages.${system}.app;
      tryFiles = "$uri $uri.html $uri/ =404";
    };
  };
}
