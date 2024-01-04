{ pkgs, ... }:
{
  home.packages = with pkgs; [
    marksman
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('utils.lsp').setup(require('lspconfig').marksman) {}
    '';
  };
}
