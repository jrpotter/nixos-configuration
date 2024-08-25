{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/a0c7a4e2a8e04ec14fdbbd1722ce4f7f74a9ec55";
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
