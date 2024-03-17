{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/444418d78e275a435031d1995ded85cd477c1526";
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
