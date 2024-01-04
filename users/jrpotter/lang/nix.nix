{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('utils.lsp').setup(require('lspconfig').nil_ls) {}
    '';
  };
}
