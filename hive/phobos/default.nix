{ pkgs, lib, system, home-manager, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    ../../digital-ocean/configuration.nix
    home-manager.nixosModules.home-manager
  ];

  environment = {
    systemPackages = with pkgs; [
      gcc
      git
      ((vim_configurable.override {}).customize {
        name = "vim";
        vimrcConfig.customRC = ''
          set nocompatible
          syntax on

          set colorcolumn=80,100
          set expandtab     " Spaces instead of tabs.
          set list          " Show hidden characters.
          set listchars=tab:>\ ,trail:-,nbsp:+
          set shiftwidth=2  " # of spaces to use for each (auto)indent.
          set tabstop=2     " # of spaces a <Tab> in the file counts for.
        '';
      })
    ];
    variables = {
      EDITOR = "vim";
    };
  };

  fonts.packages = with pkgs; [ iosevka ];

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
            update = old: old ++ [ pkgs.wezterm ];
          }
        ] base;

    # Used to pass non-default parameters to submodules.
    extraSpecialArgs = {
      inherit system;
      stateVersion = "23.11";
    };
  };

  networking.hostName = "phobos";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.mosh.enable = true;

  # Our NixOS droplet's do not have a root password set. Disable so we can still
  # run commands that require sudo (e.g. `colmena apply-local --sudo`).
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;

  time.timeZone = "America/Denver";

  users.users.jrpotter = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "libvirtd"
      "wheel"
    ];
  };

  virtualisation.docker.rootless = {
    enable = true;
    # Sets the `DOCKER_HOST` variable to the rootless Docker instance for normal
    # users by default.
    setSocketVariable = true;
  };

  system.stateVersion = "23.11";
}
