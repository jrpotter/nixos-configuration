{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./neovim
    ./wezterm
  ];

  home = {
    username = "jrpotter";
    homeDirectory = "/home/jrpotter";

    packages = with pkgs; [
      anki-bin
      bitwarden
      elan
      firefox
      gnumake
      mullvad-vpn
      python3
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
  home.stateVersion = "23.05";
}
