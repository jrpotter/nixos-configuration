{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/9bec3123b1816a0d1c04f42c40ed46baef5f3ce0";
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
