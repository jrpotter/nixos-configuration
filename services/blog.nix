{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/c4f8c98c5ea405da731b7d16d6a7d9e09c74bfba";
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
