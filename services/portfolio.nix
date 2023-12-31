{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/9ac227048c378d776ffa933c5aecf19db46cf07a";
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
