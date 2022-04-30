{ version }:
{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball (
    "https://github.com/nix-community/home-manager/archive/" +
    "release-${version}.tar.gz"
  );

  flake-templates = pkgs.fetchFromGitHub {
    owner = "jrpotter";
    repo = "flake-templates";
    rev = "53485f858247e4c74c4a83ffb89fbcbd04c809a0";
    sha256 = "0jwyv7ss5r93nwsg5lvfvhzsk1xk54aaa18gilx8lixv2yf9fcad";
  };

  homesync = pkgs.fetchFromGitHub {
    owner = "jrpotter";
    repo = "homesync";
    rev = "33001c5450669aefc99722ef0266c7d83f6dbe4e";
    sha256 = "1d4mdpgjxv2f7ksif5khp8wri8sj2wdc0pn7rsyr17i7pbi4m7d3";
  };

  nix-thunk = pkgs.fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "nix-thunk";
    rev = "72532c336d1c5119830ea8b30fbafe10866c6d5e";
    sha256 = "087zb2av81f7w4cyrf5y4qkg1xjih240hvvrk8k7l16807xk4l6f";
  };

  obelisk = pkgs.fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "obelisk";
    rev = "e3ec75f6988eed47189dd20f8c8514748b33ea81";
    sha256 = "0sdlcyzdx9nyql5vmpjydhzsakixc8y050v8m2rz87l2rmhkqnw9";
  };

  unstable = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "1ec61dd4167f04be8d05c45780818826132eea0d";
    sha256 = "0aglyrxqkfwm4wxlz642vcgn0m350jv4nhhyq91cxylvs1avps54";
  };
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

  users.users = {
    jrpotter = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keyFiles = [
        ../config/jrpotter/authorized-keys
      ];
    };
  };

  home-manager.users.jrpotter = { pkgs, ... }: {
    home.packages = with pkgs; [
      alacritty
      bitwarden
      cabal-install
      chromium
      firefox
      ffmpeg
      fzf
      ghc
      gimp
      libreoffice
      mosh
      mullvad-vpn
      ripgrep
      signal-desktop
      simplescreenrecorder
      tmux
      universal-ctags
      vlc
      yarn
      # Imported
      (import flake-templates).packages.${builtins.currentSystem}.nix-gen
      (import homesync).packages.${builtins.currentSystem}.homesync
      (import nix-thunk {}).command
      (import obelisk {}).command
      (import unstable {}).neovim
    ];
    programs = {
      bash = {
        enable = true;
        shellAliases = {
          grep = "grep --color";
          ls = "ls --color";
        };
        initExtra = builtins.readFile ./init-extra.sh;
      };
      direnv.enable = true;
      direnv.nix-direnv.enable = true;
      direnv.nix-direnv.enableFlakes = true;
      vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          dracula-theme.theme-dracula
          haskell.haskell
          jnoortheen.nix-ide
          justusadam.language-haskell
        ];
      };
    };
  };

  # https://nixos.wiki/wiki/Fonts
  # `FiraCode` is the default font we set within the alacritty terminal.
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # This corresponds to the configured allowed port.
  networking.firewall.allowedTCPPorts = [ 54878 55097 ];

  services.mullvad-vpn.enable = true;
  # This does not # necessarily apply to Mullvad, but in case it might, refer to
  # the following for why we need this when enabling VPN:
  # https://github.com/NixOS/nixpkgs/issues/101864#issuecomment-1004358879
  networking.enableIPv6 = false;
}
