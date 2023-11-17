{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('lspconfig').nil_ls.setup {}
    '';

    extraPackages = [ pkgs.nil ];
  };
}
