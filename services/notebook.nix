{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/a42ccc880a7c408ec7f87f6eceeaf9d435e68cc4";
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
