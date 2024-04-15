{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/6fe09c5a35e4ce039e570ce62cb38821f191dd4e";
in
{
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."www.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [ "jrpotter.com" ];
      locations."/" = {
        root = portfolio.packages.${system}.app;
      };
    };
  };
}
