{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/61532d4bb7cc12fe689ad2dc9d7aa4349ff57917";
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
