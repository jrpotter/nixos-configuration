{ pkgs, ... }:
{
  home.packages = with pkgs;[
    lua-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('lua.init').nvim_lspconfig()
    '';
  };
}
