{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/35fe6e376249300007f90a2bca4b36a0a739cf09";
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
