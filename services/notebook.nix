{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/1651c9d6c3e75fd25557dd6cefef6e4d6441ff46";
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
