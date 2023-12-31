{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/0b98273575532aac286f0f98d417e761400bbd81";
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
