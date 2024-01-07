{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/313136701fc918675675178905aaff0e0b3f9c75";
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
