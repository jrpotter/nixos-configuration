{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/992dff94f4a2d93a6b35aa9665d377cb30410686";
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
