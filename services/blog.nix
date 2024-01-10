{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/3985323a0378ad7571511a348ef83ef833b08646";
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
