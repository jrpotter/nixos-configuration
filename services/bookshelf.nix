{ system, ... }:
let
  bookshelf = builtins.getFlake
    "github:jrpotter/bookshelf/bf9888c050b7a62f58be0198af19a6de7c40b375";
in
{
  services.nginx.virtualHosts."bookshelf.jrpotter.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = bookshelf.packages.${system}.app;
    };
  };
}
