{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/a02bda1eed7356fca126a01d2d1bf2de80c8ee97";
in
{
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."notebook.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "${notebook.packages.${system}.app}/share";
        tryFiles = "$uri $uri.html $uri/ =404";
      };
    };
  };
}
