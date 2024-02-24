args @ { pkgs, ... }:
let
  neovimUtils = import ../neovim/utils.nix args;

  lean-nvim = {
    plugin = neovimUtils.pluginGit
      "dd37e1d2e320fb8a0948bf6ca3f7703c98b80ecb"
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
