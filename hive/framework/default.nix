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
        base = import ../../users/jrpotter args // {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
            };
          };
        };
      in
        lib.attrsets.updateManyAttrsByPath [
          {
            path = [ "home" "packages" ];
            update = old: old ++ (with pkgs; [
              anki-bin
              bitwarden
              firefox
              gimp
              virt-manager
              wezterm
              zotero
            ]);
          }
        ] base;

    # Used to pass non-default parameters to submodules.
    extraSpecialArgs = { inherit system stateVersion; };
  };

  # virt-manager requires dconf to remember settings.
  programs.dconf.enable = true;

  users.users.jrpotter = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "libvirtd"
      "wheel"
    ];
  };

  system.stateVersion = stateVersion;
}
