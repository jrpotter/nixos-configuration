{ system, stateVersion, home-manager, modulesPath, lib, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    home-manager.nixosModules.home-manager
  ];

  deployment.targetHost = "143.198.97.253";

  networking.hostName = "titan";

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
