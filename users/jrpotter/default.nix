{ stateVersion, pkgs, ... }:
let
  bootstrap = builtins.getFlake
    "github:jrpotter/bootstrap/635395b9cc946d8c8f1851b5c4dc6210fb54e400";
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
      anki-bin
      bitwarden
      bootstrap
      colmena
      dig
      file
      firefox
      gimp
      mosh
      mullvad-vpn
      unzip
      wezterm
      zotero
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
