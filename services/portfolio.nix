{ system, ... }:
let
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/357999e784102ba11c52cf1fc9edbfaa8a00912d";
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
