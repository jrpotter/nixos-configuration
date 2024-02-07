{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/3e5bb9b9a78f5d67c88df2247d6630176e7afbc4";
in
{
  services.nginx.virtualHosts."notebook.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = "${notebook.packages.${system}.app}/share";
      tryFiles = "$uri $uri.html $uri/ =404";
    };
  };
}
