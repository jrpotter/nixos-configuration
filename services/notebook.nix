{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/99e807f8074aae47a4e733ca3eaa8693f681e20f";
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
