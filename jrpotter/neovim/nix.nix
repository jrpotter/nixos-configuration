{ pkgs, ... }:
{
  nvim-lspconfig = ''
    require('lspconfig').nil_ls.setup { }
  '';

  extraPackages = with pkgs; [
    nil
  ];
}
