{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/f8ce67a38c73bf34f42056c3e32e138b3cdac8bb";
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
