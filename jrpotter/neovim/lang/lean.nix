args @ { pkgs, ... }:
let
  utils = import ../utils.nix args;

  lean-nvim = {
    plugin = utils.pluginGit
      "47ff75ce2fcc319fe7d8e031bc42a75473919b93"
      "Julian/lean.nvim";
    config = ''
      lua << EOF
      require('init.lsp').setup(require('lean')) {
        abbreviations = { builtin = true },
        mappings = true,
      }
      EOF
    '';
  };
in
{
  programs.neovim = {
    plugins = [
      lean-nvim
      pkgs.vimPlugins.plenary-nvim
    ];
  };
}
