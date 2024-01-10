{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/869cbe0f566814caa8a791d956ea794004f2eb7d";
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
