# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  environment = {
    # Excludes some KDE plasma applications from the default
    # install. We choose to use KDE since, with wayland support,
    # is is capable of fractional scaling.
    plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      gwenview
      khelpcenter
      konsole
      okular
      oxygen
      plasma-browser-integration
      print-manager
    ];
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

  # After 23.05, this option is called `fonts.packages`.
  fonts.fonts = with pkgs; [
    iosevka
  ];

  hardware.bluetooth.enable = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Recommended when using pipewire.
  # https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;

  services = {
    mullvad-vpn.enable = true;
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      desktopManager.xterm.enable = false;
      displayManager.defaultSession = "plasmawayland";
      xkbOptions = "ctrl:swapcaps";
    };
  };

  time.timeZone = "America/Denver";

  # Don't forget to set a password with `passwd`.
  users.users.jrpotter = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"  # Enable `sudo` for the user.
    ];
  };

  virtualisation.docker.rootless = {
    enable = true;
    # Sets the `DOCKER_HOST` variable to the rootless Docker instance for normal
    # users by default.
    setSocketVariable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05";
}

