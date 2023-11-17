{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('lspconfig').lua_ls.setup { }
    '';

    extraPackages = [ pkgs.lua-language-server ];
  };
}
