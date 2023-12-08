{ pkgs, ... }:
{
  home.packages = with pkgs;[
    lua-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lua').nvim_lspconfig()
    '';
  };
}
