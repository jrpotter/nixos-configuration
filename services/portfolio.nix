{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/0f89bdf6c17dd7a61988f8b3629db1988e6f7357";
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
