{ pkgs, ... }:
{
  home.packages = with pkgs;[
    lua-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('lang.lua').nvim_lspconfig()
    '';
  };
}
