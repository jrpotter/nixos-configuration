{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/4b65764c8973f54b82a0192aef19391fc61e1fef";
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
