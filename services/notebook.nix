{ system, ... }:
let
  notebook = builtins.getFlake
    "github:jrpotter/notebook/79b715a64c703279f593cad08775b0d73400a19b";
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
