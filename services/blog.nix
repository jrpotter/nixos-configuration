{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/692b6c237f57fe1b0b3badc1ff1b33db99cf7ff6";
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
