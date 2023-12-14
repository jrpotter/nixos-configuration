{ system, stateVersion, lib, ... }:
let
  blog = builtins.getFlake
    "github:jrpotter/blog/689107113f248cc2cad2a53d9f7d32be484c9060";
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
      "blog.jrpotter.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = blog.packages.${system}.app;
        };
      };
    };
  };

  system.stateVersion = stateVersion;
}
