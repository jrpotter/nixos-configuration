{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').nil_ls) {}
    '';

    extraPackages = [ pkgs.nil ];
  };
}
