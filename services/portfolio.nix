{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/eb0bc7d44ba1349860a56797b92761c68a4e7dce";
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
