{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/987e606455d37341ff7127bb396e10f017350e83";
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
