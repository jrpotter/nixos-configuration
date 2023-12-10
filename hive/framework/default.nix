{ system, stateVersion, home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jrpotter = import ../../users/jrpotter;
    # Used to pass non-default parameters to submodules.
    extraSpecialArgs = { inherit system stateVersion; };
  };

  users.users.jrpotter = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
  };

  system.stateVersion = stateVersion;
}
