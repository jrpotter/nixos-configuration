{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/09fcb0b96a9c503b69d0bccc8f253110dd42ef77";
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
