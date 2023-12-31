{ pkgs, ... }:
{
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

  fonts.packages = with pkgs; [ iosevka ];

  hardware.bluetooth.enable = true;

  networking.hostName = "framework";
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

  # time.timeZone = "America/Denver";
  time.timeZone = "America/New_York";

  virtualisation = {
    libvirtd.enable = true;
    docker.rootless = {
      enable = true;
      # Sets the `DOCKER_HOST` variable to the rootless Docker instance for normal
      # users by default.
      setSocketVariable = true;
    };
  };
}
