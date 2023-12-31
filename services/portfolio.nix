{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/c13f0c7b9976cc4c68e284f9e6d1f566574d782f";
in
{
  services.nginx.virtualHosts."www.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "jrpotter.com" ];
    locations."/" = {
      root = portfolio.packages.${system}.app;
    };
  };
}
