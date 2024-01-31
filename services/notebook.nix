{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/d3feb5028bca495b4c96314e251f4308e454a113";
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
