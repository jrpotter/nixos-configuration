{ system, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/76e0accbacb113fff57d42a9dc59adafc02eb885";
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
