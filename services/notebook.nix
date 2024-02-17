{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/ae7155758923bd9ca371d70ecae1dfbbea744f12";
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
