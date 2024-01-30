{ system, ... }:
let
  wiki = builtins.getFlake
    "github:jrpotter/wiki/7fa6887142330f5d51d8da45f896441684b6ef93";
in
{
  services.nginx.virtualHosts."wiki.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = wiki.packages.${system}.app;
    };
  };
}
