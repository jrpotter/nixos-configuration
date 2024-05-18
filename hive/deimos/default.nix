{ sops-nix, lib, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    sops-nix.nixosModules.sops
    ../../digital-ocean/configuration.nix
    ../../services/bookshelf.nix
    ../../services/notebook.nix
    ../../services/portfolio
  ];

  networking = {
    hostName = "deimos";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  programs.mosh.enable = true;

  services = {
    nginx.enable = true;
    openssh.enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jrpotter2112@gmail.com";
  };

  system.stateVersion = "23.11";
}
