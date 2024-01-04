args @ { pkgs, ... }:
let
  neovimUtils = import ../neovim/utils.nix args;

  lean-nvim = {
    plugin = neovimUtils.pluginGit
      "47ff75ce2fcc319fe7d8e031bc42a75473919b93"
      "Julian/lean.nvim";
    config = ''
      lua << EOF
      require('utils.lsp').setup(require('lean')) {
        abbreviations = { builtin = true },
        mappings = true,
      }
      EOF
    '';
  };
in
{
  home.packages = with pkgs; [
    elan
  ];

  programs.neovim = {
    plugins = [
      lean-nvim
      pkgs.vimPlugins.plenary-nvim
    ];
  };
}
