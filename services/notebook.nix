{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/45bcc6744c820adc5856d166405650b08bee7835";
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
