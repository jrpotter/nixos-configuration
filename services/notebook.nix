{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/7ae8589742870b5b414445e5852cd9c8751480ca";
in
{
  services.nginx.virtualHosts."notebook.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = notebook.packages.${system}.app;
      tryFiles = "$uri $uri.html $uri/ =404";
    };
  };
}
