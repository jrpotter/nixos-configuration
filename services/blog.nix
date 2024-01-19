{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/7bd69197cfbb8fb5e48f02abf2848b0061fc4559";
in
{
  services.nginx.virtualHosts."blog.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = blog.packages.${system}.app;
    };
  };
}
