# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  version = "21.11";   # The current version of NixOS being used.
  enableLVM = false;   # Whether or not we have LVM enabled.
  enableZFS = true;    # Whether or not we have ZFS enabled.
in {
  imports = [
    ./hardware-configuration.nix
    (import ./luks.nix { inherit enableLVM enableZFS; })
  ] ++ (
    if enableZFS then [./zfs.nix] else []
  ) ++ [
    ./obsidian
    (import ./jrpotter { inherit version; })
  ];

  # Allow non-redistributable licensed packages. Includes some firmware:
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/all-firmware.nix
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # This line is critical for certain components (e.g. network) to work properly
  # on Framework machines.
  # https://grahamc.com/blog/nixos-on-framework
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp170s0.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    file
    gcc
    git
    glibc
    gnumake
    tree
    unzip
    vim
    # https://nixos.wiki/wiki/Flakes
    # Keep flakes-enabled nix in a separate command since it is still
    # experimental.
    (pkgs.writeShellScriptBin "nixFlakes" ''
      exec ${pkgs.nixFlakes}/bin/nix \
        --experimental-features "nix-command flakes" \
        "$@"
    '')
  ];

  # Set default editor to vim. We intentionally use this over neovim
  # since neovim is not nearly as stable (especially considering it
  # is sourced from the `unstable` package set).
  environment.variables = { EDITOR = "vim"; };

  # This value determines the NixOS release from which the default settings for
  # stateful data, like file locations and database versions on your system were
  # taken. It‘s perfectly fine and recommended to leave this value at the
  # release version of the first install of this system. Before changing this
  # value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = version;
}
