{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/1d5f0c25c9106f3302c79f0cdd99a4604ee3748a";
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
