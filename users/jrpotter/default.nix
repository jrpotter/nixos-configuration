{ stateVersion, pkgs, ... }:
let
  bootstrap = builtins.getFlake
    "github:jrpotter/bootstrap/e76d111eb10a3dbfa42b19e1301f28b9d1c33e14";
in
{
  imports = [
    ./bash
    ./git.nix
    ./lang/bash.nix
    ./lang/c.nix
    ./lang/elixir.nix
    ./lang/lean.nix
    ./lang/lua.nix
    ./lang/markdown.nix
    ./lang/nix.nix
    ./lang/python.nix
    ./lang/typescript.nix
    ./neovim
    ./wezterm
  ];

  home = {
    username = "jrpotter";
    homeDirectory = "/home/jrpotter";
    packages = with pkgs; [
      bootstrap.packages.${system}.default
      colmena
      dig
      file
      mosh
      mullvad-vpn
      unzip
    ];
  };

  programs = {
    bash.enable = true;
    direnv.enable = true;
    git.enable = true;
    home-manager.enable = true;
    neovim.enable = true;
  };

  # This value determines the Home Manager release that
  # your configuration is compatible with. This helps avoid
  # breakage when a new Home Manager release introduces
  # backwards-incompatible changes.
  #
  # You can update Home Manager without changing this value.
  # See the Home Manager release notes for a list of state
  # version changes in each release.
  home.stateVersion = stateVersion;
}
