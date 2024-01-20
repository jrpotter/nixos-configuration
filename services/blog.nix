{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/26e385791ccb78823491413fc7d61121716d8ad8";
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
