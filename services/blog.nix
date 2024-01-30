{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/457bfd6c521d5d8eeb41deb7d5d6a925fd55dda9";
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
