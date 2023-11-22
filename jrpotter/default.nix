{ config, pkgs, lib, ... }:
{
  options.home.extraPythonPackages = lib.mkOption {
    type = lib.types.listOf lib.types.string;
    example = ''
      [ debugpy mccabe ]
    '';
    description = lib.mdDoc ''
      Extra Python packages that should be linked to the topmost Python
      interpreter.
    '';
  };

  imports = [
    ./git.nix
    ./neovim
    ./wezterm
  ];

  config = {
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
        (python3.withPackages
          (ps: builtins.map (s: ps.${s}) config.home.extraPythonPackages))
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
  };
}
