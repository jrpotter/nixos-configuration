{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/f17df1c6244e451d3c5d9f7bfd4076451446ff7b";
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
