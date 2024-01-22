{ lib, system, home-manager, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    ../../digital-ocean/configuration.nix
    home-manager.nixosModules.home-manager
  ];

  deployment.targetHost = "144.126.218.252";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jrpotter = import ../../users/jrpotter;

    # Used to pass non-default parameters to submodules.
    extraSpecialArgs = {
      inherit system;
      stateVersion = "23.11";
    };
  };

  networking.hostName = "phobos";

  programs.mosh.enable = true;

  services.openssh.enable = true;

  users.users.jrpotter = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "libvirtd"
      "wheel"
    ];
  };

  system.stateVersion = "23.11";
}
