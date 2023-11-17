{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lua').nvim_lspconfig()
    '';

    extraPackages = [ pkgs.lua-language-server ];
  };
}
