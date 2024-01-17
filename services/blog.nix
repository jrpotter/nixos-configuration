{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/9e3821f31a1261bffb83392ce02cb9d2a6da9b81";
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
