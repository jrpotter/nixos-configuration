{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/ab01d079d1cd491ab7b44c98516cb290cf088761";
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
