{ system, stateVersion, lib, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/29a44a257989ab85a38690b18debfe1b27a70674";
  portfolio = builtins.getFlake
    "github:jrpotter/portfolio/0f89bdf6c17dd7a61988f8b3629db1988e6f7357";
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
