{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/e578ed4615c0faffd3f27702a028b998bbdad7ca";
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
