{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/426215c12ba709e02dadba5f8d4c944bbdcf90fb";
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
