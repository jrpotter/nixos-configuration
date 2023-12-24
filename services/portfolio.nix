{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/5cd978ef3856975c622d76ec4adfc6fdcdec13a7";
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
