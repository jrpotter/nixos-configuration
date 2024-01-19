{ sops-nix, lib, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    sops-nix.nixosModules.sops
    ../../digital-ocean/configuration.nix
  ];

  deployment.targetHost = "143.198.142.171";

  networking = {
    hostName = "phobos";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  programs.mosh.enable = true;

  services = {
    nginx.enable = true;
    openssh.enable = true;
    postgresql.enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jrpotter2112@gmail.com";
  };

  system.stateVersion = "23.11";
}
