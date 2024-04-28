{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/88457c1f03e467e965654d10998875f3b40a9eb5";
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
