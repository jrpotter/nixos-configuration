{ system, stateVersion, home-manager, modulesPath, lib, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    home-manager.nixosModules.home-manager
  ];

  deployment.targetHost = "143.110.158.6";

  networking.hostName = "titan";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;

  programs.mosh.enable = true;

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
