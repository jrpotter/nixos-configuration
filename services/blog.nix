{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/e922711b9e5ef4e311e6cd7ce02ad338f7945475";
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
