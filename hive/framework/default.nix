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
    users.jrpotter = args@{ pkgs, lib, ... }:
      let
        base = import ../../users/jrpotter args;
      in
        lib.attrsets.updateManyAttrsByPath [
          {
            path = [ "home" "packages" ];
            update = old: old ++ (with pkgs; [
              anki-bin
              bitwarden
              firefox
              gimp
              wezterm
              zotero
            ]);
          }
        ] base;

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
