{ pkgs, ... }:
{
  nvim-lspconfig = ''
    require('lspconfig').lua_ls.setup { }
  '';

  extraPackages = with pkgs; [
    lua-language-server
  ];
}
