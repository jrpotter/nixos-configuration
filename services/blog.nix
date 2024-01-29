{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/042544b4b92490574fb0e8dd68dabf652641b3cd";
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
