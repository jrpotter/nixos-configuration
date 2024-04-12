{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/eca5e764f26faaa64f6966dbf3970b86eaaf2195";
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
