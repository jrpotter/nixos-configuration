{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').nil_ls) {}
    '';
  };
}
