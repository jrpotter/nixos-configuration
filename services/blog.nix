{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/47a8ec234cea73022ceba7b2a09f2e9e75e709ce";
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
