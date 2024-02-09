{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/4982b6e21f5de64a03932da28f769c8b993ee898";
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
