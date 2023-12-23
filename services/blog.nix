{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/29a44a257989ab85a38690b18debfe1b27a70674";
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
