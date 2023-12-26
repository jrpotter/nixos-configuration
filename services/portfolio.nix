{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/f9d1f38843a859ec5525a0f03612a2e3769bb442";
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
