{ pkgs, ... }:
{
  home.packages = with pkgs; [
    marksman
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').marksman) {}
    '';
  };
}
