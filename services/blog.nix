{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/31dd6856e9d9e2c70138229101b419df88ccb04e";
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
