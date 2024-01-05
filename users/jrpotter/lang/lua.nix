{ pkgs, ... }:
{
  home.packages = with pkgs;[
    lua-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('lua.init').nvim_lspconfig()
    '';

    nvim-snippets = ''
      require('luasnip').add_snippets('lua', require('lua.snippets'))
    '';
  };
}
