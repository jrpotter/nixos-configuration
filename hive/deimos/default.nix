{ system, stateVersion, lib, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/d5e3dba9f2620050365084e396bd481e68dd3795";
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/d07f24b8087f712f6d2436e2fbc4af6b56518ce6";
  bookshelf = builtins.getFlake
    "github:jrpotter/bookshelf/bf9888c050b7a62f58be0198af19a6de7c40b375";
in
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    ../../digital-ocean/configuration.nix
  ];

  deployment.targetHost = "24.199.110.222";

  networking = {
    hostName = "deimos";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  programs.mosh.enable = true;

  services.openssh.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "jrpotter2112@gmail.com";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.jrpotter.com" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "jrpotter.com" ];
        locations."/" = {
          root = portfolio.packages.${system}.app;
        };
      };
      "blog.jrpotter.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = blog.packages.${system}.app;
        };
      };
      "bookshelf.jrpotter.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = bookshelf.packages.${system}.app;
        };
      };
    };
  };

  system.stateVersion = stateVersion;
}
